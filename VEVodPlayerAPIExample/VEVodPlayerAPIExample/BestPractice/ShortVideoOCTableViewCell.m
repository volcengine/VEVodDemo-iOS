// Copyright (c) 2025 Beijing Volcano Engine Technology Co., Ltd.
// SPDX-License-Identifier: MIT
//
//  ShortVideoOCTableViewCell.m
//  VEVodPlayerAPIExample
//
//  Created by ByteDance on 2025/6/19.
//

#import "ShortVideoOCTableViewCell.h"
#import "VEAPIVideoModel.h"
#import "VEAPIMediaSource.h"
#import <TTSDKFramework/TTSDKFramework.h>
#import <Masonry/Masonry.h>
#import <SDWebImage/UIImageView+WebCache.h>

@interface ShortVideoOCTableViewCell () <TTVideoEngineDelegate>

@property (nonatomic, strong) TTVideoEngine *engine;
@property (nonatomic, strong) NSString *sourceUrl;
@property (nonatomic, strong) NSString *coverUrl;
@property (nonatomic, strong) UIImageView *coverView;
@property (nonatomic, strong) TTVideoEngineUrlSource *urlSource;

@end

@implementation ShortVideoOCTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.coverView.image = nil;
    [self closeAysnc];
    self.coverView.hidden = NO;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor blackColor];
    }
    return self;
}

- (void)configureSource:(NSString *)sourceUrl cover:(NSString *)coverUrl {
    self.sourceUrl = sourceUrl;
    self.coverUrl = coverUrl;
    self.urlSource = [VEAPIMediaSource initDirectUrlSource:self.sourceUrl];
    [self constructViews];
}

- (void)constructViews {
    [self.contentView addSubview:self.coverView];
    [self.coverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
    // 尝试获取预渲染播放器
    TTVideoEngine *preRenderVideoEngine = [TTVideoEngine getPreRenderFinishedVideoEngineWithVideoSource:self.urlSource];
    if (preRenderVideoEngine) {
        self.engine = preRenderVideoEngine;
        self.engine.delegate = self;
        self.engine.playerView.hidden = NO;
        [self constructPlayerView];
        NSLog(@"VEVodPlayerAPIExample - 使用预渲染播放器视图");
    } else {
        NSLog(@"VEVodPlayerAPIExample - 使用封面图");
        [self.coverView sd_setImageWithURL:[NSURL URLWithString:self.coverUrl] completed:nil];
    }
}

- (void)constructPlayerView {
    if ([self.engine.playerView superview] == nil) {
        [self.contentView insertSubview:self.engine.playerView aboveSubview:self.coverView];
    }
    [self.engine.playerView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
}

- (void)play {
    self.coverView.hidden = YES;
    // 尝试获取预渲染播放器
    TTVideoEngine *preRenderVideoEngine = [TTVideoEngine getPreRenderFinishedVideoEngineWithVideoSource:self.urlSource];
    if (preRenderVideoEngine) {
        self.engine = preRenderVideoEngine;
        self.engine.delegate = self;
        self.engine.playerView.hidden = NO;
        NSLog(@"VEVodPlayerAPIExample - 使用预渲染播放器");
    }else {
        self.engine = [[TTVideoEngine alloc] initWithOwnPlayer:YES];
        self.engine.delegate = self;
        [self.engine setVideoEngineVideoSource:self.urlSource];
        NSLog(@"VEVodPlayerAPIExample - 使用新建播放器");
    }
    [self constructPlayerView];
    [self.engine play];
}

- (void)closeAysnc {
    // 释放播放器
    [self.engine.playerView removeFromSuperview];
    [self.engine closeAysnc];
    self.engine = NULL;
}

- (void)pause {
    [self.engine pause];
}

#pragma mark - TTVideoEngineDelegate
- (void)videoEngine:(TTVideoEngine *)videoEngine mdlKey:(NSString *)key hitCacheSze:(NSInteger)cacheSize {
    // 当前播放命中的缓存信息，key 对应缓存的唯一标识符
    // 如果视频做了预加载，cacheSize > 0，表示命中了预加载
    NSLog(@"VEVodPlayerAPIExample - mdl key = %@ - hitCacheSize = %d", key, cacheSize);
}

- (UIImageView *)coverView {
    if (_coverView == NULL) {
        _coverView = [[UIImageView alloc] init];
        _coverView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _coverView;
}

@end
