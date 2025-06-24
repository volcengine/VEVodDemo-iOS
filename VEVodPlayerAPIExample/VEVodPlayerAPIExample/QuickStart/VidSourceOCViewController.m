// Copyright (c) 2025 Beijing Volcano Engine Technology Co., Ltd.
// SPDX-License-Identifier: MIT
//
//  VidSourceExampleViewController.m
//  VEVodPlayerAPIExample
//
//  Created by ByteDance on 2025/5/27.
//

#import "VidSourceOCViewController.h"
#import "VEAPIVideoModel.h"
#import "VEAPIMediaSource.h"
#import <TTSDKFramework/TTSDKFramework.h>
#import <Masonry/Masonry.h>

@interface VidSourceOCViewController () <UIPickerViewDelegate, UIPickerViewDataSource, TTVideoEngineDelegate>

@property (nonatomic, strong) TTVideoEngine *engine;
@property (nonatomic, strong) NSArray <NSString *> *options;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, assign) BOOL needToResume;

@end

@implementation VidSourceOCViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"VEVodPlayerAPIExample - VidSourceOCViewController");
    self.view.backgroundColor = [UIColor whiteColor];
    self.engine.delegate = self;
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
    CGFloat topOffset = UIApplication.sharedApplication.statusBarFrame.size.height + self.navigationController.navigationBar.bounds.size.height;
    // 初始化播放器实例并以属性持有
    self.engine = [[TTVideoEngine alloc] initWithOwnPlayer:YES];
    // playerView 是播放器的显示视图，需要被添加业务父视图中并设置 playerView 的 frame
    [self.view addSubview:self.engine.playerView];
    [self.engine.playerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(topOffset);
        make.left.right.equalTo(self.view);
        make.height.equalTo(self.view).multipliedBy(0.8);
    }];
    // 开启优化前后台切换卡顿开关
     [self.engine setOptionForKey:VEKKeyIsDecodeMalFunctionErrorIgnore value:@(1)];
    // 开启优化前后台切换跳帧开关
     [self.engine setOptionForKey:VEKKeyPlayerIsIgnoreTestSizeOnPause value:@(1)];
    // 设置 vid 播放源,需要同时设置 vid 和 playAuthToken
    NSString *vid = [VEAPIVideoModel defaultVideoModel][1].vid;
    NSString *playAuthToken = [VEAPIVideoModel defaultVideoModel][1].playAuthToken;
    // 起播分辨率
    TTVideoEngineResolutionType resolution = TTVideoEngineResolutionTypeFullHD;
    TTVideoEngineVidSource *urlSource = [VEAPIMediaSource initVidSource:vid playAuthToken:playAuthToken resolution:resolution];
    [self.engine setVideoEngineVideoSource:urlSource];
    self.engine.delegate = self;
    [self.engine play];
    
    UILabel *label = [[UILabel alloc] init];
    label.text = NSLocalizedString(@"set_resolution", NULL);
    [self.view addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.engine.playerView.mas_bottom).offset(5);
        make.left.equalTo(self.view).offset(5);
        make.width.mas_equalTo(110);
        make.height.mas_equalTo(40);
    }];
    
    TTVideoEngineResolutionType currentType = self.engine.currentResolution;
    self.options = @[@"SD", @"HD", @"FullHD", @"HD_H"];
    self.textField = [[UITextField alloc] init];
    self.textField.borderStyle = UITextBorderStyleRoundedRect;
    switch (currentType) {
        case TTVideoEngineResolutionTypeSD:
            self.textField.placeholder = @"SD";
            break;
        case TTVideoEngineResolutionTypeHD:
            self.textField.placeholder = @"HD";
            break;
        case TTVideoEngineResolutionTypeFullHD:
            self.textField.placeholder = @"FullHD";
            break;
        case TTVideoEngineResolutionTypeHD_H:
            self.textField.placeholder = @"HD_H";
            break;
        default:
            break;
    }
    [self.view addSubview:self.textField];
    [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.engine.playerView.mas_bottom);
        make.left.equalTo(label.mas_right);
        make.width.mas_equalTo(150);
        make.height.mas_equalTo(40);
    }];
        
    UIPickerView *picker = [[UIPickerView alloc] init];
    picker.delegate = self;
    picker.dataSource = self;
    self.textField.inputView = picker;
}

- (void)handleResignActive:(NSNotification *)notification {
    NSLog(@"VEVodPlayerAPIExample - applicationWillResignActive from VidSourceOCViewController");
    // 即将进入后台时，若视频正在播放，则需要暂停
    if (self.engine.playbackState == TTVideoEnginePlaybackStatePlaying) {
        [self.engine pause];
        self.needToResume = YES;
    }else {
        self.needToResume = NO;
    }
}

- (void)handleBecomeActive:(NSNotification *)notification {
    NSLog(@"VEVodPlayerAPIExample - applicationDidBecomeActive in VidSourceOCViewController");
    // 从后台回复后，若视频之前是播放状态，则需要恢复播放
    if (self.needToResume) {
        [self.engine play];
    }
}

#pragma mark - TTVideoEngineDelegate
- (void)videoEngine:(TTVideoEngine *)videoEngine fetchedVideoModel:(TTVideoEngineModel *)videoModel {
    // 获取视频点播服务下发的清晰度数组，可用于清晰度列表展示
    NSArray<NSNumber *> *allResolutions = [self.engine supportedResolutionTypes];
    NSLog(@"VEVodPlayerAPIExample - (in delegate) support resolutions are:%@", allResolutions);
}

#pragma mark - UIPickerView 代理方法
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.options.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return self.options[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.textField.text = self.options[row];
    [self.textField resignFirstResponder];
    TTVideoEngineResolutionType type;
    switch (row) {
        case 0:
            type = TTVideoEngineResolutionTypeSD;
            break;
        case 1:
            type = TTVideoEngineResolutionTypeHD;
            break;
        case 2:
            type = TTVideoEngineResolutionTypeFullHD;
            break;
        case 3:
            type = TTVideoEngineResolutionTypeHD_H;
            break;
        default:
            type = TTVideoEngineResolutionTypeSD;
            break;
    }
    // 切换视频清晰度
    [self.engine configResolution:type withCompletion:^(BOOL success, NSError * _Nullable err, TTVideoEngineResolutionType completeResolution) {
        if (success) {
            NSLog(@"VEVodPlayerAPIExample - resolution switch successfully to %@", @(completeResolution));
        } else {
            // NSError 的 code 中包含了具体的错误码，具体含义参考官网文档
            // 特别情况：分辨率切换因播放器状态异常导致未成功执行时，错误码为 -1
            // 回调可能在非 UI 线程触发，因此请勿在回调中直接执行涉及 UI 的操作。建议将 UI 操作放到 UI 线程中执行。
            NSLog(@"VEVodPlayerAPIExample - resolution switch to %@ failed with code：%ld", @(completeResolution), err.code);
        }
    }];
}

@end
