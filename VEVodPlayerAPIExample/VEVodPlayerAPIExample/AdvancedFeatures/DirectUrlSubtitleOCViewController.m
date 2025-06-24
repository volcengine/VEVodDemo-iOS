// Copyright (c) 2025 Beijing Volcano Engine Technology Co., Ltd.
// SPDX-License-Identifier: MIT
//
//  DirectUrlSubtitleOCViewController.m
//  VEVodPlayerAPIExample
//
//  Created by ByteDance on 2025/5/29.
//

#import "DirectUrlSubtitleOCViewController.h"
#import "VEAPIVideoModel.h"
#import "VEAPIButton.h"
#import "VEAPIMediaSource.h"
#import <TTSDKFramework/TTSDKFramework.h>
#import <Masonry/Masonry.h>

@interface DirectUrlSubtitleOCViewController () <TTVideoEngineSubDecInfoProtocol, TTVideoEngineSubtitleDelegate>

@property (nonatomic, strong) TTVideoEngine *engine;
@property (nonatomic, strong) UILabel *subtitleLabel;
@property (nonatomic, assign) NSInteger buttonNum;
@property (nonatomic, strong) TTVideoEngineSubDecInfoModel *subtitleInfoModel;

@end

@implementation DirectUrlSubtitleOCViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"VEVodPlayerAPIExample - DirectUrlSubtitleOCViewController");
    self.view.backgroundColor = [UIColor whiteColor];
    [self getSubtitleInfoModel];
    [self initPlayerForSubtitle];
    [self constructViews];
    [self.engine play];
}

- (void)viewDidDisappear:(BOOL)animated {
    // 移除视图
    [self.engine.playerView removeFromSuperview];
    // 停止播放，销毁 engine 实例，engine 实例不能再次被使用。
    [self.engine closeAysnc];
    self.engine = nil;
    [super viewWillDisappear:animated];
}

- (void)initPlayerForSubtitle {
    self.engine = [[TTVideoEngine alloc] initWithOwnPlayer:YES];
    // 如果需要字幕预加载，可通过 TTVideoEngineUrlSource 提前设置，详细可参考官方文档
    // NSInteger subtitleDefaultId = [[VEAPIVideoModel defaultSubtitleSubIDs][4][@"cmn-Hans-CN"] integerValue];
    // urlSource.subtitleId = subtitleDefaultId;
    // urlSource.subtitleInfoModel = [self getSubtitleInfoModelById];
    
    // 外挂字幕功能总开关，建议在设置 vid 之前调用
    [self.engine setOptionForKey:VEKeyPlayerEnableSubThread_BOOL value:@(YES)];
    // 外挂字幕加载优化开关
    // NO: 关闭外挂字幕加载优化；YES: 开启外挂字幕加载优化
    [self.engine setOptionForKey:VEKKeyPlayerSubtitleOptEnable_BOOL value:@(YES)];
    // 使用数据加载模块 MDL 加载外挂字幕，提升加载成功率
    // YES: 使用 MDL 加载外挂字幕
    // NO: 不使用 MDL 加载外挂字幕
    [self.engine setOptionForKey:VEKKeySubTitleEnableMDL_BOOL value:@(YES)];
    // 展示字幕，推荐在播放前先开启一次，也支持在播放中设置，YES: 输出字幕；NO: 停止输出字幕
    [self.engine setOptionForKey:VEKKeyPlayerSubEnabled_BOOL value:@(YES)];
    
    // 设置 DirectURL 模式下的字幕源
    [self.engine setSubDecInfoModel:self.subtitleInfoModel];

    // 设置字幕回调
    [self.engine setSubtitleDelegate:self];
    
    // 设置 directUrl 播放源
    NSString *videoUrl = [VEAPIVideoModel defaultVideoModel][4].videoUrl;
    TTVideoEngineUrlSource *urlSource = [VEAPIMediaSource initDirectUrlSource:videoUrl];
    [self.engine setVideoEngineVideoSource:urlSource];
}

