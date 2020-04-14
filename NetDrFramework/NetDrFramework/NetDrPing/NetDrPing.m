//
//  NetDrPing.m
//  NetDr
//
//  Created by 张艺哲 on 2020/4/1.
//  Copyright © 2020 com.elecoxy. All rights reserved.
//

#import "NetDrPing.h"
#include <sys/socket.h>
#include <netdb.h>
#import "SimplePing.h"

@interface NetDrPing () <SimplePingDelegate>

// ping 次数
@property (nonatomic, assign) NSInteger count;

// ping实例
@property (nonatomic, strong) SimplePing * pinger;

// ping时间控制器实例
@property (nonatomic, strong) NSTimer * timer;

// 域名
@property (nonatomic, copy) NSString * hostName;

// 域名ip地址
@property (nonatomic, copy) NSString * ip;

// 包数组
@property (nonatomic, strong) NSMutableArray <NetDrPingPacketData *> * packetArr;

// 接收到的包数量
@property (nonatomic, assign) long long receiveNum;

// 丢失的包数量
@property (nonatomic, assign) long long lossNum;

@end

@implementation NetDrPing

/// 使用IPv4/IPv6来请求
/// @param hostName 域名
/// @param count 请求次数  -1 -> 不限次数
- (void)startWithHostName: (NSString *) hostName count: (NSInteger) count
{
    [self startWithHostName:hostName forceIPv4: NO forceIPv6: NO count: count];
}

/// 使用IPv6来请求
/// @param hostName 域名
/// @param count 请求次数  -1 -> 不限次数
- (void)startForceIPv6WithHostName: (NSString *) hostName count: (NSInteger) count
{
    [self startWithHostName:hostName forceIPv4: NO forceIPv6: YES count: count];
}

/// 使用IPv4来请求
/// @param hostName 域名
/// @param count 请求次数  -1 -> 不限次数
- (void)startForceIPv4WithHostName: (NSString *) hostName count: (NSInteger) count
{
    [self startWithHostName:hostName forceIPv4: YES forceIPv6: NO count: count];
}

- (void)startWithHostName: (NSString *) hostName forceIPv4: (BOOL) forceIPv4 forceIPv6: (BOOL) forceIPv6 count: (NSInteger) count
{
    [self stop];
    
    _count = count;
    _hostName = hostName;
    _ip = @"";
    _packetArr = [NSMutableArray new];
    _pinger = [[SimplePing alloc] initWithHostName: hostName];
    _receiveNum = 0;
    _lossNum = 0;
    
    if (forceIPv4 && !forceIPv6) {
        _pinger.addressStyle = SimplePingAddressStyleICMPv4;
    } else if (!forceIPv4 && forceIPv6) {
        _pinger.addressStyle = SimplePingAddressStyleICMPv6;
    }
    
    _pinger.delegate = self;
    [_pinger start];
}

- (void)stop
{
    if (_pinger) { // 真正停止
        if (_endBlock) {
            _endBlock(_packetArr, _packetArr.count, _receiveNum, _packetArr.count == 0 ? 0 : (float)_lossNum / (float)_packetArr.count);
        }
    }
    
    [_pinger stop];
    _pinger = nil;
    
    [_timer invalidate];
    _timer = nil;
}

- (void)sendPingisFirst: (BOOL) isFirst
{
    if (_count == 0) {
        if (!_packetArr.lastObject.overUnixTime && !isFirst) { // 超时
            NetDrPingPacketData * packetData = _packetArr.lastObject;
            packetData.overUnixTime = [NetDrPing currentUnixTimeStr];
            packetData.status = NO;
            packetData.errorDescription = @"Request timeout";
            _lossNum += 1;
            
            // 单个包结果返回
            if (_singlePacketBlock) _singlePacketBlock(packetData);
        }
        
        [self stop];
        return;
    }
    
    if (_count > 0) _count -= 1;
    
    if (!_packetArr.lastObject.overUnixTime && !isFirst) { // 超时
        NetDrPingPacketData * packetData = _packetArr.lastObject;
        packetData.overUnixTime = [NetDrPing currentUnixTimeStr];
        packetData.status = NO;
        packetData.errorDescription = @"Request timeout";
        _lossNum += 1;
        
        // 单个包结果返回
        if (_singlePacketBlock) _singlePacketBlock(packetData);
    }
    
    [_pinger sendPingWithData: nil];
}

// MARK: - SimplePing delegate callback

// 开始Ping
- (void)simplePing:(SimplePing *)pinger didStartWithAddress:(NSData *)address
{
    _ip = [NetDrPing displayAddressForAddress: address];
    
    if (_startBlock) _startBlock(_hostName, _ip);
    
    // 第一次ping操作
    [self sendPingisFirst: YES];
    
    // 开始定时器操作
    if (_timer) return;
    _timer = [NSTimer scheduledTimerWithTimeInterval: 1.0 target: self selector:@selector(sendPingisFirst:) userInfo:nil repeats: YES];
    
}

