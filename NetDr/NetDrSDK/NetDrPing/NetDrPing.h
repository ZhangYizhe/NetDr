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

@property (nonatomic, copy) void(^singlePacketBlock)(NetDrPingPacketData *);

- (void)startWithHostName: (NSString *) hostName;

- (void)startWithHostName: (NSString *) hostName forceIPv6: (BOOL) forceIPv6;

- (void)startWithHostName: (NSString *) hostName forceIPv4: (BOOL) forceIPv4;

- (void)stop;

@end

NS_ASSUME_NONNULL_END
