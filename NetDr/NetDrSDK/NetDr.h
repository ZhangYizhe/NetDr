//
//  NetDr.h
//  NetDr
//
//  Created by 张艺哲 on 2020/4/1.
//  Copyright © 2020 com.elecoxy. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NetDr : NSObject

- (void)netDrPing_startWithHostName: (NSString *) hostName;

@end

NS_ASSUME_NONNULL_END