- (void)constructViews {
    CGFloat topOffset = UIApplication.sharedApplication.statusBarFrame.size.height + self.navigationController.navigationBar.bounds.size.height;
    [self.view addSubview:self.engine.playerView];
    [self.engine.playerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(topOffset);
        make.left.width.equalTo(self.view);
        make.height.equalTo(self.view.mas_width);
    }];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    self.engine.playerView.userInteractionEnabled = YES;
    [self.engine.playerView addGestureRecognizer:tapGesture];
    
    UILabel *subLabel = [[UILabel alloc] init];
    subLabel.text = NSLocalizedString(@"show_subtitle_label", NULL);
    [self.view addSubview:subLabel];
    [subLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.engine.playerView.mas_bottom).offset(3);
        make.left.equalTo(self.view).offset(5);
        make.width.mas_equalTo(300);
        make.height.mas_equalTo(30);
    }];
    [self.view addSubview:self.subtitleLabel];
    [self.subtitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(subLabel.mas_bottom).offset(3);
        make.width.equalTo(self.view).multipliedBy(0.8);
        make.height.mas_equalTo(50);
    }];
    
    UILabel *controlLabel = [[UILabel alloc] init];
    controlLabel.text = NSLocalizedString(@"control_subtitle_label", NULL);
    [self.view addSubview:controlLabel];
    [controlLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.subtitleLabel.mas_bottom).offset(3);
        make.left.equalTo(self.view).offset(5);
        make.width.mas_equalTo(300);
        make.height.mas_equalTo(30);
    }];
    NSArray *subtitleButtons = @[NSLocalizedString(@"start_subtitle", NULL), NSLocalizedString(@"end_subtitle", NULL), NSLocalizedString(@"chinese_label", NULL), NSLocalizedString(@"english_label", NULL)];
    [self constructButtons:subtitleButtons Width:80 BelowLabel:controlLabel];
}

- (void)constructButtons:(NSArray <NSString *> *)titles Width:(NSInteger)width BelowLabel:(UILabel *)label {
    for (int i = 0; i < titles.count; ++i) {
        VEAPIButton *button = [[VEAPIButton alloc] initWithTitle:titles[i]];
        [self.view addSubview:button];
        button.tag = self.buttonNum;
        self.buttonNum += 1;
        [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(label.mas_bottom).offset(3);
            make.left.equalTo(self.view).offset((width + 5) * i + 3);
            make.width.mas_equalTo(width);
            make.height.mas_equalTo(35);
        }];
    }
}

- (UILabel *)subtitleLabel {
    if (_subtitleLabel == NULL) {
        _subtitleLabel = [[UILabel alloc] init];
        _subtitleLabel.textColor = [UIColor whiteColor];
        _subtitleLabel.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        _subtitleLabel.textAlignment = NSTextAlignmentCenter;
        _subtitleLabel.numberOfLines = 0;
        _subtitleLabel.font = [UIFont systemFontOfSize:20 weight:UIFontWeightMedium];
        _subtitleLabel.layer.cornerRadius = 4;
        _subtitleLabel.clipsToBounds = YES;
    }
    return _subtitleLabel;
}

- (void)handleTap:(UITapGestureRecognizer *)gesture {
    if (self.engine.playbackState != TTVideoEnginePlaybackStatePlaying) {
        [self.engine play];
    }else {
        [self.engine pause];
    }
}

- (void)refreshContent:(NSString *)content {
    // 主线程更新 UI
    dispatch_async(dispatch_get_main_queue(), ^{
        self.subtitleLabel.text = content;
        [self.view layoutIfNeeded];
    });
}

