//
//  ViewController.m
//  NetDr
//
//  Created by 张艺哲 on 2020/4/1.
//  Copyright © 2020 com.elecoxy. All rights reserved.
//

#import "ViewController.h"
#import "NetDr.h"

@interface ViewController () <NetDrDelegate>

@property (nonatomic, strong) UITextView * textView;

@property (nonatomic, strong) NetDr * netDr;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    
    // 初始化
    _netDr = [NetDr new];
    _netDr.delegate = self;
    
    [self ping];
    
}

- (void)initView
{
    _textView = [UITextView new];
    _textView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [self.view addSubview: _textView];
    
    
}

- (void)basicInfo
{
    NSDictionary * basicInfoDict = [_netDr netDrBasic_infoDict];
    NSLog(@"device-type: %@", basicInfoDict[BasicInfoDictKeyDeviceType]);
    NSLog(@"system-version: %@", basicInfoDict[BasicInfoDictKeySystemVersion]);
    NSLog(@"carrier-name: %@", basicInfoDict[BasicInfoDictKeyCarrierName]);
    NSLog(@"current-network-type: %@", basicInfoDict[BasicInfoDictKeyCurrentNetworkType]);
    NSLog(@"public-IP-address: %@", basicInfoDict[BasicInfoDictKeyPublicIPAddress]);
    NSLog(@"dns-IP-address: %@", basicInfoDict[BasicInfoDictKeyLocalDNSAddress]);
    
}

- (void)ping
{
    _netDr = [NetDr new];
    _netDr.delegate = self;
    [_netDr netDrPing_startWithHostName: @"baidu.com" count:3 addressStyle: PingAddressStyleAny];
}

// MARK: - NetDr Delegate

- (void)netDrPing_didStartWithHostName:(NSString *)hostName ip:(NSString *)ip
{
    NSLog(@"PING %@ (%@):", hostName, ip);
}

- (void)netDrPing_singlePacketWithStatus:(BOOL)status size:(NSString *)size ip:(NSString *)ip icmpSeq:(long long)icmpSeq time:(NSInteger)time
{
    if (status) {
        NSLog(@"%@ bytes from %@: icmp_seq=%lld ttl=52 time=%zd ms", size, ip, icmpSeq, time);
    } else {
        NSLog(@"Request timeout for icmp_seq %lld", icmpSeq);
    }
}

- (void)netDrPing_singleUnexpectedPacketWithSize:(NSUInteger)size
{
    NSLog(@"unexpected packet, size=%zu", size);
}

- (void)netDrPing_didEndWithError:(NSString *)errorDescription
{
    NSLog(@"failed: %@", errorDescription);
}

- (void)netDrPing_didEndWithPacketNum:(NSInteger)packetNum packetReceivedNum:(NSInteger)packetReceivedNum packetLossPercentage:(float)packetLossPercentage
{
    NSLog(@"%zd packets transmitted, %zd packets received, %.2f%% packet loss", packetNum, packetReceivedNum, packetLossPercentage * 100);
    
    [_netDr netDrPing_startWithHostName: @"baidu.com" count:3 addressStyle: PingAddressStyleAny];
}


@end
