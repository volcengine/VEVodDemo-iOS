//
//  VEVideoPlayerViewController.m
//  VOLCDemo
//
//  Created by wangzhiyong on 2021/11/11.
//  Copyright © 2021 ByteDance. All rights reserved.
//

#import "VEVideoPlayerViewController.h"
#import "VEVideoPlayerViewController+Observer.h"
#import "VEVideoPlayerViewController+Resolution.h"
#import "VEVideoPlayerViewController+Options.h"
#import "VEVideoPlayerViewController+DebugTool.h"
#import "VEVideoPlayerViewController+Tips.h"
#import "TTVideoEngineVidSource+VEVidSource.h"
#import "VEUserGlobalConfiguration.h"


@implementation VEPreRenderVideoEngineMediatorDelegate

+ (VEPreRenderVideoEngineMediatorDelegate *)shareInstance {
    static VEPreRenderVideoEngineMediatorDelegate * preRenderVideoEngineMediatorDelegate = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (preRenderVideoEngineMediatorDelegate == nil) {
            preRenderVideoEngineMediatorDelegate = [[VEPreRenderVideoEngineMediatorDelegate alloc] init];
        }
    });
    return preRenderVideoEngineMediatorDelegate;
}

#pragma mark - TTVideoEnginePreRenderDelegate

- (void)videoEngineWillPrepare:(TTVideoEngine *)videoEngine {
    [VEVideoPlayerViewController setVideoEngineOptions:videoEngine];
}

@end


@interface VEVideoPlayerViewController () <
VEVideoPlaybackDelegate,
TTVideoEngineDelegate,
TTVideoEngineDataSource,
TTVideoEngineResolutionDelegate>

@property (nonatomic, strong) TTVideoEngine *videoEngine;

@property (nonatomic, strong) id<TTVideoEngineMediaSource> currentMediaSource;
@property (nonatomic, strong) UIImageView *posterImageView;

@property (nonatomic, strong) UIView *playerPanelContainerView;
@property (nonatomic, strong) UIViewController<VEVideoPlaybackPanelPotocol> *playerPanelViewController;

@property (nonatomic, assign) VEVideoPlaybackState playbackState;
@property (nonatomic, assign) VEVideoLoadState loadState;

@end

@implementation VEVideoPlayerViewController

@synthesize delegate;
@synthesize playerTitle;
@synthesize duration;
@synthesize currentPlaybackTime;
@synthesize playableDuration;

@dynamic playbackRate;
@dynamic playbackVolume;
@dynamic muted;
@dynamic audioMode;
@dynamic looping;

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)dealloc {
    [self removeObserver];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configuratoinCustomView];
}

- (void)configVideoEngine {
    if (_videoEngine == nil) {
        TTVideoEngine* engine = [[TTVideoEngine alloc] initWithOwnPlayer:YES];
        self.videoEngine = engine;
    }
    self.videoEngine.delegate = self;
    self.videoEngine.resolutionDelegate = self;
    self.videoEngine.reportLogEnable = YES;
    self.videoEngine.dataSource = self;
    [self.videoEngine configResolution:[VEVideoPlayerViewController getPlayerCurrentResolution]];
    if (@available(iOS 14.0, *)) {
        [self.videoEngine setSupportPictureInPictureMode:YES];
    }
    
    /// add observer
    [self addObserver];
    
    /// config video engine option
    [VEVideoPlayerViewController setVideoEngineOptions:self.videoEngine];
}

#pragma mark - UI

