//
//  VOLCSmallVideoPlayerView.m
//  VOLCDemo
//
//  Created by wangzhiyong on 2021/5/24.
//  Copyright © 2021 ByteDance. All rights reserved.
//

#import "VOLCSmallVideoPlayerView.h"
#import "VOLCVideoPlayer.h"
#import "VOLCPlayerSliderControlView.h"
#import "VOLCPlayerToolControlView.h"
#import <MBProgressHUD/MBProgressHUD.h>

NSString * const kVOLCCanPreLoadNextVideoIfNeedNotification = @"kVOLCCanPreLoadNextVideoIfNeedNotification";

@interface VOLCSmallVideoPlayerView () <VOLCVideoPlayerDelegate, VOLCPlayerSliderControlViewDelegate, VOLCPlayerToolControlViewDelegate>

@property (nonatomic, strong) VOLCVideoModel *videoModel;
@property (nonatomic, strong) VOLCVideoPlayer *videoPlayer;

@property (nonatomic, strong) UIImageView *posterImageView;

@property (nonatomic, strong) UIView *playerControlContainerView;
@property (nonatomic, strong) UILabel *preloadSizeLabel;
@property (nonatomic, strong) UILabel *seekTipLabel;
@property (nonatomic, strong) VOLCPlayerToolControlView *toolControlView;
@property (nonatomic, strong) VOLCPlayerSliderControlView *sliderControlView;

@property (nonatomic, strong) UIImageView *playIconImage;
@property (nonatomic, strong) MBProgressHUD *loadingView;

@property (nonatomic, assign) BOOL isDragingProgress;
@property (nonatomic, assign, readwrite) BOOL readyDisplay;
@property (nonatomic, assign, readwrite) BOOL posterImageLoaded;

@property (nonatomic, assign, readwrite) BOOL postCanPreLoadNextVideoNotifi;

@property (nonatomic, strong) UIView *debugContainerView;

@end

@implementation VOLCSmallVideoPlayerView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self configuratoinCustomView];
    }
    return self;
}

#pragma mark - UI

- (void)configuratoinCustomView {
    self.backgroundColor = [UIColor blackColor];
    
    [self addSubview:self.posterImageView];
    [self.posterImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    [self addSubview:self.playerControlContainerView];
    [self.playerControlContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    [self.playerControlContainerView addSubview:self.sliderControlView];
    [self.sliderControlView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.width.equalTo(self.playerControlContainerView);
        make.height.mas_equalTo(30);
        if (@available(iOS 11.0, *)) {
            make.bottom.mas_equalTo(self.mas_safeAreaLayoutGuideBottom);
        } else {
            make.bottom.equalTo(self).with.offset(-10);
        }
    }];
    
    [self.playerControlContainerView addSubview:self.toolControlView];
    [self.toolControlView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.width.equalTo(self.playerControlContainerView);
        make.height.mas_equalTo(40);
        make.bottom.equalTo(self.sliderControlView.mas_top);
    }];
    
    [self.playerControlContainerView addSubview:self.playIconImage];
    [self.playIconImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.playerControlContainerView);
        make.size.mas_equalTo(CGSizeMake(50, 50));
    }];
    
    [self.playerControlContainerView addSubview:self.loadingView];
    [self.loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.playerControlContainerView);
    }];
    
    [self.playerControlContainerView addSubview:self.preloadSizeLabel];
    [self.preloadSizeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.toolControlView.mas_top);
        make.left.width.equalTo(self.playerControlContainerView);
        make.height.mas_equalTo(25);
    }];
    
    [self.playerControlContainerView addSubview:self.seekTipLabel];
    [self.seekTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.preloadSizeLabel.mas_top).with.offset(-20);
        make.centerX.equalTo(self.playerControlContainerView);
    }];
    self.seekTipLabel.hidden = YES;
    
    [self addSubview:self.debugContainerView];
    if (@available(iOS 11.0, *)) {
        self.debugContainerView.frame = CGRectMake(0, [[[UIApplication sharedApplication] keyWindow] safeAreaInsets].top + 50, SCREEN_WIDTH, SCREEN_HEIGHT - [[[UIApplication sharedApplication] keyWindow] safeAreaInsets].bottom - [[[UIApplication sharedApplication] keyWindow] safeAreaInsets].top - 50 - 80);
    } else {
        self.debugContainerView.frame = CGRectMake(0, 65, SCREEN_WIDTH, SCREEN_HEIGHT - 65 - 80);
    }
}


#pragma mark - Public

- (void)configWithVideoModel:(VOLCVideoModel *)videoModel {
    self.videoModel = videoModel;
    self.postCanPreLoadNextVideoNotifi = NO;
    self.playIconImage.hidden = YES;
    [self.videoPlayer setVideoId:videoModel.videoId playAuthToken:videoModel.playAuthToken];
    [self.videoPlayer setAudioMode:self.toolControlView.isAudioOn];
    [self.videoPlayer setMuted:self.toolControlView.isMuteOn];
    self.posterImageLoaded = NO;
    [self.posterImageView sd_setImageWithURL:[NSURL URLWithString:videoModel.coverUrl] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        self.posterImageLoaded = YES;
    }];
}

