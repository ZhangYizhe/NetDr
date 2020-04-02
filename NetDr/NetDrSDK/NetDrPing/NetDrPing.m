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

// ping实例
@property (nonatomic, strong) SimplePing * pinger;

// 域名ip地址
@property (nonatomic, copy) NSString * ip;

// 包数组
@property (nonatomic, strong) NSMutableArray <NetDrPingPacketData *> * packetArr;

@end

@implementation NetDrPing

- (void)startWithHostName: (NSString *) hostName
{
    [self startWithHostName:hostName forceIPv4: NO forceIPv6: NO];
}

- (void)startWithHostName: (NSString *) hostName forceIPv6: (BOOL) forceIPv6
{
    [self startWithHostName:hostName forceIPv4: NO forceIPv6: forceIPv6];
}

- (void)startWithHostName: (NSString *) hostName forceIPv4: (BOOL) forceIPv4
{
    [self startWithHostName:hostName forceIPv4: forceIPv4 forceIPv6: NO];
}

- (void)startWithHostName: (NSString *) hostName forceIPv4: (BOOL) forceIPv4 forceIPv6: (BOOL) forceIPv6
{
    [self stop];
    
    _ip = @"";
    _packetArr = [NSMutableArray new];
    _pinger = [[SimplePing alloc] initWithHostName: hostName];
    
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
    [_pinger stop];
    _pinger = nil;
}

- (void)sendPing
{
    [_pinger sendPingWithData: nil];
}

// MARK: - SimplePing delegate callback
- (void)simplePing:(SimplePing *)pinger didStartWithAddress:(NSData *)address
{
    _ip = [NetDrPing displayAddressForAddress: address];
    [self sendPing];
}

- (void)simplePing:(SimplePing *)pinger didFailWithError:(NSError *)error
{
    NSLog(@"failed: %@", [NetDrPing shortErrorFromError: error]);
    
    [self stop];
}

- (void)simplePing:(SimplePing *)pinger didSendPacket:(NSData *)packet sequenceNumber:(uint16_t)sequenceNumber
{
    NetDrPingPacketData * packetData = [NetDrPingPacketData new];
    packetData.icmpSeq = sequenceNumber;
    packetData.ip = _ip;
    packetData.startUnixTime = [NetDrPing currentUnixTimeStr];
    packetData.status = NO;
    [_packetArr addObject: packetData];
}

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
    
    // 单个包结果返回
    if (_singlePacketBlock) _singlePacketBlock(packetData);
}

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
    // 单个包结果返回
    if (_singlePacketBlock) _singlePacketBlock(packetData);
}

// 不认识的包
- (void)simplePing:(SimplePing *)pinger didReceiveUnexpectedPacket:(NSData *)packet
{
//    NSLog(@"unexpected packet, size=%zu", packet.length);
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
