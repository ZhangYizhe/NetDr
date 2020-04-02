//
//  NetDrPingPacketData.h
//  NetDr
//
//  Created by 张艺哲 on 2020/4/1.
//  Copyright © 2020 com.elecoxy. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NetDrPingPacketData : NSObject

@property (nonatomic, assign) long long icmpSeq;

// IP地址
@property (nonatomic, copy) NSString * ip;

// 长度
@property (nonatomic, copy) NSString * size;

// timeToLive
@property (nonatomic, assign) NSInteger ttl;

// 发起时间
@property (nonatomic, copy) NSString * startUnixTime;

// 结束时间
@property (nonatomic, copy) NSString * overUnixTime;

// 是否成功
@property (nonatomic, assign) BOOL status;

// 错误描述
@property (nonatomic, copy) NSString * errorDescription;

@end

NS_ASSUME_NONNULL_END
