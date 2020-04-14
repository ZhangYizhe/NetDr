//
//  NetDrBasic.m
//  NetDr
//
//  Created by 张艺哲 on 2020/4/14.
//  Copyright © 2020 com.elecoxy. All rights reserved.
//

#import "NetDrBasic.h"
#import <sys/utsname.h>
#import "NetDr.h"
#import <UIKit/UIKit.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import "Reachability.h"
#import "DNSResolver.h"

@implementation NetDrBasic

/// 获取全部基础信息
+ (NSDictionary *)getAllInfoDict;
{
    NSMutableDictionary * infoDict = [NSMutableDictionary new];
    [infoDict setValue: [NetDrBasic getDeviceType] forKey: BasicInfoDictKeyDeviceType];
    [infoDict setValue: [NetDrBasic getSystemVersion] forKey: BasicInfoDictKeySystemVersion];
    [infoDict setValue: [NetDrBasic getCarrierName] forKey: BasicInfoDictKeyCarrierName];
    [infoDict setValue: [NetDrBasic getCurrentNetworkType] forKey: BasicInfoDictKeyCurrentNetworkType];
    [infoDict setValue: [NetDrBasic getPublicIPAddress] forKey: BasicInfoDictKeyPublicIPAddress];
    [infoDict setValue: [NetDrBasic getLocalDNSAddress] forKey: BasicInfoDictKeyLocalDNSAddress];
    
    return infoDict;
}

// 获取设备类型
+ (NSString *)getDeviceType
{
    struct utsname systemInfo;
    uname(&systemInfo);

    return [NSString stringWithCString:systemInfo.machine
                              encoding:NSUTF8StringEncoding];
}

// 获取系统版本
+ (NSString *)getSystemVersion
{
    return [[UIDevice currentDevice] systemVersion];
}

// 获取运营商名称
+ (NSArray *)getCarrierName
{
    CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
    __block NSMutableArray *operatorNameArr = [NSMutableArray new];
    //iOS12以上可使用
    if (@available(iOS 12.0, *)) {
        NSDictionary *carrierDic = [info serviceSubscriberCellularProviders];
        
        [carrierDic.allValues enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            CTCarrier *carrier = obj;
            //NSLog(@"carrier = %@", carrier);
            NSString *code = [carrier mobileNetworkCode];
            if (code == nil) {
                [operatorNameArr addObject: @"None"];
            } else if ([code isEqualToString:@"00"] || [code isEqualToString:@"02"] || [code isEqualToString:@"04"] || [code isEqualToString:@"07"] || [code isEqualToString:@"08"]) {
                [operatorNameArr addObject: @"China Mobile"];
            } else if ([code isEqualToString:@"01"] || [code isEqualToString:@"06"] || [code isEqualToString:@"09"]) {
                [operatorNameArr addObject: @"China Unicom"];
            } else if ([code isEqualToString:@"03"] || [code isEqualToString:@"05"] || [code isEqualToString:@"11"]) {
                [operatorNameArr addObject: @"China Telecom"];
            } else if ([code isEqualToString:@"20"]) {
                [operatorNameArr addObject: @"China Railcom"];
            }
            
        }];
    } else {
        CTCarrier *carrier = [info subscriberCellularProvider];
        NSString *currentCountryCode = [carrier mobileCountryCode];
        NSString *mobileNetWorkCode = [carrier mobileNetworkCode];
        
        if (![currentCountryCode isEqualToString:@"460"]) {
            [operatorNameArr addObject: @"None"];
        } else if ([mobileNetWorkCode isEqualToString:@"00"] || [mobileNetWorkCode isEqualToString:@"02"] || [mobileNetWorkCode isEqualToString:@"04"] || [mobileNetWorkCode isEqualToString:@"07"] || [mobileNetWorkCode isEqualToString:@"08"]) {
            [operatorNameArr addObject: @"China Mobile"];
        } else if ([mobileNetWorkCode isEqualToString:@"01"] || [mobileNetWorkCode isEqualToString:@"06"] || [mobileNetWorkCode isEqualToString:@"09"]) {
            [operatorNameArr addObject: @"China Unicom"];
        } else if ([mobileNetWorkCode isEqualToString:@"03"] || [mobileNetWorkCode isEqualToString:@"05"] || [mobileNetWorkCode isEqualToString:@"11"]) {
            [operatorNameArr addObject: @"China Telecom"];
        } else if ([mobileNetWorkCode isEqualToString:@"20"]) {
            [operatorNameArr addObject: @"China Railcom"];
        }
    }
    
    return operatorNameArr;
}

// 获取当前网络类型
+ (NSArray *)getCurrentNetworkType
{
    __block NSMutableArray *netconnTypeArr = [NSMutableArray new];

    Reachability *reach = [Reachability reachabilityWithHostName:@"www.apple.com"];

    switch ([reach currentReachabilityStatus]) {
        case NotReachable:// 没有网络
        {
            [netconnTypeArr addObject: @"no network"];
        }
            break;

        case ReachableViaWiFi:// Wifi
        {
            [netconnTypeArr addObject: @"Wi-Fi"];
        }
            break;

        case ReachableViaWWAN:// 手机自带网络
        {
            // 获取手机网络类型
            CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];

            [info.serviceCurrentRadioAccessTechnology.allValues enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSString * currentStatus = obj;
                if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyGPRS"]) {
                    [netconnTypeArr addObject: @"GPRS"];
                }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyEdge"]) {
                    [netconnTypeArr addObject: @"2.75G EDGE"];
                }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyWCDMA"]){
                    [netconnTypeArr addObject: @"3G"];
                }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyHSDPA"]){
                    [netconnTypeArr addObject: @"3.5G HSDPA"];
                }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyHSUPA"]){
                    [netconnTypeArr addObject: @"3.5G HSUPA"];
                }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyCDMA1x"]){
                    [netconnTypeArr addObject: @"2G"];
                }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyCDMAEVDORev0"]){
                    [netconnTypeArr addObject: @"3G"];
                }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyCDMAEVDORevA"]){
                    [netconnTypeArr addObject: @"3G"];
                }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyCDMAEVDORevB"]){
                    [netconnTypeArr addObject: @"3G"];
                }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyeHRPD"]){
                    [netconnTypeArr addObject: @"HRPD"];
                }else if ([currentStatus isEqualToString:@"CTRadioAccessTechnologyLTE"]){
                    [netconnTypeArr addObject: @"4G"];
                }
            }];
        }
            break;

        default:
            break;
    }

    return netconnTypeArr;
}

// 获取当前IP地址
+ (NSString *)getPublicIPAddress
{
    NSError *error;
    NSURL *ipURL = [NSURL URLWithString:@"http://api.ipify.org"];
    NSString *ip = [NSString stringWithContentsOfURL:ipURL encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        return @"None";
    }
    return ip;
}


// 获取本地DNS地址
+ (NSString *)getLocalDNSAddress
{
    DNSResolver * resolver = [DNSResolver new];
    return [resolver getDNSAddressesCSV];
}


@end