// 由于发生错误结束Ping
- (void)simplePing:(SimplePing *)pinger didFailWithError:(NSError *)error
{
    if (_errorEndBlock) {
        _errorEndBlock([NetDrPing shortErrorFromError: error]);
    }
    
    [self stop];
}

// 发送Ping包
- (void)simplePing:(SimplePing *)pinger didSendPacket:(NSData *)packet sequenceNumber:(uint16_t)sequenceNumber
{
    NetDrPingPacketData * packetData = [NetDrPingPacketData new];
    packetData.icmpSeq = sequenceNumber;
    packetData.ip = _ip;
    packetData.startUnixTime = [NetDrPing currentUnixTimeStr];
    packetData.status = NO;
    [_packetArr addObject: packetData];
}

// 收到错误Ping包
- (void)simplePing:(SimplePing *)pinger didFailToSendPacket:(NSData *)packet sequenceNumber:(uint16_t)sequenceNumber error:(NSError *)error
{
    NSInteger packetArrNum = _packetArr.count;
    
    if (sequenceNumber > packetArrNum - 1) {
        [self stop];
        return;
    }
    
    NetDrPingPacketData * packetData = _packetArr[sequenceNumber];
    packetData.overUnixTime = [NetDrPing currentUnixTimeStr];
    packetData.status = NO;
    packetData.errorDescription = [NetDrPing shortErrorFromError: error];
    
    _lossNum += 1;
    
    // 单个包结果返回
    if (_singlePacketBlock) _singlePacketBlock(packetData);
}

// 收到成功Ping包
- (void)simplePing:(SimplePing *)pinger didReceivePingResponsePacket:(NSData *)packet sequenceNumber:(uint16_t)sequenceNumber timeToLive:(NSInteger)timeToLive
{
    NSInteger packetArrNum = _packetArr.count;
    
    if (sequenceNumber > packetArrNum - 1) {
        [self stop];
        return;
    }
    
    NetDrPingPacketData * packetData = _packetArr[sequenceNumber];
    packetData.size = [NSString stringWithFormat:@"%zu", packet.length];
    packetData.ttl = timeToLive;
    packetData.overUnixTime = [NetDrPing currentUnixTimeStr];
    packetData.status = YES;
    
    _receiveNum += 1;
    
    // 单个包结果返回
    if (_singlePacketBlock) _singlePacketBlock(packetData);
}

// 接收到不匹配的ICMP消息
- (void)simplePing:(SimplePing *)pinger didReceiveUnexpectedPacket:(NSData *)packet
{
    if (_singleUnexpectedPacketBlock) _singleUnexpectedPacketBlock(packet.length);
}

// MARK: - utilities

/*! Returns the string representation of the supplied address.
 *  \param address Contains a (struct sockaddr) with the address to render.
 *  \returns A string representation of that address.
 */

+ (NSString *)displayAddressForAddress: (NSData *) address
{
    int         err;
    NSString *  result;
    char        hostStr[NI_MAXHOST];
    
    result = nil;
    
    if (address != nil) {
        err = getnameinfo(address.bytes, (socklen_t) address.length, hostStr, sizeof(hostStr), NULL, 0, NI_NUMERICHOST);
        if (err == 0) {
            result = @(hostStr);
        }
    }
    
    if (result == nil) {
        result = @"?";
    }

    return result;
}

/*! Returns a short error string for the supplied error.
 *  \param error The error to render.
 *  \returns A short string representing that error.
 */

+ (NSString *) shortErrorFromError: (NSError *) error
{
    NSString *      result;
    NSNumber *      failureNum;
    int             failure;
    const char *    failureStr;
    
    assert(error != nil);
    
    result = nil;
    
    // Handle DNS errors as a special case.
    
    if ( [error.domain isEqual:(NSString *)kCFErrorDomainCFNetwork] && (error.code == kCFHostErrorUnknown) ) {
        failureNum = error.userInfo[(id) kCFGetAddrInfoFailureKey];
        if ( [failureNum isKindOfClass:[NSNumber class]] ) {
            failure = failureNum.intValue;
            if (failure != 0) {
                failureStr = gai_strerror(failure);
                if (failureStr != NULL) {
                    result = @(failureStr);
                }
            }
        }
    }
    
    // Otherwise try various properties of the error object.
    
    if (result == nil) {
        result = error.localizedFailureReason;
    }
    if (result == nil) {
        result = error.localizedDescription;
    }
    assert(result != nil);
    return result;
}

// 获取当前时间戳
+ (NSString *)currentUnixTimeStr
{
    NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];//获取当前时间0秒后的时间
    NSTimeInterval time=[date timeIntervalSince1970] * 1000;// *1000 是精确到毫秒，不乘就是精确到秒
    NSString *timeString = [NSString stringWithFormat:@"%.0f", time];
    return timeString;
}

- (void)dealloc
{
    [self stop];
}


@end
