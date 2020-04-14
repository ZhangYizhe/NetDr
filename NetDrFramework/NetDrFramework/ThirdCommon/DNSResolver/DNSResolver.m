//
//  DNSResolver.m
//  NetDr
//
//  Created by 张艺哲 on 2020/4/14.
//  Copyright © 2020 com.elecoxy. All rights reserved.
//

#import "DNSResolver.h"
#include <resolv.h>
#include <netdb.h>

@implementation DNSResolver {
    res_state _state;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _state = malloc(sizeof(struct __res_state));
        if (EXIT_SUCCESS != res_ninit(_state)) {
            free(_state);
            return nil;
        }
    }
    return self;
}

- (void)dealloc {
    res_ndestroy(_state);
    free(_state);
}

#pragma mark - Public

- (NSString *)getDNSAddressesCSV
{
    NSMutableArray *addresses = [NSMutableArray new];

    union res_sockaddr_union servers[NI_MAXSERV];

    int serversFound = res_9_getservers(_state, servers, NI_MAXSERV);

    char hostBuffer[NI_MAXHOST];
    for (int i = 0; i < serversFound; i ++) {
        union res_sockaddr_union s = servers[i];
        if (s.sin.sin_len > 0) {
            if (EXIT_SUCCESS == getnameinfo((struct sockaddr *)&s.sin,  // Pointer to your struct sockaddr
                                            (socklen_t)s.sin.sin_len,   // Size of this struct
                                            (char *)&hostBuffer,        // Pointer to hostname string
                                            sizeof(hostBuffer),         // Size of this string
                                            nil,                        // Pointer to service name string
                                            0,                          // Size of this string
                                            NI_NUMERICHOST)) {          // Flags given
                [addresses addObject:[NSString stringWithUTF8String:hostBuffer]];
            }
        }
    }

    return [addresses componentsJoinedByString:@","];
}


@end
