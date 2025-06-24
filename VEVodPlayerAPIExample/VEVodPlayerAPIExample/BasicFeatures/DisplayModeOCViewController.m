// Copyright (c) 2025 Beijing Volcano Engine Technology Co., Ltd.
// SPDX-License-Identifier: MIT
//
//  DisplayModeOCViewController.m
//  VEVodPlayerAPIExample
//
//  Created by ByteDance on 2025/5/28.
//

#import "DisplayModeOCViewController.h"
#import "VEAPIVideoModel.h"
#import "VEAPIButton.h"
#import "VEAPIMediaSource.h"
#import <TTSDKFramework/TTSDKFramework.h>
#import <Masonry/Masonry.h>

@interface DisplayModeOCViewController ()

@property (nonatomic, strong) TTVideoEngine *engine;
@property (nonatomic, assign) NSInteger buttonNum;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *containView;

@end

@implementation DisplayModeOCViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"VEVodPlayerAPIExample - DisplayModeOCViewController");
    self.view.backgroundColor = [UIColor whiteColor];
    [self constructViews];
}

- (void)viewDidDisappear:(BOOL)animated {
    // 移除视图
    [self.engine.playerView removeFromSuperview];
    // 停止播放，销毁 engine 实例，engine 实例不能再次被使用。
    [self.engine closeAysnc];
    self.engine = nil;
    [super viewWillDisappear:animated];
}

- (void)constructViews {
    self.scrollView = [[UIScrollView alloc] init];
    [self.view addSubview:self.scrollView];
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.equalTo(self.view);
        make.width.equalTo(self.view);
        make.height.equalTo(self.view);
    }];
    self.containView = [[UIView alloc] init];
    [self.scrollView addSubview:self.containView];
    [self.containView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.scrollView);
        make.width.equalTo(self.scrollView);
    }];
    
    // 初始化播放器实例并以属性持有
    self.engine = [[TTVideoEngine alloc] initWithOwnPlayer:YES];
    // playerView 是播放器的显示视图，需要被添加业务父视图中并设置 playerView 的 frame
    [self.containView addSubview:self.engine.playerView];
    self.engine.playerView.backgroundColor = [UIColor grayColor];
    [self.engine.playerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.containView);
        make.left.equalTo(self.containView);
        make.width.equalTo(self.containView);
        make.height.equalTo(self.containView.mas_width);
    }];
    // 设置 directUrl 播放源
    NSString *videoUrl = [VEAPIVideoModel defaultVideoModel][0].videoUrl;
    TTVideoEngineUrlSource *urlSource = [VEAPIMediaSource initDirectUrlSource:videoUrl];
    [self.engine setVideoEngineVideoSource:urlSource];
    [self.engine play];
    
    UILabel *ratioLabel = [[UILabel alloc] init];
    ratioLabel.text = NSLocalizedString(@"view_size_label", NULL);
    [self.containView addSubview:ratioLabel];
    [ratioLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.engine.playerView.mas_bottom).offset(3);
        make.left.equalTo(self.containView).offset(5);
        make.width.mas_equalTo(300);
        make.height.mas_equalTo(30);
    }];
    NSArray *ratioTitles = @[@"1:2", @"9:16", @"3:4", @"1:1", @"4:3", @"16:9", @"2:1"];
    [self constructButtons:ratioTitles Width:50 BelowLabel:ratioLabel];
    
    UILabel *displayLabel = [[UILabel alloc] init];
    displayLabel.text = NSLocalizedString(@"mode_label", NULL);
    [self.containView addSubview:displayLabel];
    [displayLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(ratioLabel.mas_bottom).offset(41);
        make.left.equalTo(self.containView).offset(5);
        make.width.mas_equalTo(300);
        make.height.mas_equalTo(30);
    }];
    NSArray *displayTitles = @[@"AspectFit", @"AspectFill", @"Fill"];
    [self constructButtons:displayTitles Width:90 BelowLabel:displayLabel];
    
    [self.containView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(displayLabel.mas_bottom).offset(70);
    }];
}

- (void)constructButtons:(NSArray <NSString *> *)titles Width:(NSInteger)width BelowLabel:(UILabel *)label {
    for (int i = 0; i < titles.count; ++i) {
        VEAPIButton *button = [[VEAPIButton alloc] initWithTitle:titles[i]];
        [self.containView addSubview:button];
        button.tag = self.buttonNum;
        self.buttonNum += 1;
        [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(label.mas_bottom).offset(3);
            make.left.equalTo(self.containView).offset((width + 5) * i + 3);
            make.width.mas_equalTo(width);
            make.height.mas_equalTo(35);
        }];
    }
}

- (void)buttonTapped:(UIButton *)sender {
    switch (sender.tag) {
        case 0: {
            [self.engine.playerView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.containView);
                make.left.equalTo(self.containView);
                make.width.equalTo(self.containView);
                make.height.mas_equalTo(self.containView.frame.size.width * 2);
            }];
            break;
        }
        case 1: {
            [self.engine.playerView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.containView);
                make.left.equalTo(self.containView);
                make.width.equalTo(self.containView);
                make.height.mas_equalTo(self.containView.frame.size.width * 16 / 9);
            }];
            break;
        }
        case 2: {
            [self.engine.playerView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.containView);
                make.left.equalTo(self.containView);
                make.width.equalTo(self.containView);
                make.height.mas_equalTo(self.containView.frame.size.width * 4 / 3);
            }];
            break;
        }
        case 3: {
            [self.engine.playerView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.containView);
                make.left.equalTo(self.containView);
                make.width.equalTo(self.containView);
                make.height.mas_equalTo(self.containView.frame.size.width);
            }];
            break;
        }
        case 4: {
            [self.engine.playerView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.containView);
                make.left.equalTo(self.containView);
                make.width.equalTo(self.containView);
                make.height.mas_equalTo(self.containView.frame.size.width * 3 / 4);
            }];
            break;
        }
        case 5: {
            [self.engine.playerView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.containView);
                make.left.equalTo(self.containView);
                make.width.equalTo(self.containView);
                make.height.mas_equalTo(self.containView.frame.size.width * 9 / 16);
            }];
            break;
        }
        case 6: {
            [self.engine.playerView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.containView);
                make.left.equalTo(self.containView);
                make.width.equalTo(self.containView);
                make.height.mas_equalTo(self.containView.frame.size.width / 2);
            }];
            break;
        }
        case 7: {
            // 等比例适配，不会有变形，按照视频宽高等比适配画面，可能有黑边
            [self.engine setOptionForKey:VEKKeyViewScaleMode_ENUM value:@(TTVideoEngineScalingModeAspectFit)];
            break;
        }
        case 8: {
            // 等比例填充，不会有变形，按照视频宽高等比充满画面，可能有画面裁切
            [self.engine setOptionForKey:VEKKeyViewScaleMode_ENUM value:@(TTVideoEngineScalingModeAspectFill)];
            break;
        }
        case 9: {
            // 拉伸填充，视频宽高比例与画面比例不一致，会导致画面变形
            [self.engine setOptionForKey:VEKKeyViewScaleMode_ENUM value:@(TTVideoEngineScalingModeFill)];
            break;
        }
        default:
            break;
    }
}

@end
