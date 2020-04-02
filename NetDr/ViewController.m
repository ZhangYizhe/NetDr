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

@property (nonatomic, strong) UITextView * textView;

@property (nonatomic, strong) NetDr * netDr;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    
    [self ping];
    
}

- (void)initView
{
    _textView = [UITextView new];
    _textView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [self.view addSubview: _textView];
    
    
}


- (void)ping
{
    _netDr = [NetDr new];
    [_netDr netDrPing_startWithHostName: @"v2ex.com" count: 10];
}


@end
