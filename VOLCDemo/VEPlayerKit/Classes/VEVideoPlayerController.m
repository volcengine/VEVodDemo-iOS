//
//  VEVideoPlayerController.m
//  VOLCDemo
//
//  Created by wangzhiyong on 2021/11/11.
//  Copyright © 2021 ByteDance. All rights reserved.
//

#import "VEVideoPlayerController.h"
#import "VEVideoPlayerController+Observer.h"
#import "VEVideoPlayerController+Resolution.h"
#import "VEVideoPlayerController+Options.h"
#import "VEVideoPlayerController+DebugTool.h"
#import "VEVideoPlayerController+Tips.h"
#import "VEVideoPlayerController+Strategy.h"
#import "VEVideoPlayerController+DisRecordScreen.h"
#import <Masonry/Masonry.h>
#import <SDWebImage/SDWebImage.h>

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
}

@end


@interface VEVideoPlayerController () <
VEVideoPlaybackDelegate,
TTVideoEngineDelegate,
TTVideoEngineDataSource,
TTVideoEngineResolutionDelegate>

@property (nonatomic, strong) TTVideoEngine *videoEngine;

@property (nonatomic, strong) id<TTVideoEngineMediaSource> mediaSource;

@property (nonatomic, strong) UIImageView *posterImageView;

@property (nonatomic, strong) UIView *playerPanelContainerView;
@property (nonatomic, strong) UIViewController<VEVideoPlaybackPanelPotocol> *playerPanelViewController;

@property (nonatomic, assign) VEVideoPlaybackState playbackState;
@property (nonatomic, assign) VEVideoLoadState loadState;

@property (nonatomic, strong) UITextView *debugInfoView;

@end

@implementation VEVideoPlayerController

@synthesize delegate;
@synthesize playerTitle;
@synthesize duration;
@synthesize currentPlaybackTime;
@synthesize playableDuration;
@synthesize superResolutionEnable = _superResolutionEnable;
@synthesize videoViewMode = _videoViewMode;
@synthesize startTime = _startTime;

@dynamic playbackRate;
@dynamic playbackVolume;
@dynamic muted;
@dynamic audioMode;

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)dealloc {
    [self removeObserver];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self configuratoinCustomView];
    [self registerScreenCapturedDidChangeNotification];
}

- (void)configVideoEngine {
    self.videoEngine.delegate = self;
    self.videoEngine.resolutionDelegate = self;
    self.videoEngine.reportLogEnable = YES;
    self.videoEngine.dataSource = self;
    [self.videoEngine configResolution:[VEVideoPlayerController getPlayerCurrentResolution]];
    if (@available(iOS 14.0, *)) {
        [self.videoEngine setSupportPictureInPictureMode:YES];
    }
    
    /// add observer
    [self addObserver];
    
    /// config video engine option
    [self openVideoEngineDefaultOptions];
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
    
//    [self.view addSubview:self.debugInfoView];
//    [self.debugInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.view).with.offset(40);
//        make.size.mas_equalTo(CGSizeMake(300, 30));
//    }];
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
    if (self.preRenderOpen) {
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
        if (weak_self.playerPanelViewController) {
            [weak_self.playerPanelViewController videoPlayerTimeTrigger:weak_self.videoEngine.duration
                                               currentPlaybackTime:weak_self.videoEngine.currentPlaybackTime
                                                  playableDuration:weak_self.videoEngine.playableDuration];
        }
        if ([weak_self.receiver respondsToSelector:@selector(playerCore:playTimeDidChanged:info:)]) {
            [weak_self.receiver playerCore:weak_self playTimeDidChanged:weak_self.currentPlaybackTime info:@{}];
        }
    }];
}

#pragma mark - Player control

- (void)resetVideoEngine:(TTVideoEngine * _Nonnull)videoEngine mediaSource:(id<TTVideoEngineMediaSource> _Nonnull)mediaSource {
    self.videoEngine = nil;
    self.mediaSource = mediaSource;
    self.videoEngine = videoEngine;
}

- (void)setMediaSource:(id<TTVideoEngineMediaSource> _Nonnull)mediaSource {
    _mediaSource = mediaSource;
    [self configVideoEngine];
    [self.videoEngine setVideoEngineVideoSource:mediaSource];
}

- (void)loadBackgourdImageWithMediaSource:(id<TTVideoEngineMediaSource> _Nonnull)mediaSource {
    [self __setBackgroudImageForMediaSource:mediaSource];
}

