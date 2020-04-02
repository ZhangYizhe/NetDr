//
//  NetDr.h
//  NetDr
//
//  Created by 张艺哲 on 2020/4/1.
//  Copyright © 2020 com.elecoxy. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol NetDrDelegate;

typedef NS_ENUM(NSInteger, PingAddressStyle) {
    PingAddressStyleAny,               /// 使用IPv4 / IPv6 Ping操作
    PingAddressStyleStyleICMPv4,       /// 使用IPv4 Ping操作
    PingAddressStyleStyleICMPv6        /// 使用IPv6 Ping操作
};

@interface NetDr : NSObject

@property (nonatomic, weak, readwrite, nullable) id<NetDrDelegate> delegate;

// MARK: Ping
/// 开始Ping
/// @param hostName 域名
/// @param count 请求次数 -1为无限
/// @param addressStyle 地址类型
- (void)netDrPing_startWithHostName: (NSString *)hostName count: (NSInteger)count addressStyle: (PingAddressStyle)addressStyle;

/// 结束Ping
- (void)netDrPing_end;

@end

@protocol NetDrDelegate <NSObject>

@optional

/// 接收到开始Ping回调
/// @param hostName 当前域名
/// @param ip 当前ip地址
- (void)netDrPing_didStartWithHostName: (NSString *)hostName ip: (NSString *)ip;

/// 接收到Ping包
/// @param status 状态 成功 / 失败
/// @param size 包大小
/// @param ip ip地址
/// @param icmpSeq icmp_seq
/// @param time 耗时
- (void)netDrPing_singlePacketWithStatus: (BOOL)status size: (NSString *)size ip: (NSString *)ip icmpSeq: (long long)icmpSeq time: (NSInteger)time;

/// 接收到不匹配的ICMP消息
/// @param size 包大小
- (void)netDrPing_singleUnexpectedPacketWithSize: (NSUInteger)size;

/// 由于发生错误终止Ping
/// @param errorDescription 错误描述
- (void)netDrPing_didEndWithError: (NSString *)errorDescription;

/// 正常完成Ping
/// @param packetNum 包数量
/// @param packetReceivedNum 成功返回包数量
/// @param packetLossPercentage 丢失包数量
- (void)netDrPing_didEndWithPacketNum: (NSInteger)packetNum packetReceivedNum: (NSInteger)packetReceivedNum packetLossPercentage: (float)packetLossPercentage;

@end

NS_ASSUME_NONNULL_END
