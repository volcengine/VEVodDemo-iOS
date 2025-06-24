// Copyright (c) 2025 Beijing Volcano Engine Technology Co., Ltd.
// SPDX-License-Identifier: MIT
//
//  DirectUrlSourceExampleViewController.m
//  VEVodPlayerAPIExample
//
//  Created by ByteDance on 2025/5/27.
//

#import "DirectUrlSourceOCViewController.h"
#import "VEAPIVideoModel.h"
#import "VEAPIMediaSource.h"
#import <TTSDKFramework/TTSDKFramework.h>
#import <Masonry/Masonry.h>

@interface DirectUrlSourceOCViewController ()

@property (nonatomic, strong) TTVideoEngine *engine;
@property (nonatomic, assign) BOOL needToResume;

@end

@implementation DirectUrlSourceOCViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"VEVodPlayerAPIExample - DirectUrlSourceOCViewController");
    self.view.backgroundColor = [UIColor whiteColor];
    [self constructViews];
    // 注册通知监听，进入后台以及从后台恢复时，手动管理一下播放器状态
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    // 移除视图
    [self.engine.playerView removeFromSuperview];
    // 停止播放，销毁 engine 实例，engine 实例不能再次被使用。
    [self.engine closeAysnc];
    self.engine = nil;
    [super viewWillDisappear:animated];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)constructViews {
    // 初始化播放器实例并以属性持有
    self.engine = [[TTVideoEngine alloc] initWithOwnPlayer:YES];
    // playerView 是播放器的显示视图，需要被添加业务父视图中并设置 playerView 的 frame
    [self.view addSubview:self.engine.playerView];
    [self.engine.playerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    // 开启优化前后台切换卡顿开关
     [self.engine setOptionForKey:VEKKeyIsDecodeMalFunctionErrorIgnore value:@(1)];
    // 开启优化前后台切换跳帧开关
     [self.engine setOptionForKey:VEKKeyPlayerIsIgnoreTestSizeOnPause value:@(1)];
    // 设置 directUrl 播放源
    NSString *videoUrl = [VEAPIVideoModel defaultVideoModel][0].videoUrl;
    TTVideoEngineUrlSource *urlSource = [VEAPIMediaSource initDirectUrlSource:videoUrl];
    [self.engine setVideoEngineVideoSource:urlSource];
    [self.engine play];
}

- (void)handleResignActive:(NSNotification *)notification {
    NSLog(@"VEVodPlayerAPIExample - applicationWillResignActive from DirectUrlSourceOCViewController");
    // 即将进入后台时，若视频正在播放，则需要暂停
    if (self.engine.playbackState == TTVideoEnginePlaybackStatePlaying) {
        [self.engine pause];
        self.needToResume = YES;
    }else {
        self.needToResume = NO;
    }
}

- (void)handleBecomeActive:(NSNotification *)notification {
    NSLog(@"VEVodPlayerAPIExample - applicationDidBecomeActive in DirectUrlSourceOCViewController");
    // 从后台回复后，若视频之前是播放状态，则需要恢复播放
    if (self.needToResume) {
        [self.engine play];
    }
}

@end