- (void)buttonTapped:(UIButton *)sender {
    switch (sender.tag) {
        case 0: {
            // 开启字幕
            [self.engine setOptionForKey:VEKKeyPlayerSubEnabled_BOOL value:@(YES)];
            break;
        }
        case 1: {
            // 关闭字幕
            [self.engine setOptionForKey:VEKKeyPlayerSubEnabled_BOOL value:@(NO)];
            [self refreshContent:@""];
            break;
        }
        case 2: {
            // 切换中文字幕
            [self.engine setOptionForKey:VEKeyPlayerSwitchSubtitleId_NSInteger value:[VEAPIVideoModel defaultSubtitleSubIDs][4][@"cmn-Hans-CN"]];
            break;
        }
        case 3: {
            // 切换英文字幕
            [self.engine setOptionForKey:VEKeyPlayerSwitchSubtitleId_NSInteger value:[VEAPIVideoModel defaultSubtitleSubIDs][4][@"eng-US"]];
            break;
        }
        default:
            break;
    }
}

- (void)getSubtitleInfoModel {
    /**
     json 字符串格式
     {\"list\"：[{\"sub_id\":-248462473,\"format\":\"webvtt\",\"language\":\"cmn-Hans-CN\",\"language_id\":1,\"url\":\"http://vodsdk-api-example.byte-test.com/0a10248c56c44c26b7269eef18e24a6f?auth_key=2063269808-ca6cd62edfbd4b10b52edee9c8db04b9-0-2f2e48450e52206c863cb38df2f14ffa&mime_type=text_plain\"}]}
     */
    NSString *jsonStr = [VEAPIVideoModel defaultVideoModel][4].subtitleModels;
    NSError *error = nil;
    NSDictionary *subTitleDic = [NSJSONSerialization JSONObjectWithData:[jsonStr dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
    
    // 构建字幕源的Model
    self.subtitleInfoModel = [[TTVideoEngineSubDecInfoModel alloc] initWithDictionary:subTitleDic];
}

#pragma mark - TTVideoEngineSubtitleDelegate
// 每行字幕信息回调。返回视频当前播放进度处的字幕内容。收到字幕信息后，您需要自行渲染字幕。
// content：单行字幕内容
// pts：时间戳
- (void)videoEngine:(TTVideoEngine *)videoEngine onSubtitleInfoCallBack:(NSString *)content pts:(NSUInteger)pts {
    // 刷新字幕
    [self refreshContent:content];
    NSLog(@"VEVodPlayerAPIExample - Subtitle - pts:%lu, content:%@", (unsigned long)pts, content);
}

- (void)videoEngine:(TTVideoEngine *)videoEngine onSubtitleInfoCallBack:(TTVideoEngineSubInfo *)subInfo {
    // subInfo.pts: 字幕开始显示的时间戳
    // subInfo.content： 字幕内容
    // subInfo.duration： 字幕要持续的时长。
    // 每行字幕信息回调，subInfo：TTVideoEngineSubInfo
    NSLog(@"VEVodPlayerAPIExample - Subtitle - pts:%ld, content:%@, duration:%ld", (long)subInfo.pts, subInfo.content, (long)subInfo.duration);
}

// 字幕切换完成，currentLangId：当前语言ID
- (void)videoEngine:(TTVideoEngine *)videoEngine onSubSwitchCompleted:(BOOL)success currentLangId:(NSInteger)currentLangId {
    NSLog(@"VEVodPlayerAPIExample - Subtitle - switch to %@.", @(currentLangId));
}

// 当前字幕加载完成
- (void)videoEngine:(TTVideoEngine *)videoEngine onSubLoadFinished:(BOOL)success info:(TTVideoEngineLoadInfo *)info {
  if (!success) {
      // 字幕加载失败。可移除字幕渲染或重新请求
      NSLog(@"VEVodPlayerAPIExample - Subtitle - load fail and code is %ld", (long)info.loadStageCode);
  } else {
      // 字幕加载成功。
      // info.firstPts 字幕首次出现的时间戳
      NSLog(@"VEVodPlayerAPIExample - Subtitle - load success and the first pts is %ld", (long)info.firstPts);
  }
}

@end
