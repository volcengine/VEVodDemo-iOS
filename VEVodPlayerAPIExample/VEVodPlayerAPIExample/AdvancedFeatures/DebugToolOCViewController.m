// Copyright (c) 2025 Beijing Volcano Engine Technology Co., Ltd.
// SPDX-License-Identifier: MIT
//
//  DebugToolOCViewController.m
//  VEVodPlayerAPIExample
//
//  Created by ByteDance on 2025/6/4.
//

#import "DebugToolOCViewController.h"
#import "VidSourceOCViewController.h"
#import <Masonry/Masonry.h>
// 1. 导入头文件
#import "TTSDKFramework/TTVideoEngine+DebugTool.h"

@interface DebugToolOCViewController ()

@end

@implementation DebugToolOCViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"VEVodPlayerAPIExample - DebugToolOCViewController");
    self.view.backgroundColor = [UIColor whiteColor];
    VidSourceOCViewController *vc = [[VidSourceOCViewController alloc] init];
    [self addChildViewController:vc];
    vc.view.frame = self.view.bounds;
    [self.view addSubview:vc.view];
    [vc didMoveToParentViewController:self];
    [self showDebugTool];
    if ([TTVideoEngine debugToolIsShowing]) {
        NSLog(@"VEVodPlayerAPIExample - debugTool is showing");
    }else {
        NSLog(@"VEVodPlayerAPIExample - debugTool is not showing");
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [self removeDebugTool];
    [super viewWillDisappear:animated];
}

// 添加展示 debug 工具
- (void)showDebugTool {
// 强烈建议只在 Debug 模式下添加 debug 工具
    CGFloat topCap = 70;
    CGFloat width = CGRectGetWidth(self.view.bounds);
    CGFloat height = CGRectGetHeight(self.view.bounds) - 100;
    [TTVideoEngine showDebugTool:self.view inRect:CGRectMake(0, topCap, width, height)];
}

// 不使用时，移除 debug 工具
- (void)removeDebugTool {
    [TTVideoEngine removeDebugTool];
}

@end
