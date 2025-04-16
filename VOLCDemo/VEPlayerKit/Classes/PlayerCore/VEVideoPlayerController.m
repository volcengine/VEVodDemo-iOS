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
#import "VEVideoPlayerController+DebugTool.h"
#import "VEVideoPlayerController+Tips.h"
#import "VEVideoPlayerController+Strategy.h"
#import "VEVideoPlayerController+DisRecordScreen.h"
#import "TTVideoEngineSourceCategory.h"
#import <Masonry/Masonry.h>
#import <SDWebImage/SDWebImage.h>
#import "VEPlayerContext.h"
#import "VEPlayerInteraction.h"
#import "VEPlayerContextKeyDefine.h"
#import "BTDMacros.h"
#import "VEVideoEnginePool.h"
#import "BTDMacros.h"
#import <AVKit/AVKit.h>
#import "VEVideoPlayerPipController.h"

@interface VEVideoPlayerDisplayView : UIView

@end

@implementation VEVideoPlayerDisplayView

+ (Class)layerClass {
  return [AVSampleBufferDisplayLayer class];
}

@end

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

- (void)videoEngine:(TTVideoEngine *)videoEngine willPreRenderSource:(id<TTVideoEngineMediaSource>)source {
    BOOL enableSubtitle = NO;
    NSInteger subtitleSourceType = VEPlayerKitSubtitleSourceAuthToken;  // 0 vid + authtoken, 1 direct url
    @synchronized (self) {
        enableSubtitle = self.playerConfig.enableSubtitle;
        subtitleSourceType = self.playerConfig.subtitleSourceType;
    }
    id value = nil;
    @synchronized (self) {
        value = [self.subtitleModels objectForKey:source.uniqueId];
    }
    if (enableSubtitle) {
        if (subtitleSourceType == VEPlayerKitSubtitleSourceDirectUrl) {
            if ([value isKindOfClass:[NSDictionary class]]) {
                NSDictionary *subInfoDict = value;
                NSNumber *subtitleId = [subInfoDict objectForKey:@"id"];
                TTVideoEngineSubDecInfoModel *subtitleInfoModel = [subInfoDict objectForKey:@"model"];
                [videoEngine setSubDecInfoModel:subtitleInfoModel];
                [videoEngine setOptionForKey:VEKeyPlayerSwitchSubtitleId_NSInteger value:subtitleId];
            }
        } else if (subtitleSourceType == VEPlayerKitSubtitleSourceAuthToken) {
            if ([value isKindOfClass:[NSString class]]) {
                NSString *subtitleAuthToken = value;
                [videoEngine setSubtitleAuthToken:subtitleAuthToken];
            }
        }
    }
}

- (void)videoEngineWillPrepare:(TTVideoEngine *)videoEngine {
    BOOL enableSubtitle = NO;
    id<TTVideoEngineSubtitleDelegate> subtitleDelegate = nil;
    @synchronized (self) {
        enableSubtitle = self.playerConfig.enableSubtitle;
        subtitleDelegate = self.subtitleDelegate;
    }
    if (enableSubtitle) {
        [videoEngine setOptionForKey:VEKeyPlayerEnableSubThread_BOOL value:@(YES)];
        [videoEngine setOptionForKey:VEKKeyPlayerSubtitleOptEnable_BOOL value:@(YES)];
        [videoEngine setOptionForKey:VEKKeyPlayerSubEnabled_BOOL value:@(YES)];
        [videoEngine setOptionForKey:VEKKeySubTitleEnableMDL_BOOL value:@(YES)];
        [videoEngine setSubtitleDelegate:subtitleDelegate];
    }
}

#pragma mark - Setter
- (void)setPlayerConfig:(VEVideoPlayerConfiguration *)playerConfig {
    @synchronized (self) {
        _playerConfig = playerConfig;
    }
}

- (void)setSubtitleModels:(NSMutableDictionary *)subtitleModels {
    @synchronized (self) {
        _subtitleModels = subtitleModels;
    }
}

- (void)setSubtitleDelegate:(id<TTVideoEngineSubtitleDelegate>)subtitleDelegate {
    @synchronized (self) {
        _subtitleDelegate = subtitleDelegate;
    }
}
@end