- (void)configuratoinCustomView {
    self.view.backgroundColor = [UIColor blackColor];
    
    [self.view addSubview:self.posterImageView];
    [self.posterImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self.view addSubview:self.playerPanelContainerView];
    [self.playerPanelContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

- (void)reLayoutVideoPlayerView {
    if ([self.videoEngine.playerView superview] == nil) {
        [self.view insertSubview:self.videoEngine.playerView aboveSubview:self.posterImageView];
    }
    [self.videoEngine.playerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

#pragma mark - Pirvate

- (void)__setBackgroudImageForMediaSource:(id<TTVideoEngineMediaSource> _Nonnull)mediaSource {
    /// player is running, reture
    if ([self isPlaying] && [self isPause]) {
        return;
    }
    if ([[VEUserGlobalConfiguration sharedInstance] preRenderStrategyEnabled]) {
        TTVideoEngine *preRenderVideoEngine = [TTVideoEngine getPreRenderFinishedVideoEngineWithVideoSource:mediaSource];
        if (preRenderVideoEngine) {
            preRenderVideoEngine.playerView.hidden = NO;
            self.posterImageView.hidden = YES;
            [self.view insertSubview:preRenderVideoEngine.playerView aboveSubview:self.posterImageView];
            [preRenderVideoEngine.playerView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self.view);
            }];
            NSLog(@"EngineStrategy: ===== backgroud image use pre render video engine view");
        } else {
            self.posterImageView.hidden = NO;
            [self.posterImageView sd_setImageWithURL:[NSURL URLWithString:[self __getBackgroudImageUrl:mediaSource]] completed:nil];
        }
    } else {
        self.posterImageView.hidden = NO;
        [self.posterImageView sd_setImageWithURL:[NSURL URLWithString:[self __getBackgroudImageUrl:mediaSource]] completed:nil];
    }
}

- (NSString *)__getBackgroudImageUrl:(id<TTVideoEngineMediaSource> _Nonnull)mediaSource {
    NSString *url = [(NSObject *)mediaSource valueForKey:@"cover"];
    return url ?: @"";
}

- (void)__closeVideoPlayer {
    [self.videoEngine.playerView removeFromSuperview];
    [self.videoEngineDebugTool remove];
    [self.videoEngine closeAysnc];
    [self.videoEngine removeTimeObserver];
    self.videoEngine = nil;
}

- (void)__addPeriodicTimeObserver {
    @weakify(self);
    [self.videoEngine addPeriodicTimeObserverForInterval:0.3f queue:dispatch_get_main_queue() usingBlock:^{
        @strongify(self);
        if (self.playerPanelViewController) {
            [self.playerPanelViewController videoPlayerTimeTrigger:self.videoEngine.duration
                                               currentPlaybackTime:self.videoEngine.currentPlaybackTime
                                                  playableDuration:self.videoEngine.playableDuration];
        }
    }];
}

#pragma mark - Player control

- (void)registePlaybackPanelController:(UIViewController<VEVideoPlaybackPanelPotocol> *)playbackPanelController {
    self.playerPanelViewController = playbackPanelController;
    [self.playerPanelContainerView addSubview:self.playerPanelViewController.view];
    [self.playerPanelViewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.playerPanelContainerView);
    }];
}

- (void)resetVideoEngine:(TTVideoEngine * _Nonnull)videoEngine mediaSource:(id<TTVideoEngineMediaSource> _Nonnull)mediaSource {
    self.videoEngine = nil;
    self.currentMediaSource = mediaSource;
    self.videoEngine = videoEngine;
    
    [self configVideoEngine];
    [self.videoEngine setVideoEngineVideoSource:mediaSource];
}

- (void)setMediaSource:(id<TTVideoEngineMediaSource> _Nonnull)mediaSource {
    self.currentMediaSource = mediaSource;
    [self configVideoEngine];
    [self.videoEngine setVideoEngineVideoSource:mediaSource];
}

- (void)loadBackgourdImageWithMediaSource:(id<TTVideoEngineMediaSource> _Nonnull)mediaSource {
    [self __setBackgroudImageForMediaSource:mediaSource];
}

- (void)playWithMediaSource:(id<TTVideoEngineMediaSource> _Nonnull)mediaSource {
    if ([[VEUserGlobalConfiguration sharedInstance] preRenderStrategyEnabled]) {
        TTVideoEngine *preRenderVideoEngine = [TTVideoEngine getPreRenderVideoEngineWithVideoSource:mediaSource];
        if (preRenderVideoEngine) {
            [self resetVideoEngine:preRenderVideoEngine mediaSource:mediaSource];
            NSLog(@"EngineStrategy: ===== use pre render video engine play");
        } else {
            [self setMediaSource:mediaSource];
        }
    } else {
        [self setMediaSource:mediaSource];
    }
    
    [self play];
    [self reLayoutVideoPlayerView];
    [self __addPeriodicTimeObserver];
}

- (void)prepareToPlay {
    [self.videoEngine prepareToPlay];
}

- (void)play {
    [self.videoEngine play];
    [self __addPeriodicTimeObserver];
}

- (void)pause {
    [self.videoEngine pause];
    [self.videoEngine removeTimeObserver];
}

- (void)seekToTime:(NSTimeInterval)time
          complete:(void(^ _Nullable)(BOOL success))finised
    renderComplete:(void(^ _Nullable)(void)) renderComplete {
    [self.videoEngine setCurrentPlaybackTime:time complete:finised renderComplete:renderComplete];
}

