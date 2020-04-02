//
//  ViewController.m
//  NetDr
//
//  Created by 张艺哲 on 2020/4/1.
//  Copyright © 2020 com.elecoxy. All rights reserved.
//

#import "ViewController.h"
#import "NetDr.h"

@interface ViewController ()

@property (nonatomic, strong) NetDr * netDr;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _netDr = [NetDr new];
    
    [_netDr netDrPing_startWithHostName: @"baidu.com"];
}


@end
