//
//  VESmallVideoPlaybackPanelViewController.m
//  VOLCDemo
//
//  Created by wangzhiyong on 2021/12/3.
//

#import "VESmallVideoPlaybackPanelViewController.h"
#import "VEVideoPlayerViewController+DebugTool.h"
#import "VEPlayerSliderControlView.h"
#import "VEPlayerToolControlView.h"
#import <MBProgressHUD/MBProgressHUD.h>

@interface VESmallVideoPlaybackPanelViewController () <VEPlayerSliderControlViewDelegate, VEPlayerToolControlViewDelegate>

@property (nonatomic, strong) UILabel *seekTipLabel;

@property (nonatomic, strong) UIView *debugContainerView;

@property (nonatomic, strong) VEPlayerToolControlView *toolControlView;
@property (nonatomic, strong) VEPlayerSliderControlView *sliderControlView;

@property (nonatomic, strong) UIImageView *playIconImage;
@property (nonatomic, strong) MBProgressHUD *loadingView;

@property (nonatomic, assign) NSTimeInterval duration;
@property (nonatomic, assign) BOOL isDragingProgress;

@property (nonatomic, weak) id<VEVideoPlayback> videoPlayer;

@end

@implementation VESmallVideoPlaybackPanelViewController

- (instancetype)initWithVideoPlayer:(id<VEVideoPlayback>)videoPlayer {
    self = [super init];
    if (self) {
        self.videoPlayer = videoPlayer;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configuratoinCustomView];
}

- (void)configuratoinCustomView {
    self.view.backgroundColor = [UIColor clearColor];
    
    [self.view addSubview:self.sliderControlView];
    [self.sliderControlView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.width.equalTo(self.view);
        make.height.mas_equalTo(30);
        if (@available(iOS 11.0, *)) {
            make.bottom.mas_equalTo(self.view.mas_safeAreaLayoutGuideBottom).with.offset(-30);
        } else {
            make.bottom.equalTo(self.view).with.offset(-30);
        }
    }];
    
    [self.view addSubview:self.toolControlView];
    [self.toolControlView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.width.equalTo(self.view);
        make.height.mas_equalTo(40);
        make.bottom.equalTo(self.sliderControlView.mas_top);
    }];
    
    [self.view addSubview:self.playIconImage];
    [self.playIconImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(50, 50));
    }];
    
    [self.view addSubview:self.loadingView];
    [self.loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
    }];
    

    [self.view addSubview:self.seekTipLabel];
    [self.seekTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.toolControlView.mas_top).with.offset(-50);
        make.centerX.equalTo(self.view);
    }];
    self.seekTipLabel.hidden = YES;

    [self.view addSubview:self.debugContainerView];
    if (@available(iOS 11.0, *)) {
        self.debugContainerView.frame = CGRectMake(0, [[[UIApplication sharedApplication] keyWindow] safeAreaInsets].top + 50, SCREEN_WIDTH, SCREEN_HEIGHT - [[[UIApplication sharedApplication] keyWindow] safeAreaInsets].bottom - [[[UIApplication sharedApplication] keyWindow] safeAreaInsets].top - 50 - 80);
    } else {
        self.debugContainerView.frame = CGRectMake(0, 65, SCREEN_WIDTH, SCREEN_HEIGHT - 65 - 80);
    }
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playGestureHandler:)];
    [self.view addGestureRecognizer:tapGesture];
}

- (void)playGestureHandler:(UITapGestureRecognizer *)tapGesture {
    if ([self.videoPlayer isPlaying]) {
        [self.videoPlayer pause];
    } else {
        [self.videoPlayer play];
    }
}

#pragma mark - VEVideoPlaybackPanel

- (void)videoPlayerPlaybackStateChanged:(VEVideoPlaybackState)oldState
                               newState:(VEVideoPlaybackState)newState {
    switch (newState) {
        case VEVideoPlaybackStatePlaying: {
            self.playIconImage.hidden = YES;
            [self.loadingView hideAnimated:YES];
        }
            break;
        case VEVideoPlaybackStatePaused: {
            self.playIconImage.hidden = NO;
        }
            break;
        case VEVideoPlaybackStateStopped: {
            [self.loadingView hideAnimated:YES];
            [self.toolControlView reset];
        }
            break;
        case VEVideoPlaybackStateError: {
            self.playIconImage.hidden = NO;
            [self.loadingView hideAnimated:YES];
        }
            break;
        case VEVideoPlaybackStateFinished: {
            [self.loadingView hideAnimated:YES];
        }
            break;
        case VEVideoPlaybackStateFinishedBecauseUser: {
            [self.loadingView hideAnimated:YES];
        }
            break;
        default:
            break;
    }
}