@interface VEVideoPlayerController () <
VEVideoPlaybackDelegate,
TTVideoEngineDelegate,
TTVideoEngineDataSource,
TTVideoEngineResolutionDelegate,
TTVideoEnginePreloadDelegate,
TTVideoEngineSubtitleDelegate,
VEVideoPlayerPipControllerDelegate>

@property (nonatomic, strong) VEVideoPlayerConfiguration *playerConfig;
@property (nonatomic, strong) TTVideoEngine *videoEngine;
@property (nonatomic, assign) VECreateEngineFrom engineFrom;

@property (nonatomic, strong) id<TTVideoEngineMediaSource> mediaSource;

@property (nonatomic, weak) UIView *playerContainerView;
@property (nonatomic, strong) UIImageView *posterImageView;

@property (nonatomic, assign) VEVideoPlaybackState playbackState;
@property (nonatomic, assign) VEVideoLoadState loadState;

@property (nonatomic, strong) VEPlayerContext *context;

@property (nonatomic, strong) VEPlayerInteraction<VEPlayerInteractionPlayerProtocol> *interaction;

@property (nonatomic, copy) NSString *subtitleAuthToken;
@property (nonatomic, strong) TTVideoEngineSubDecInfoModel *subtitleInfoModel;
@property (nonatomic, assign) NSInteger subtitleId;


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
@synthesize netWorkSpeed = _netWorkSpeed;

@dynamic playbackRate;
@dynamic playbackVolume;
@dynamic muted;
@dynamic audioMode;

- (instancetype)initWithConfiguration:(VEVideoPlayerConfiguration *)configuration {
    self = [super init];
    if (self) {
        self.playerConfig = configuration;
        [VEPreRenderVideoEngineMediatorDelegate shareInstance].subtitleDelegate = self;
        [TTVideoEngine setPreRenderVideoEngineDelegate:[VEPreRenderVideoEngineMediatorDelegate shareInstance]];
    }
    return self;
}

- (instancetype)initWithConfiguration:(VEVideoPlayerConfiguration *)configuration 
                         moduleLoader:(VEPlayerBaseModule *)moduleLoader {
    return [self initWithConfiguration:configuration moduleLoader:moduleLoader playerContainerView:nil];
}

- (instancetype)initWithConfiguration:(VEVideoPlayerConfiguration *)configuration
                         moduleLoader:(VEPlayerBaseModule *)moduleLoader
                  playerContainerView:(UIView * _Nullable)containerView {
    self = [self initWithConfiguration:configuration];
    if (self) {
        self.playerContainerView = containerView;
        self.playerConfig = configuration;
        
        _context = [[VEPlayerContext alloc] init];
        [_context bindOwner:self withProtocol:@protocol(VEVideoPlayback)];
        
        _interaction = [[VEPlayerInteraction alloc] initWithContext:_context];
        [_interaction addModule:moduleLoader];
        [VEPreRenderVideoEngineMediatorDelegate shareInstance].subtitleDelegate = self;
        [TTVideoEngine setPreRenderVideoEngineDelegate:[VEPreRenderVideoEngineMediatorDelegate shareInstance]];
    }
    return self;
}

- (void)dealloc {
    [self removeObserver];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    VEPlayerContextDIUnBind(VEVideoPlayback, self.context);
    VEPlayerContext *playerContext = self.context;
    VEPlayerContextRunOnMainThread(^{
        [playerContext removeAllHandler];
    });
    [self.interaction removeAllModules];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self configuratoinCustomView];
    [self registerScreenCapturedDidChangeNotification];
    
    if (self.interaction) {
        self.interaction.playerVCView = self.view;
        self.interaction.playerContainerView = self.playerContainerView;
        [self.interaction viewDidLoad]; //分发生命周期
    }

    if (self.playerConfig.enablePip) {
        [VEVideoPlayerPipController shared];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}