- (void)play {
    self.readyDisplay = NO;
    [self.videoPlayer play];
    [self __addPeriodicTimeObserver];
}

- (void)stop {
    [self.toolControlView reset];
    [self __releaseVideoPlayer];
}

- (void)pause {
    self.videoPlayer.playerView.hidden = YES;
    [self.videoPlayer pause];
    [self.videoPlayer removeTimeObserver];
}


#pragma mark - Pirvate

- (void)__releaseVideoPlayer {
    self.videoPlayer.playerView.hidden = YES;
    [self.videoPlayer close];
    [self.videoPlayer removeDebugTool];
    [self.videoPlayer removeTimeObserver];
    self.videoPlayer = nil;
}

- (void)__addPeriodicTimeObserver {
    @weakify(self);
    [self.videoPlayer addPeriodicTimeObserverForInterval:0.3f queue:dispatch_get_main_queue() usingBlock:^{
        @strongify(self);
        if (!self.isDragingProgress && self.videoPlayer.playableDuration > 0) {
            [self.sliderControlView setProgress:self.videoPlayer.currentPlaybackTime / self.videoPlayer.duration animated:YES];
            [self.sliderControlView setCacheProgress:self.videoPlayer.playableDuration / self.videoPlayer.duration animated:YES];
            
            [self __checkPlayerCacheStatus];
        }
    }];
}

- (void)__playGestureHandler:(UITapGestureRecognizer *)tapGesture {
    if ([self.videoPlayer isPlaying]) {
        self.playIconImage.hidden = NO;
        [self.videoPlayer pause];
    } else {
        self.playIconImage.hidden = YES;
        [self.videoPlayer play];
    }
}

- (void)__checkPlayerCacheStatus {
    if (self.videoPlayer.duration > 0) {
        if (self.videoPlayer.duration > 45) {
            if (!self.postCanPreLoadNextVideoNotifi && (self.videoPlayer.playableDuration - self.videoPlayer.currentPlaybackTime) > 20) {
                self.postCanPreLoadNextVideoNotifi = YES;
                [[NSNotificationCenter defaultCenter] postNotificationName:kVOLCCanPreLoadNextVideoIfNeedNotification object:nil userInfo:nil];
            }
        } else {
            if (!self.postCanPreLoadNextVideoNotifi && ABS(self.videoPlayer.playableDuration - self.videoPlayer.duration) < 1) {
                self.postCanPreLoadNextVideoNotifi = YES;
                [[NSNotificationCenter defaultCenter] postNotificationName:kVOLCCanPreLoadNextVideoIfNeedNotification object:nil userInfo:nil];
            }
        }
    }
}


#pragma mark - VOLCPlayerSliderControlView Delegate

- (void)sliderWillDragingProgress:(CGFloat)progress {
    self.isDragingProgress = YES;
}

- (void)sliderProgressValueChanged:(CGFloat)progress {
    self.seekTipLabel.hidden = NO;
    NSString *curString = [NSString stringWithFormat:@"%02ld:%02ld", (NSInteger)(progress * self.videoPlayer.duration) / 60, (NSInteger)(progress * self.videoPlayer.duration) % 60];
    NSString *durationString = [NSString stringWithFormat:@"%02ld:%02ld", (NSInteger)(self.videoPlayer.duration) /60, (NSInteger)(self.videoPlayer.duration) % 60];
    self.seekTipLabel.text = [NSString stringWithFormat:@"%@ / %@", curString, durationString];
}

- (void)sliderDidSeekToProgress:(CGFloat)progress {
    CGFloat time = progress * self.videoPlayer.duration;
    [self.videoPlayer seekToTime:time complete:^(BOOL success) {
        
    }];
    self.isDragingProgress = NO;
    self.seekTipLabel.hidden = YES;
}


#pragma mark - VOLCPlayerToolControlView Delegate

- (void)toolControlViewDebugButtonDidClicked:(VOLCPlayerToolControlView *)controlView isShow:(BOOL)isShow {
    self.debugContainerView.hidden = !isShow;
    if (isShow) {
        [self.videoPlayer showDebugViewInView:self.debugContainerView zIndex:0];
    } else {
        [self.videoPlayer removeDebugTool];
    }
}

- (void)toolControlViewLogMuteButtonDidClicked:(VOLCPlayerToolControlView *)controlView isMute:(BOOL)mute {
    self.videoPlayer.muted = mute;
}

- (void)toolControlViewLogAudioButtonDidClicked:(VOLCPlayerToolControlView *)controlView isAudio:(BOOL)isAudio {
    self.videoPlayer.audioMode = isAudio;
}


#pragma mark - VOLCVideoPlayer delegate

- (void)playerPrepared:(VOLCVideoPlayer *)player {
    
}

- (void)readyToDisplay:(VOLCVideoPlayer *)player {
    self.readyDisplay = YES;
    self.videoPlayer.playerView.hidden = NO;
}

