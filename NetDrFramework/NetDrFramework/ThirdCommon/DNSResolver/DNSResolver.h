//
//  DNSResolver.h
//  NetDr
//
//  Created by 张艺哲 on 2020/4/14.
//  Copyright © 2020 com.elecoxy. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DNSResolver : NSObject

- (NSString *)getDNSAddressesCSV;

@end

NS_ASSUME_NONNULL_END