- (void)playWithMediaSource:(id<TTVideoEngineMediaSource> _Nonnull)mediaSource {
    if (self.preRenderOpen) {
        TTVideoEngine *preRenderVideoEngine = [TTVideoEngine getPreRenderVideoEngineWithVideoSource:mediaSource];
        if (preRenderVideoEngine) {
            [self resetVideoEngine:preRenderVideoEngine mediaSource:mediaSource];
            preRenderVideoEngine.delegate = self;
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
    if (@available(iOS 11.0, *)) {
        if ([[[[UIApplication sharedApplication] keyWindow] screen] isCaptured]) {
            [self showRecordScreenView];
            return;
        }
    }
    [self.videoEngine play];
    [self __addPeriodicTimeObserver];
}

- (void)pause {
    [self.videoEngine pause];
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

- (void)setSuperResolutionEnable:(BOOL)superResolutionEnable {
    _superResolutionEnable = superResolutionEnable;
    [self.videoEngine setOptionForKey:VEKKeyPlayerEnableNNSR_BOOL value:@(superResolutionEnable)];
    [self.videoEngine setOptionForKey:VEKKeyIsEnableVideoBmf_BOOL value:@(superResolutionEnable)];
}

#pragma mark - TTVideoEngineDelegate

- (void)videoEnginePrepared:(TTVideoEngine *)videoEngine {
    if (self.delegate &&[self.delegate respondsToSelector:@selector(videoPlayerPrepared:)]) {
        [self.delegate videoPlayerPrepared:self];
    }
    if ([self.receiver respondsToSelector:@selector(playerCore:resolutionChanged:info:)]) {
        [self.receiver playerCore:self resolutionChanged:self.currentResolution info:@{}];
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
    if ([self.receiver respondsToSelector:@selector(playerCore:playbackStateDidChanged:info:)]) {
        [self.receiver playerCore:self playbackStateDidChanged:self.currentPlaybackState info:@{}];
    }
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
    NSLog(@"EngineStrategy: ===== hitCacheSze %@, vid = %@", @(cacheSize), [self.mediaSource getUniqueId]);
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

- (void)videoBitrateDidChange:(TTVideoEngine *)videoEngine resolution:(TTVideoEngineResolutionType)resolution bitrate:(NSInteger)bitrate {
    if (self.delegate && [self.delegate respondsToSelector:@selector(videoPlayerBitrateDidChange:resolution:bitrate:)]) {
        [self.delegate videoPlayerBitrateDidChange:self resolution:resolution bitrate:bitrate];
    }
    // VEUIModule
    if ([self.receiver respondsToSelector:@selector(playerCore:resolutionChanged:info:)]) {
        [self.receiver playerCore:self resolutionChanged:self.currentResolution info:@{}];
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
        }
            break;
        case VEVideoPlaybackStateError: {
            [self showTips:NSLocalizedStringFromTable(@"tip_play_error_normal", @"VodLocalizable", nil)];
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

+ (void)cleanCache {
    [TTVideoEngine ls_clearAllCaches:YES];
}

- (void)setLooping:(BOOL)looping {
    [self.videoEngine setLooping:looping];
}

- (BOOL)looping {
    return self.videoEngine.looping;
}

- (void)setVideoViewMode:(VEVideoViewMode)videoViewMode {
    switch (videoViewMode) {
        case VEVideoViewModeAspectFit: {
            [self.videoEngine setOptionForKey:VEKKeyViewScaleMode_ENUM value:@(TTVideoEngineScalingModeAspectFit)];
            self.posterImageView.contentMode = UIViewContentModeScaleAspectFit;
        }
            break;
        case VEVideoViewModeAspectFill: {
            [self.videoEngine setOptionForKey:VEKKeyViewScaleMode_ENUM value:@(TTVideoEngineScalingModeAspectFill)];
            self.posterImageView.contentMode = UIViewContentModeScaleAspectFill;
        }
            break;
        case VEVideoViewModeModeFill: {
            [self.videoEngine setOptionForKey:VEKKeyViewScaleMode_ENUM value:@(TTVideoEngineScalingModeFill)];
            self.posterImageView.contentMode = UIViewContentModeScaleToFill;
        }
            break;
        default: {
            [self.videoEngine setOptionForKey:VEKKeyViewScaleMode_ENUM value:@(TTVideoEngineScalingModeNone)];
            self.posterImageView.contentMode = UIViewContentModeScaleAspectFit;
        }
            break;
    }
    _videoViewMode = videoViewMode;
}

- (void)setStartTime:(NSTimeInterval)startTime {
    _startTime = startTime;
    [self.videoEngine setOptionForKey:VEKKeyPlayerStartTime_CGFloat value:@(startTime)];
}

#pragma mark - lazy load

- (TTVideoEngine *)videoEngine {
    if (_videoEngine == nil) {
        _videoEngine = [[TTVideoEngine alloc] initWithOwnPlayer:YES];
    }
    return _videoEngine;
}

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

- (UITextView *)debugInfoView {
    if (!_debugInfoView) {
        _debugInfoView = [[UITextView alloc] init];
        _debugInfoView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
        _debugInfoView.textColor = [UIColor redColor];
    }
    return _debugInfoView;
}

@end
