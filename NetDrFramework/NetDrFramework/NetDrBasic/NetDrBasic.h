//
//  NetDrBasic.h
//  NetDr
//
//  Created by 张艺哲 on 2020/4/14.
//  Copyright © 2020 com.elecoxy. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NetDrBasic : NSObject

/// 获取全部基础信息
+ (NSDictionary *)getAllInfoDict;

// 获取设备类型
+ (NSString *)getDeviceType;

// 获取系统版本
+ (NSString *)getSystemVersion;

// 获取运营商名称
+ (NSArray *)getCarrierName;

// 获取当前网络类型
+ (NSArray *)getCurrentNetworkType;

// 获取当前IP地址
+ (NSString *)getPublicIPAddress;

// 获取本地DNS地址
+ (NSString *)getLocalDNSAddress;

@end

NS_ASSUME_NONNULL_END
