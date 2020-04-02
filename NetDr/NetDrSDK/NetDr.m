//
//  NetDr.m
//  NetDr
//
//  Created by 张艺哲 on 2020/4/1.
//  Copyright © 2020 com.elecoxy. All rights reserved.
//

#import "NetDr.h"
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

- (void)netDrPing_startWithHostName: (NSString *) hostName count: (NSInteger) count
{
    _netDrPing.startBlock = ^(NSString * _Nonnull url, NSString * _Nonnull ip) {
        NSLog(@"PING %@ (%@):", url, ip);
    };
    
    _netDrPing.singlePacketBlock = ^(NetDrPingPacketData * _Nonnull singlePackData) {
        if (singlePackData.status) {
            NSLog(@"%@ bytes from %@: icmp_seq=%lld ttl=52 time=%zd ms", singlePackData.size, singlePackData.ip, singlePackData.icmpSeq, singlePackData.overUnixTime.integerValue - singlePackData.startUnixTime.integerValue);
        } else {
            NSLog(@"Request timeout for icmp_seq %lld", singlePackData.icmpSeq);
        }
        
    };
    
    _netDrPing.endBlock = ^(NSArray<NetDrPingPacketData *> * _Nonnull packetArr, NSInteger packetNum, NSInteger packetReceivedNum, float packetLossPercentage) {
        
        NSLog(@"%zd packets transmitted, %zd packets received, %.2f%% packet loss", packetNum, packetReceivedNum, packetLossPercentage * 100);
        
    };
    
    [_netDrPing startWithHostName: hostName count: count];
}

@end