- (void)createVideoEngine:(id<TTVideoEngineMediaSource> _Nonnull)mediaSource needPrerenderEngine:(BOOL)needPrerender {
    if (_videoEngine == nil) {
        @weakify(self);
        [[VEVideoEnginePool shareInstance] createVideoEngine:mediaSource needPrerenderEngine:needPrerender block:^(TTVideoEngine * _Nullable engine, VECreateEngineFrom engineFrom) {
            @strongify(self);
			// Pip
			[engine setOptionForKey:VEKKeyPlayerLoopWay_NSInteger value:@1];
			[engine setSupportPictureInPictureMode:YES];

            self.videoEngine = engine;
            self.engineFrom = engineFrom;
            if (self.playerConfig.enablePip) {
                [self.videoEngine setVideoWrapper:[[VEVideoPlayerPipController shared] createVideoWrapper:self]];
            }
            if (engineFrom == VECreateEngineFrom_Init) {
                [self.videoEngine setVideoEngineVideoSource:mediaSource];
            } else {
                self.playbackState = [self __getPlaybackState:self.videoEngine.playbackState];
                self.loadState = [self __getLoadState:self.videoEngine.loadState];
                [self.context post:@(self.playbackState) forKey:VEPlayerContextKeyPlaybackState];
            }
        }];
    }
    _mediaSource = mediaSource;
    [self configurationVideoEngine];
}

#pragma mark - Pip

- (void)__setupPipEnv {
	[self __setupDisplayerView];
	[self __setupPipController];
	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didBecomeActiveNotification:)
												 name: UIApplicationDidBecomeActiveNotification
											   object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(didLockScreen:)
												 name:UIApplicationProtectedDataWillBecomeUnavailable
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(didUnLockScreen:)
												 name:UIApplicationProtectedDataDidBecomeAvailable
											   object:nil];

    @weakify(self);
    [self.context addKey:VEPlayerContextKeySwitchPictureInPicture withObserver:self handler:^(NSNumber *pipActived, NSString *key) {
        @strongify(self);
        [self switchPip];
        if ([pipActived integerValue] == 0) {
            [[UIApplication sharedApplication] performSelector:NSSelectorFromString(@"suspend")];
        }
    }];
}

