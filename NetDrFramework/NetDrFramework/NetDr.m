//
//  NetDr.m
//  NetDr
//
//  Created by 张艺哲 on 2020/4/1.
//  Copyright © 2020 com.elecoxy. All rights reserved.
//

#import "NetDr.h"
#import "NetDrBasic.h"
#import "NetDrPing.h"

@interface NetDr ()

@property (nonatomic, strong) NetDrPing * netDrPing;

@end

@implementation NetDr

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.netDrPing = [NetDrPing new];
    }
    return self;
}

// MARK: - 基础信息
- (NSDictionary *)netDrBasic_infoDict
{
    return [NetDrBasic getAllInfoDict];
}

// MARK: - Ping
/// 开始Ping
/// @param hostName 域名
/// @param count 请求次数 -1为无限
/// @param addressStyle 地址类型
- (void)netDrPing_startWithHostName: (NSString *)hostName count: (NSInteger)count addressStyle: (PingAddressStyle)addressStyle
{
    __weak typeof(self) weakSelf = self;
    
    // 开始Ping
    _netDrPing.startBlock = ^(NSString * _Nonnull hostName, NSString * _Nonnull ip) {
        if (weakSelf.delegate != nil && [weakSelf.delegate respondsToSelector:@selector(netDrPing_didStartWithHostName:ip:)]) {
            [weakSelf.delegate netDrPing_didStartWithHostName: hostName ip: ip];
        }
    };
    
    // 单包信息回调
    _netDrPing.singlePacketBlock = ^(NetDrPingPacketData * _Nonnull singlePackData) {
        if (weakSelf.delegate != nil && [weakSelf.delegate respondsToSelector:@selector(netDrPing_singlePacketWithStatus:size:ip:icmpSeq:time:)]) {
            [weakSelf.delegate netDrPing_singlePacketWithStatus: singlePackData.status size: singlePackData.size ip: singlePackData.ip icmpSeq:singlePackData.icmpSeq time: singlePackData.overUnixTime.integerValue - singlePackData.startUnixTime.integerValue];
        }
    };
    
    // 单包不匹配的ICMP消息回调
    _netDrPing.singleUnexpectedPacketBlock = ^(NSUInteger size) {
        if (weakSelf.delegate != nil && [weakSelf.delegate respondsToSelector:@selector(netDrPing_singleUnexpectedPacketWithSize:)]) {
            [weakSelf.delegate netDrPing_singleUnexpectedPacketWithSize: size];
        }
    };
    
    // 接收到错误结束Ping操作
    _netDrPing.errorEndBlock = ^(NSString * _Nonnull errorDescription) {
        if (weakSelf.delegate != nil && [weakSelf.delegate respondsToSelector:@selector(netDrPing_didEndWithError:)]) {
            [weakSelf.delegate netDrPing_didEndWithError: errorDescription];
        }
    };
    
    // 完成Ping操作
    _netDrPing.endBlock = ^(NSArray<NetDrPingPacketData *> * _Nonnull packetArr, NSInteger packetNum, long long packetReceivedNum, float packetLossPercentage) {
        if (weakSelf.delegate != nil && [weakSelf.delegate respondsToSelector:@selector(netDrPing_didEndWithPacketNum:packetReceivedNum:packetLossPercentage:)]) {
            [weakSelf.delegate netDrPing_didEndWithPacketNum:packetNum packetReceivedNum:(NSInteger)packetReceivedNum packetLossPercentage:packetLossPercentage * 100];
        }
    };
    
    switch (addressStyle) {
        case PingAddressStyleAny:
            [_netDrPing startWithHostName: hostName count: count];
            break;
        case PingAddressStyleStyleICMPv4:
            [_netDrPing startForceIPv4WithHostName: hostName count: count];
            break;
        case PingAddressStyleStyleICMPv6:
            [_netDrPing startForceIPv6WithHostName: hostName count: count];
            break;
    }
}

/// 结束Ping
- (void)netDrPing_end
{
    [_netDrPing stop];
}

@end