- (void)player:(VOLCVideoPlayer *)player loadStateDidChange:(VOLCVideoLoadState)state {
    switch (state) {
        case VOLCVideoLoadStateStalled: {
            [self.loadingView showAnimated:YES];
        }
            break;
        case VOLCVideoLoadStatePlayable: {
            [self.loadingView hideAnimated:YES];
            
            [self __checkPlayerCacheStatus];
        }
            break;
        case VOLCVideoLoadStateError: {
            [self.loadingView hideAnimated:YES];
        }
            break;
        default:
            break;
    }
}

- (void)player:(VOLCVideoPlayer *)player playbackStateDidChange:(VOLCVideoPlaybackState)state {
    switch (state) {
        case VOLCVideoPlaybackStatePlaying: {
            self.videoPlayer.playerView.hidden = NO;
            [self.loadingView hideAnimated:YES];
        }
            break;
        case VOLCVideoPlaybackStatePaused: {
            [self __checkPlayerCacheStatus];
        }
            break;
        case VOLCVideoPlaybackStateStopped: {
            [self.sliderControlView setProgress:0 animated:YES];
            [self.sliderControlView setCacheProgress:0 animated:YES];
        }
            break;
        case VOLCVideoPlaybackStateError: {
        }
            break;
        case VOLCVideoPlaybackStateFinished: {
        }
            break;
        case VOLCVideoPlaybackStateFinishedBecauseUser: {
        }
            break;
        default:
            break;
    }
}

- (void)player:(VOLCVideoPlayer *)player key:(NSString *)key hitVideoPreloadDataSize:(NSInteger)dataSize {
    if (dataSize > 0) {
        self.preloadSizeLabel.text = [NSString stringWithFormat:@"hit preload data size : %ld", dataSize];
    } else {
        self.preloadSizeLabel.text = [NSString stringWithFormat:@"not hit preload data"];
    }
}


#pragma mark - lazy load

- (UIImageView *)posterImageView {
    if (!_posterImageView) {
        _posterImageView = [[UIImageView alloc] init];
        _posterImageView.backgroundColor = [UIColor clearColor];
        _posterImageView.contentMode = UIViewContentModeScaleAspectFit;
        _posterImageView.clipsToBounds = YES;
    }
    return _posterImageView;
}

- (VOLCVideoPlayer *)videoPlayer {
    if (!_videoPlayer) {
        _videoPlayer = [[VOLCVideoPlayer alloc] init];
        _videoPlayer.delegate = self;
        _videoPlayer.looping = YES;

        [self insertSubview:_videoPlayer.playerView aboveSubview:self.posterImageView];
        [_videoPlayer.playerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
    }
    return _videoPlayer;
}

- (UIView *)playerControlContainerView {
    if (!_playerControlContainerView) {
        _playerControlContainerView = [[UIView alloc] init];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(__playGestureHandler:)];
        [_playerControlContainerView addGestureRecognizer:tapGesture];
    }
    return _playerControlContainerView;
}

- (UILabel *)preloadSizeLabel {
    if (!_preloadSizeLabel) {
        _preloadSizeLabel = [[UILabel alloc] init];
        _preloadSizeLabel.textAlignment = NSTextAlignmentCenter;
        _preloadSizeLabel.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
        _preloadSizeLabel.textColor = [UIColor brownColor];
        _preloadSizeLabel.font = [UIFont systemFontOfSize:14];
    }
    return _preloadSizeLabel;
}

- (UILabel *)seekTipLabel {
    if (!_seekTipLabel) {
        _seekTipLabel = [[UILabel alloc] init];
        _seekTipLabel.font = [UIFont systemFontOfSize:18];
        _seekTipLabel.textColor = [UIColor whiteColor];
        _seekTipLabel.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.1];
    }
    return _seekTipLabel;
}

- (VOLCPlayerSliderControlView *)sliderControlView {
    if (!_sliderControlView) {
        _sliderControlView = [[VOLCPlayerSliderControlView alloc] init];
        _sliderControlView.delegate = self;
    }
    return _sliderControlView;
}

- (VOLCPlayerToolControlView *)toolControlView {
    if (!_toolControlView) {
        _toolControlView = [[VOLCPlayerToolControlView alloc] init];
        _toolControlView.delegate = self;
    }
    return _toolControlView;
}

- (MBProgressHUD *)loadingView {
    if (!_loadingView) {
        _loadingView = [[MBProgressHUD alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        _loadingView.mode = MBProgressHUDModeIndeterminate;
    }
    return _loadingView;
}

- (UIImageView *)playIconImage {
    if (!_playIconImage) {
        _playIconImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"learning_live_play"]];
        _playIconImage.contentMode = UIViewContentModeCenter;
        _playIconImage.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.4];
        _playIconImage.layer.cornerRadius = 50 / 2;
        _playIconImage.hidden = YES;
    }
    return _playIconImage;
}

- (UIView *)debugContainerView {
    if (!_debugContainerView) {
        _debugContainerView = [[UIView alloc] init];
        _debugContainerView.hidden = YES;
    }
    return _debugContainerView;
}

@end