- (void)__setupDisplayerView {
    [[VEVideoPlayerPipController shared].displayView removeFromSuperview];
    [[VEVideoPlayerPipController shared].displayLayer flushAndRemoveImage];
    [self.view insertSubview:[VEVideoPlayerPipController shared].displayView aboveSubview:self.posterImageView];
    [[VEVideoPlayerPipController shared].displayView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

- (void)__setupPipController {
	[self __updateAudioSession];

    [VEVideoPlayerPipController shared].delegate = self;
    [[VEVideoPlayerPipController shared] invalidatePlaybackState];
}

- (void)__unsetPipController {
    if (@available(iOS 15.0, *)) {
        [[VEVideoPlayerPipController shared] stopPip];
        [[VEVideoPlayerPipController shared] invalidatePlaybackState];
    }
}

- (void)__updateAudioSession {
	AVAudioSession *audioSession = [AVAudioSession sharedInstance];
	NSError *categoryError = nil;
	[audioSession setCategory:AVAudioSessionCategoryPlayback
						 mode:AVAudioSessionModeMoviePlayback
					  options:AVAudioSessionCategoryOptionOverrideMutedMicrophoneInterruption error:&categoryError];
	if (categoryError) {
		NSLog(@"volc--set audio session category error: %@", categoryError.localizedDescription);
	}
	NSError *activeError = nil;
	[audioSession setActive:YES error:&activeError];
	if (activeError) {
		NSLog(@"volc--set audio session active error: %@", activeError.localizedDescription);
	}
}

- (void)preparePip {
    if (self.playerConfig.enablePip) {
        [VEVideoPlayerPipController shared].currentController = self;
        [self __setupPipEnv];
    }
}

- (void)switchPip {
    if (@available(iOS 15.0, *)) {
        if (self.playerConfig.enablePip) {
            if ([[VEVideoPlayerPipController shared] isPipActive]) {
                [[VEVideoPlayerPipController shared] stopPip];
            } else {
                [[VEVideoPlayerPipController shared] startPip];
            }
        }
    } else {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Tips"
                                                                                message:@"Only Support iOS15+"
                                                                         preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

#pragma mark - notification handlers
- (void)didBecomeActiveNotification:(NSNotification *)notification {
    NSLog(@"volc--didBecomeActive");
    if (self.playerConfig.enablePip) {
        [[VEVideoPlayerPipController shared] stopPip];
        [[VEVideoPlayerPipController shared] invalidatePlaybackState];
    }
}

- (void)didLockScreen:(NSNotificationCenter *)notification {
	if (self.playerConfig.enablePip) {
		[self __unsetPipController];
		[self pause];
	}
	NSLog(@"volc--didLockScreen");

}
- (void)didUnLockScreen:(NSNotificationCenter *)notification {
	if (self.playerConfig.enablePip) {
		[self __setupPipController];
	}
	NSLog(@"volc--didUnLockScreen");
}

#pragma mark - VEVideoPlayerPipControllerDelegate

- (void)willStartPictureInPicture {
    [self.context post:@(1) forKey:VEPlayerContextKeyPictureInPictureStateChanged];
}

- (void)didStopPictureInPicture {
    [self.context post:@(0) forKey:VEPlayerContextKeyPictureInPictureStateChanged];
}

- (VEVideoPlaybackState)getPlaybackState {
    return self.playbackState;
}

- (void)setPlaying:(BOOL)playing {
    if (playing) {
        // 如果当前已播放完毕、未起播或出错，重播
        // 如果当前处于播放状态，跳过
        // 如果当前处于暂停状态，续播
        if (self.playbackState == VEVideoPlaybackStateStopped || self.playbackState == VEVideoPlaybackStateUnkown || self.playbackState == VEVideoPlaybackStateError) {
            [self playWithMediaSource:self.mediaSource];
        } else if (self.playbackState == VEVideoPlaybackStatePaused) {
            [self play];
        }
    } else {
        [self pause];
    }
    [[VEVideoPlayerPipController shared] invalidatePlaybackState];
}

- (NSInteger)getDuration {
    return (NSInteger)(self.videoEngine.duration);
}

- (NSInteger)getPosition {
    return (NSInteger)self.videoEngine.currentPlaybackTime;
}

- (void)configurationVideoEngine {
    [self __configPlayerScaleMode:self.videoEngine viewMode:self.playerConfig.videoViewMode];
    self.audioMode = self.playerConfig.audioMode;
    self.muted = self.playerConfig.muted;
    self.looping = self.playerConfig.looping;
    self.playbackRate = self.playerConfig.playbackRate;
    if (self.playerConfig.startTime > 0) {
        self.startTime = self.playerConfig.startTime;
    }
    if (@available(iOS 14.0, *)) {
        if (self.playerConfig.isSupportPictureInPictureMode && self.playerConfig.enablePip) {
            [self.videoEngine setSupportPictureInPictureMode:YES];
        }
    }
    [self.videoEngine setOptionForKey:VEKKeyPlayerHardwareDecode_BOOL value:@(self.playerConfig.isOpenHardware)];
    [self.videoEngine setOptionForKey:VEKKeyPlayerh265Enabled_BOOL value:@(self.playerConfig.isH265)];
    [self.videoEngine setOptionForKey:VEKKeyPlayerIdleTimerAuto_NSInteger value:@(YES)];
    [self.videoEngine setOptionForKey:VEKKeyPlayerSeekEndEnabled_BOOL value:@(YES)];
    // open super resolution
    if (self.playerConfig.isOpenSR && [self.videoEngine isSupportSR]) {
        self.superResolutionEnable = YES;
        [self.videoEngine setOptionForKey:VEKKeyPlayerEnableAllResolutionSR_BOOL value:@(YES)];
        [self.videoEngine setOptionForKey:VEKKeyPlayerEnableNNSR_BOOL value:@(YES)];
        [self.videoEngine setOptionForKey:VEKKeyIsEnableVideoBmf_BOOL value:@(YES)];
        [self.videoEngine setOptionForKey:VEKKeyIsEnableEnsureSRGetFirstFrame value:@(YES)];
    }
    
    self.videoEngine.delegate = self;
    self.videoEngine.resolutionDelegate = self;
    self.videoEngine.dataSource = self;
    
    [self.videoEngine configResolution:[VEVideoPlayerController getPlayerCurrentResolution]];
    
    /// add observer
    [self addObserver];

    [self setupSubtitle];
}

#pragma mark - UI

- (void)configuratoinCustomView {
    self.view.backgroundColor = [UIColor blackColor];
    
    [self.view addSubview:self.posterImageView];
    [self.posterImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

- (void)reLayoutVideoPlayerView {
    // 如果之前曾用prerender video engine做为封面图，但因个别情况其media source与
    // 即将播放的media source不同，则先移除之前的prerender video engine，防止其遮挡
    // 真正的video engine
    for (UIView *view in self.view.subviews) {
        if ([view isKindOfClass:[self.videoEngine.playerView class]] && view != self.videoEngine.playerView) {
            [view removeFromSuperview];
            break;
        }
    }
    self.videoEngine.playerView.clipsToBounds = YES;
    [self.view insertSubview:self.videoEngine.playerView aboveSubview:self.posterImageView];
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
            preRenderVideoEngine.playerView.clipsToBounds = YES;
            [self __configPlayerScaleMode:preRenderVideoEngine viewMode:_videoViewMode];
            [self.view insertSubview:preRenderVideoEngine.playerView aboveSubview:self.posterImageView];
            [preRenderVideoEngine.playerView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self.view);
            }];
            BTDLog(@"EngineStrategy: ===== backgroud image use pre render video engine view");
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
    [[VEVideoEnginePool shareInstance] removeVideoEngine:self.mediaSource];
    [self.videoEngine.playerView removeFromSuperview];
    [self.videoEngineDebugTool remove];
    [self.videoEngine closeAysnc];
    [self.videoEngine removeTimeObserver];
    self.videoEngine = nil;
}

- (void)__addPeriodicTimeObserver {
    @weakify(self);
    [self.videoEngine addPeriodicTimeObserverForInterval:0.3f queue:dispatch_get_main_queue() usingBlock:^{
        if ([weak_self.receiver respondsToSelector:@selector(playerCore:playTimeDidChanged:info:)]) {
            [weak_self.receiver playerCore:weak_self playTimeDidChanged:weak_self.currentPlaybackTime info:@{}];
        }
    }];
}

- (void)configStartTime:(id<TTVideoEngineMediaSource> _Nonnull)mediaSource {
    NSInteger retStartTime = 0;
    if (mediaSource.sourceType == TTVideoEngineSourceTypeVideoId) {
        retStartTime = [(TTVideoEngineVidSource *)mediaSource startTime];
    } else if (mediaSource.sourceType == TTVideoEngineSourceTypeDirectUrl) {
        retStartTime = [(TTVideoEngineUrlSource *)mediaSource startTime];
    }
    if (retStartTime > 0) {
        self.startTime = retStartTime;
    }
}

#pragma mark - Player control

- (void)setMediaSource:(id<TTVideoEngineMediaSource> _Nonnull)mediaSource {
    _mediaSource = mediaSource;
    [self createVideoEngine:mediaSource needPrerenderEngine:NO];
    [self reLayoutVideoPlayerView];
}

- (void)setupSubtitle {
    if (!self.playerConfig.enableSubtitle) {
        return;
    }

    [self.videoEngine setOptionForKey:VEKeyPlayerEnableSubThread_BOOL value:@(YES)];
    [self.videoEngine setOptionForKey:VEKKeyPlayerSubtitleOptEnable_BOOL value:@(YES)];
    [self.videoEngine setOptionForKey:VEKKeyPlayerSubEnabled_BOOL value:@(YES)];
    [self.videoEngine setOptionForKey:VEKKeySubTitleEnableMDL_BOOL value:@(YES)];

    [self.videoEngine setSubtitleDelegate:self];

    if (self.playerConfig.subtitleSourceType == VEPlayerKitSubtitleSourceDirectUrl) {
        [self.videoEngine setSubDecInfoModel:self.subtitleInfoModel];
        [self.videoEngine setOptionForKey:VEKeyPlayerSwitchSubtitleId_NSInteger value:@(self.subtitleId)];
    } else if (self.playerConfig.subtitleSourceType == VEPlayerKitSubtitleSourceAuthToken) {
        [self.videoEngine setSubtitleAuthToken:self.subtitleAuthToken];
    }
}

- (void)setSubtitleAuthToken:(NSString *)subtitleAuthToken {
    _subtitleAuthToken = subtitleAuthToken;
}

- (void)setSubtitleInfoModel:(TTVideoEngineSubDecInfoModel *)subtitleInfoModel {
    _subtitleInfoModel = subtitleInfoModel;
}

- (void)setSubtitleId:(NSInteger)subtitleId {
    _subtitleId = subtitleId;
}

- (void)loadBackgourdImageWithMediaSource:(id<TTVideoEngineMediaSource> _Nonnull)mediaSource {
    [self __setBackgroudImageForMediaSource:mediaSource];
}

- (void)playWithMediaSource:(id<TTVideoEngineMediaSource> _Nonnull)mediaSource {
    [self createVideoEngine:mediaSource needPrerenderEngine:self.preRenderOpen];
    [self reLayoutVideoPlayerView];
    [self play];
    
    [self __addPeriodicTimeObserver];
}

- (void)prepareToPlay {
    BTDAssertMainThread();
    VEPlayerContextRunOnMainThread(^{
        [self.videoEngine prepareToPlay];
    });
}

- (void)play {
    BTDAssertMainThread();
    VEPlayerContextRunOnMainThread(^{
        if (@available(iOS 11.0, *)) {
            if ([[[[UIApplication sharedApplication] keyWindow] screen] isCaptured]) {
                [self showRecordScreenView];
                return;
            }
        }
        [self __handleBeforePlayAction];
        [self.videoEngine play];
        [self _handleAfterPlayAction];
        [self __addPeriodicTimeObserver];
        
        if (self.playerConfig.enableLoadSpeed) {
            [TTVideoEngine ls_setPreloadDelegate:self];
        }
    });
}

- (void)pause {
    BTDAssertMainThread();
    VEPlayerContextRunOnMainThread(^{
        [self.context post:@(YES) forKey:VEPlayerContextKeyPauseAction];
        [self.videoEngine pause];
	});
}

- (void)seekToTime:(NSTimeInterval)time
          complete:(void(^ _Nullable)(BOOL success))finised
    renderComplete:(void(^ _Nullable)(void)) renderComplete {
    BTDAssertMainThread();
    VEPlayerContextRunOnMainThread(^{
        [self.videoEngine setCurrentPlaybackTime:time complete:finised renderComplete:renderComplete];
    });
}

- (void)stop {
    BTDAssertMainThread();
    VEPlayerContextRunOnMainThread(^{
        [self.context post:@(YES) forKey:VEPlayerContextKeyStopAction];
        [self.videoEngine stop];
        [self __closeVideoPlayer];
    });
}

- (void)close {
    [self.videoEngine closeAysnc];
    [self __closeVideoPlayer];
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
    [self.context post:@(playbackVolume) forKey:VEPlayerContextKeyVolumeChanged];
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

#pragma mark - TTVideoEnginePreloadDelegate

- (void)localServerTestSpeedInfo:(NSTimeInterval)timeInternalMs size:(NSInteger)sizeByte {
    NSTimeInterval time = timeInternalMs / 1000;
    CGFloat dataSize = sizeByte / 1024;
    self.netWorkSpeed = dataSize / time;
}

#pragma mark - TTVideoEngineDelegate

- (void)videoEnginePrepared:(TTVideoEngine *)videoEngine {
    if (self.delegate &&[self.delegate respondsToSelector:@selector(videoPlayerPrepared:)]) {
        [self.delegate videoPlayerPrepared:self];
    }
    if ([self.receiver respondsToSelector:@selector(playerCore:resolutionChanged:info:)]) {
        [self.receiver playerCore:self resolutionChanged:self.currentResolution info:@{}];
    }
    [self.context post:@(YES) forKey:VEPlayerContextKeyEnginePrepared];
}

- (void)videoEngineReadyToDisPlay:(TTVideoEngine *)videoEngine {
    self.videoEngine.playerView.hidden = NO;
    if (self.delegate && [self.delegate respondsToSelector:@selector(videoPlayerReadyToDisplay:)]) {
        [self.delegate videoPlayerReadyToDisplay:self];
    }
    [self.context post:@(YES) forKey:VEPlayerContextKeyReadyForDisplay];
}

- (void)videoEngineReadyToPlay:(TTVideoEngine *)videoEngine {
    [self.context post:@(YES) forKey:VEPlayerContextKeyReadyToPlay];
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
    if (loadState == TTVideoEngineLoadStatePlayable) {
        [[VEVideoPlayerPipController shared] invalidatePlaybackState];
    }
}

- (void)videoEngine:(TTVideoEngine *)videoEngine mdlKey:(NSString *)key hitCacheSze:(NSInteger)cacheSize {
    if (self.delegate && [self.delegate respondsToSelector:@selector(videoPlayer:key:hitVideoPreloadDataSize:)]) {
        [self.delegate videoPlayer:self key:key hitVideoPreloadDataSize:cacheSize];
    }
    BTDLog(@"EngineStrategy: ===== hitCacheSze %@, vid = %@", @(cacheSize), [self.mediaSource getUniqueId]);
}

- (void)videoEngine:(TTVideoEngine *)videoEngine subtitleKey:(NSString *)key subtitleHitCacheSize:(NSInteger)cacheSize {
    BTDLog(@"subtitle hit cache: key=%@, size=%ld", key, cacheSize);
}

- (void)videoEngineUserStopped:(TTVideoEngine *)videoEngine {
    [self __handlePlayFinishStateChange:VEVideoPlayFinishStatusType_UserFinish error:nil];
}

- (void)videoEngineDidFinish:(TTVideoEngine *)videoEngine error:(nullable NSError *)error {
    [self __handlePlayFinishStateChange:VEVideoPlayFinishStatusType_SystemFinish error:error];
}

- (void)videoEngineDidFinish:(TTVideoEngine *)videoEngine videoStatusException:(NSInteger)status {
    NSError *error = [NSError errorWithDomain:@"VEPlayerSourceException" code:status userInfo:nil];
    [self __handlePlayFinishStateChange:VEVideoPlayFinishStatusType_SystemFinish error:error];
}

- (void)videoEngineCloseAysncFinish:(TTVideoEngine *)videoEngine {
    if (![self.videoEngine isEqual:videoEngine]) {
        /// 异步销毁后如果换了ve就不要继续往下走了
        return;
    }
    [self __handlePlayFinishStateChange:VEVideoPlayFinishStatusType_CloseAnsync error:nil];
}

- (void)videoEngineStalledExcludeSeek:(TTVideoEngine *)videoEngine {
    
}

- (void)videoEngineBeforeViewRemove:(TTVideoEngine *)videoEngine {
    
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

#pragma mark - TTVideoEngineSubtitleDelegate
- (void)videoEngine:(TTVideoEngine *)videoEngine onSubtitleInfoCallBack:(NSString *)content pts:(NSUInteger)pts {
    if (self.subtitleDelegate && [self.subtitleDelegate respondsToSelector:@selector(videoPlayerController:onSubtitleTextUpdated:)]) {
        [self.subtitleDelegate videoPlayerController:self onSubtitleTextUpdated:content];
    }
}

- (void)videoEngine:(TTVideoEngine *)videoEngine onSubtitleInfoCallBack:(TTVideoEngineSubInfo *)subInfo {

}

- (void)videoEngine:(TTVideoEngine *)videoEngine onSubtitleInfoRequestFinish:(TTVideoEngineSubDecInfoModel *)subtitleInfoModel error:(NSError * _Nullable)error {
    if (self.subtitleDelegate && [self.subtitleDelegate respondsToSelector:@selector(videoPlayerController:onSubtitleRequestFinished:error:)]) {
        [self.subtitleDelegate videoPlayerController:self onSubtitleRequestFinished:subtitleInfoModel error:error];
    }
    if (!subtitleInfoModel) {
        return;
    }
    if (self.subtitleDelegate && [self.subtitleDelegate respondsToSelector:@selector(getMatchedSubtitleId:)]) {
        NSInteger subtitleId = [self.subtitleDelegate getMatchedSubtitleId:subtitleInfoModel];
        [videoEngine setOptionForKey:VEKeyPlayerSwitchSubtitleId_NSInteger value:@(subtitleId)];
    }
}

- (void)videoEngine:(TTVideoEngine *)videoEngine onSubSwitchCompleted:(BOOL)success currentSubtitleId:(NSInteger)currentSubtitleId {
    if (self.subtitleDelegate && [self.subtitleDelegate respondsToSelector:@selector(videoPlayerController:onSubtitleChanged:)]) {
        [self.subtitleDelegate videoPlayerController:self onSubtitleChanged:currentSubtitleId];
    }
}

- (void)videoEngine:(TTVideoEngine *)videoEngine onSubLoadFinished:(BOOL)success info:(TTVideoEngineLoadInfo * _Nullable)info {
    if (self.subtitleDelegate && [self.subtitleDelegate respondsToSelector:@selector(videoPlayerController:onSubtitleLoadFinished:)]) {
        [self.subtitleDelegate videoPlayerController:self onSubtitleLoadFinished:success];
    }
}

#pragma mark - Private

- (void)__handleBeforePlayAction {
    [self.context post:@(YES) forKey:VEPlayerContextKeyBeforePlayAction];
}

- (void)_handleAfterPlayAction {
    [self.context post:@(YES) forKey:VEPlayerContextKeyPlayAction];
}

- (void)__handlePlaybackStateChanged:(VEVideoPlaybackState)state {
    self.playbackState = state;
    switch (state) {
        case VEVideoPlaybackStatePlaying: {
			NSLog(@"volc--state VEVideoPlaybackStatePlaying");
            self.videoEngine.playerView.hidden = NO;
        }
            break;
        case VEVideoPlaybackStatePaused: {
			NSLog(@"volc--state VEVideoPlaybackStatePaused");
        }
            break;
        case VEVideoPlaybackStateStopped: {
			NSLog(@"volc--state VEVideoPlaybackStateStopped");
        }
            break;
        case VEVideoPlaybackStateError: {
			NSLog(@"volc--state VEVideoPlaybackStateError");
            [self showTips:NSLocalizedStringFromTable(@"tip_play_error_normal", @"VodLocalizable", nil)];
        }
            break;
        default:
            break;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(videoPlayer:playbackStateDidChange:)]) {
        [self.delegate videoPlayer:self playbackStateDidChange:self.playbackState];
    }
    [self.context post:@(self.playbackState) forKey:VEPlayerContextKeyPlaybackState];
	if (self.playerConfig.enablePip) {
        [[VEVideoPlayerPipController shared] invalidatePlaybackState];
	}
}

- (void)__handleLoadStateChanged:(VEVideoLoadState)state {
    self.loadState = state;
    if (self.delegate && [self.delegate respondsToSelector:@selector(videoPlayer:loadStateDidChange:)]) {
        [self.delegate videoPlayer:self loadStateDidChange:self.loadState];
    }
    [self.context post:@(state) forKey:VEPlayerContextKeyLoadState];
}

- (void)__handlePlayFinishStateChange:(VEVideoPlayFinishStatusType)finishState error:(NSError *)error {
    VEPlayFinishStatus *finishStatus = [[VEPlayFinishStatus alloc] init];
    finishStatus.finishState = finishState;
    finishStatus.error = error;
    if (self.delegate && [self.delegate respondsToSelector:@selector(videoPlayer:didFinishedWithStatus:)]) {
        [self.delegate videoPlayer:self didFinishedWithStatus:finishStatus];
    }
    [self.context post:finishStatus forKey:VEPlayerContextKeyPlaybackDidFinish];
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

- (void)__configPlayerScaleMode:(TTVideoEngine *)videoEngine viewMode:(VEVideoViewMode)videoViewMode {
    switch (videoViewMode) {
        case VEVideoViewModeAspectFit: {
            [videoEngine setOptionForKey:VEKKeyViewScaleMode_ENUM value:@(TTVideoEngineScalingModeAspectFit)];
            self.posterImageView.contentMode = UIViewContentModeScaleAspectFit;
        }
            break;
        case VEVideoViewModeAspectFill: {
            [videoEngine setOptionForKey:VEKKeyViewScaleMode_ENUM value:@(TTVideoEngineScalingModeAspectFill)];
            self.posterImageView.contentMode = UIViewContentModeScaleAspectFill;
        }
            break;
        case VEVideoViewModeModeFill: {
            [videoEngine setOptionForKey:VEKKeyViewScaleMode_ENUM value:@(TTVideoEngineScalingModeFill)];
            self.posterImageView.contentMode = UIViewContentModeScaleToFill;
        }
            break;
        default: {
            [videoEngine setOptionForKey:VEKKeyViewScaleMode_ENUM value:@(TTVideoEngineScalingModeNone)];
            self.posterImageView.contentMode = UIViewContentModeScaleAspectFit;
        }
            break;
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
    _videoViewMode = videoViewMode;
    [self __configPlayerScaleMode:self.videoEngine viewMode:_videoViewMode];
}

- (void)setStartTime:(NSTimeInterval)startTime {
    _startTime = startTime;
    if (self.engineFrom == VECreateEngineFrom_Init) {
        [self.videoEngine setOptionForKey:VEKKeyPlayerStartTime_CGFloat value:@(startTime)];
    } else {
        [self seekToTime:startTime complete:nil renderComplete:nil];
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
        _posterImageView.contentMode = UIViewContentModeScaleAspectFill;
        _posterImageView.clipsToBounds = YES;
    }
    return _posterImageView;
}

@end
