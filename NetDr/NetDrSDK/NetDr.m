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

- (void)netDrPing_startWithHostName: (NSString *) hostName
{
    _netDrPing.singlePacketBlock = ^(NetDrPingPacketData * _Nonnull singlePackData) {
        NSLog(@"%@ bytes from %@: icmp_seq=%lld ttl=52 time=%zd ms", singlePackData.size, singlePackData.ip, singlePackData.icmpSeq, singlePackData.overUnixTime.integerValue - singlePackData.startUnixTime.integerValue);
    };
    [_netDrPing startWithHostName: hostName];
}

@end