- (void)videoPlayerLoadStateChanged:(VEVideoLoadState)oldState
                           newState:(VEVideoLoadState)newState {
    switch (newState) {
        case VEVideoLoadStateStalled: {
            [self.loadingView showAnimated:YES];
        }
            break;
        case VEVideoLoadStatePlayable: {
            [self.loadingView hideAnimated:YES];
        }
            break;
        case VEVideoLoadStateError: {
            [self.loadingView hideAnimated:YES];
        }
            break;
        default:
            break;
    }
}

- (void)videoPlayerTimeTrigger:(NSTimeInterval)duration
           currentPlaybackTime:(NSTimeInterval)currentPlaybackTime
              playableDuration:(NSTimeInterval)playableDuration {
    self.duration = duration;
    if (!self.isDragingProgress && playableDuration > 0) {
        [self.sliderControlView setProgress:currentPlaybackTime / duration animated:YES];
        [self.sliderControlView setCacheProgress:playableDuration / duration animated:YES];
    }
}


#pragma mark - VEPlayerSliderControlView Delegate

- (void)sliderWillDragingProgress:(CGFloat)progress {
    self.isDragingProgress = YES;
}

- (void)sliderProgressValueChanged:(CGFloat)progress {
    self.seekTipLabel.hidden = NO;
    NSString *curString = [NSString stringWithFormat:@"%02ld:%02ld", (NSInteger)(progress * self.duration) / 60, (NSInteger)(progress * self.duration) % 60];
    NSString *durationString = [NSString stringWithFormat:@"%02ld:%02ld", (NSInteger)(self.duration) /60, (NSInteger)(self.duration) % 60];
    self.seekTipLabel.text = [NSString stringWithFormat:@"%@ / %@", curString, durationString];
}

- (void)sliderDidSeekToProgress:(CGFloat)progress {
    NSTimeInterval time = progress * self.videoPlayer.duration;
    [self.videoPlayer seekToTime:time complete:nil renderComplete:nil];
    self.isDragingProgress = NO;
    self.seekTipLabel.hidden = YES;
}


#pragma mark - VEPlayerToolControlView Delegate

- (void)toolControlViewDebugButtonDidClicked:(VEPlayerToolControlView *)controlView isShow:(BOOL)isShow {
    if ([self.videoPlayer isKindOfClass:[VEVideoPlayerViewController class]]) {
        self.debugContainerView.hidden = !isShow;
        if (isShow) {
            [(VEVideoPlayerViewController *)self.videoPlayer showDebugViewInView:self.debugContainerView];
        } else {
            [(VEVideoPlayerViewController *)self.videoPlayer removeDebugTool];
        }
    }
}

- (void)toolControlViewLogMuteButtonDidClicked:(VEPlayerToolControlView *)controlView isMute:(BOOL)mute {
    self.videoPlayer.muted = mute;
}

- (void)toolControlViewLogAudioButtonDidClicked:(VEPlayerToolControlView *)controlView isAudio:(BOOL)isAudio {
    self.videoPlayer.audioMode = isAudio;
}

#pragma mark - lazy load

- (UILabel *)seekTipLabel {
    if (!_seekTipLabel) {
        _seekTipLabel = [[UILabel alloc] init];
        _seekTipLabel.font = [UIFont systemFontOfSize:18];
        _seekTipLabel.textColor = [UIColor whiteColor];
        _seekTipLabel.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.1];
    }
    return _seekTipLabel;
}

- (VEPlayerSliderControlView *)sliderControlView {
    if (!_sliderControlView) {
        _sliderControlView = [[VEPlayerSliderControlView alloc] init];
        _sliderControlView.delegate = self;
    }
    return _sliderControlView;
}

- (VEPlayerToolControlView *)toolControlView {
    if (!_toolControlView) {
        _toolControlView = [[VEPlayerToolControlView alloc] init];
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