- (void)stop {
    [self.videoEngine stop];
    [self __closeVideoPlayer];
    [self.playerPanelViewController videoPlayerPlaybackStateChanged:self.playbackState newState:VEVideoPlaybackStateStopped];
}

- (void)close {
    [self.videoEngine closeAysnc];
}

- (BOOL)isPlaying {
    return (self.playbackState == VEVideoPlaybackStatePlaying);
}

- (BOOL)isPause {
    return (self.playbackState == VEVideoPlaybackStatePaused);
}

- (NSTimeInterval)duration {
    return self.videoEngine.duration;
}

- (NSTimeInterval)currentPlaybackTime {
    return self.videoEngine.currentPlaybackTime;
}

- (NSTimeInterval)playableDuration {
    return self.videoEngine.playableDuration;
}

- (void)setPlaybackRate:(CGFloat)playbackRate {
    self.videoEngine.playbackSpeed = playbackRate;
}

- (CGFloat)playbackRate {
    return self.videoEngine.playbackSpeed;
}

- (void)setPlaybackVolume:(CGFloat)playbackVolume {
    self.videoEngine.volume = playbackVolume;
}

- (CGFloat)playbackVolume {
    return self.videoEngine.volume;
}

- (void)setMuted:(BOOL)muted {
    [self.videoEngine setMuted:muted];
}

- (BOOL)muted {
    return self.videoEngine.muted;
}

- (void)setAudioMode:(BOOL)audioMode {
    self.videoEngine.radioMode = audioMode;
}

- (BOOL)audioMode {
    return self.videoEngine.radioMode;
}

#pragma mark - TTVideoEngineDelegate

- (void)videoEnginePrepared:(TTVideoEngine *)videoEngine {
    if (self.delegate &&[self.delegate respondsToSelector:@selector(videoPlayerPrepared:)]) {
        [self.delegate videoPlayerPrepared:self];
    }
}

- (void)videoEngineReadyToDisPlay:(TTVideoEngine *)videoEngine {
    self.videoEngine.playerView.hidden = NO;
    if (self.delegate && [self.delegate respondsToSelector:@selector(videoPlayerReadyToDisplay:)]) {
        [self.delegate videoPlayerReadyToDisplay:self];
    }
}

- (void)videoEngine:(TTVideoEngine *)videoEngine playbackStateDidChanged:(TTVideoEnginePlaybackState)playbackState {
    [self __handlePlaybackStateChanged:[self __getPlaybackState:playbackState]];
}

- (void)videoEngine:(TTVideoEngine *)videoEngine loadStateDidChanged:(TTVideoEngineLoadState)loadState {
    [self __handleLoadStateChanged:[self __getLoadState:loadState]];
}

- (void)videoEngine:(TTVideoEngine *)videoEngine loadStateDidChanged:(TTVideoEngineLoadState)loadState extra:(nullable NSDictionary<NSString *,id> *)extraInfo {
    [self __handleLoadStateChanged:[self __getLoadState:loadState]];
}

- (void)videoEngine:(TTVideoEngine *)videoEngine mdlKey:(NSString *)key hitCacheSze:(NSInteger)cacheSize {
    if (self.delegate && [self.delegate respondsToSelector:@selector(videoPlayer:key:hitVideoPreloadDataSize:)]) {
        [self.delegate videoPlayer:self key:key hitVideoPreloadDataSize:cacheSize];
    }
    NSLog(@"EngineStrategy: ===== hitCacheSze %@, vid = %@", @(cacheSize), [self.currentMediaSource getUniqueId]);
}

- (void)videoEngineUserStopped:(TTVideoEngine *)videoEngine {
    [self __handlePlaybackStateChanged:VEVideoPlaybackStateFinishedBecauseUser];
}

- (void)videoEngineDidFinish:(TTVideoEngine *)videoEngine error:(nullable NSError *)error {
    if (error) {
        /// NSLog(@"videoEngineDidFinish with error : %@", [error description]);
        [self __handlePlaybackStateChanged:VEVideoPlaybackStateError];
        return;
    }
    [self __handlePlaybackStateChanged:VEVideoPlaybackStateFinished];
}

- (void)videoEngineDidFinish:(TTVideoEngine *)videoEngine videoStatusException:(NSInteger)status {
    [self __handlePlaybackStateChanged:VEVideoPlaybackStateError];
}

- (void)videoEngineCloseAysncFinish:(TTVideoEngine *)videoEngine {
    [self __handlePlaybackStateChanged:VEVideoPlaybackStateFinished];
}

