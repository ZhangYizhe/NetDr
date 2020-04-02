//
//  NetDrPing.h
//  NetDr
//
//  Created by 张艺哲 on 2020/4/1.
//  Copyright © 2020 com.elecoxy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NetDrPingPacketData.h"

NS_ASSUME_NONNULL_BEGIN

@interface NetDrPing : NSObject

// 开始Ping
@property (nonatomic, copy) void(^startBlock)(NSString * url, NSString * ip);

// 结束Ping操作
/// @param packetArr 包信息集合
/// @param packetNum 包数量
/// @param packetReceivedNum 包成功数量
/// @param packetLossPercentage 包失败比率
@property (nonatomic, copy) void(^endBlock)(NSArray <NetDrPingPacketData *> * packetArr, NSInteger packetNum, NSInteger packetReceivedNum, float packetLossPercentage);

// 单包信息回调
@property (nonatomic, copy) void(^singlePacketBlock)(NetDrPingPacketData *);

/// 使用IPv4/IPv6来请求
/// @param hostName 域名
/// @param count 请求次数  -1 -> 不限次数
- (void)startWithHostName: (NSString *) hostName count: (NSInteger) count;

/// 使用IPv6来请求
/// @param hostName 域名
/// @param count 请求次数  -1 -> 不限次数
- (void)startForceIPv6WithHostName: (NSString *) hostName count: (NSInteger) count;

/// 使用IPv4来请求
/// @param hostName 域名
/// @param count 请求次数  -1 -> 不限次数
- (void)startForceIPv4WithHostName: (NSString *) hostName count: (NSInteger) count;

- (void)stop;

@end

NS_ASSUME_NONNULL_END