- (void)videoBitrateDidChange:(TTVideoEngine *)videoEngine resolution:(TTVideoEngineResolutionType)resolution bitrate:(NSInteger)bitrate {
    if (self.delegate && [self.delegate respondsToSelector:@selector(videoPlayerBitrateDidChange:resolution:bitrate:)]) {
        [self.delegate videoPlayerBitrateDidChange:self resolution:resolution bitrate:bitrate];
    }
}

- (void)videoSizeDidChange:(TTVideoEngine *)videoEngine videoWidth:(NSInteger)videoWidth videoHeight:(NSInteger)videoHeight {
    if (self.delegate && [self.delegate respondsToSelector:@selector(videoPlayerViewSizeDidChange:videoWidth:videoHeight:)]) {
        [self.delegate videoPlayerViewSizeDidChange:self videoWidth:videoWidth videoHeight:videoHeight];
    }
}


#pragma mark - Private

- (void)__handlePlaybackStateChanged:(VEVideoPlaybackState)state {
    VEVideoPlaybackState oldPlaybackState = self.playbackState;
    self.playbackState = state;
    switch (state) {
        case VEVideoPlaybackStatePlaying: {
            self.videoEngine.playerView.hidden = NO;
        }
            break;
        case VEVideoPlaybackStatePaused: {
        }
            break;
        case VEVideoPlaybackStateStopped: {
            [self.videoEngine removeTimeObserver];
        }
            break;
        case VEVideoPlaybackStateError: {
            [self showTips:NSLocalizedString(@"tip_play_error_normal", nil)];
        }
            break;
        case VEVideoPlaybackStateFinished: {
        }
            break;
        case VEVideoPlaybackStateFinishedBecauseUser: {
        }
            break;
        default:
            break;
    }
    if (self.playerPanelViewController) {
        [self.playerPanelViewController videoPlayerPlaybackStateChanged:oldPlaybackState newState:state];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(videoPlayer:playbackStateDidChange:)]) {
        [self.delegate videoPlayer:self playbackStateDidChange:self.playbackState];
    }
}

- (void)__handleLoadStateChanged:(VEVideoLoadState)state {
    VEVideoLoadState oldState = state;
    self.loadState = state;
    switch (state) {
        case VEVideoLoadStateStalled: {
        }
            break;
        case VEVideoLoadStatePlayable: {
        }
            break;
        case VEVideoLoadStateError: {
        }
            break;
        default:
            break;
    }
    
    if (self.playerPanelViewController) {
        [self.playerPanelViewController videoPlayerLoadStateChanged:oldState newState:state];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(videoPlayer:loadStateDidChange:)]) {
        [self.delegate videoPlayer:self loadStateDidChange:self.loadState];
    }
}

- (VEVideoPlaybackState)__getPlaybackState:(TTVideoEnginePlaybackState)state {
    switch (state) {
        case TTVideoEnginePlaybackStatePlaying:
            return VEVideoPlaybackStatePlaying;
        case TTVideoEnginePlaybackStatePaused:
            return VEVideoPlaybackStatePaused;
        case TTVideoEnginePlaybackStateStopped:
            return VEVideoPlaybackStateStopped;
        case TTVideoEnginePlaybackStateError:
            return VEVideoPlaybackStateError;
        default:
            return VEVideoPlaybackStateUnkown;
    }
}

- (VEVideoLoadState)__getLoadState:(TTVideoEngineLoadState)state {
    switch (state) {
        case TTVideoEngineLoadStateUnknown:
            return VEVideoLoadStateUnkown;
        case TTVideoEngineLoadStateStalled:
            return VEVideoLoadStateStalled;
        case TTVideoEngineLoadStatePlayable:
            return VEVideoLoadStatePlayable;
        case TTVideoEngineLoadStateError:
            return VEVideoLoadStateError;
        default:
            return VEVideoLoadStateUnkown;
    }
}


#pragma mark - lazy load

- (UIView *)playerView {
    self.videoEngine.playerView.backgroundColor = [UIColor blackColor];
    return self.videoEngine.playerView;
}

- (UIImageView *)posterImageView {
    if (!_posterImageView) {
        _posterImageView = [[UIImageView alloc] init];
        _posterImageView.backgroundColor = [UIColor clearColor];
        _posterImageView.contentMode = UIViewContentModeScaleAspectFit;
        _posterImageView.clipsToBounds = YES;
    }
    return _posterImageView;
}

- (UIView *)playerPanelContainerView {
    if (!_playerPanelContainerView) {
        _playerPanelContainerView = [[UIView alloc] init];
    }
    return _playerPanelContainerView;
}

@end
