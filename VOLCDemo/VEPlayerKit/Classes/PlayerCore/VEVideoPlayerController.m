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
#import "ShortDramaDetailPlayerModuleLoader.h"
#import "VEVideoEnginePool.h"
#import "BTDMacros.h"
#import <AVKit/AVKit.h>

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

- (void)videoEngineWillPrepare:(TTVideoEngine *)videoEngine {
    
}

- (void)videoEngine:(TTVideoEngine *)videoEngine willPreRenderSource:(id<TTVideoEngineMediaSource>)source {
    
}

@end


@interface VEVideoPlayerController () <
VEVideoPlaybackDelegate,
TTVideoEngineDelegate,
TTVideoEngineDataSource,
TTVideoEngineResolutionDelegate,
TTVideoEnginePreloadDelegate,
AVPictureInPictureControllerDelegate,
AVPictureInPictureSampleBufferPlaybackDelegate>

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

// Pip
@property (nonatomic, strong) AVPictureInPictureController *pipController;
@property (nonatomic, strong) AVSampleBufferDisplayLayer *displayLayer;
@property (nonatomic, strong) VEVideoPlayerDisplayView *displayView;

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
		[self __setupPipEnv];
	}
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	[self __resetPipController];
	[self __resetDisplayView];
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
	
	if (self.playerConfig.enablePip) {
		[self __startObserveVideoFrame];
	}
}

#pragma mark - Pip

- (void)__setupPipEnv {
	[self __setupDisplayerView];
	[self __setupPipController];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(didBecomeActiveNotification)
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
}

- (void)__setupDisplayerView {
	self.displayView = [[VEVideoPlayerDisplayView alloc] init];
	self.displayView.userInteractionEnabled = NO;
	self.displayView.clipsToBounds = YES;
	self.displayLayer = (AVSampleBufferDisplayLayer *)self.displayView.layer;
	self.displayLayer.opaque = YES;
	self.displayLayer.videoGravity = AVLayerVideoGravityResizeAspect;
	[self.view insertSubview:self.displayView aboveSubview:self.posterImageView];
	[self.displayView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.edges.equalTo(self.view);
	}];
}

- (void)__resetDisplayView {
	[self.displayView removeFromSuperview];
	[self.displayLayer stopRequestingMediaData];
	self.displayView = nil;
}

- (void)__setupPipController {
	[self __updateAudioSession];
	AVPictureInPictureControllerContentSource *contentSource = [[AVPictureInPictureControllerContentSource alloc] initWithSampleBufferDisplayLayer:self.displayLayer playbackDelegate:self];
	self.pipController = [[AVPictureInPictureController alloc] initWithContentSource:contentSource];
	self.pipController.canStartPictureInPictureAutomaticallyFromInline = YES;
	self.pipController.requiresLinearPlayback = YES;
	self.pipController.delegate = self;
}

- (void)__resetPipController {
	if (@available(iOS 15.0, *)) {
		[self.pipController stopPictureInPicture];
		[self.pipController invalidatePlaybackState];
		self.pipController = nil;
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

- (void)__startObserveVideoFrame {
	EngineVideoWrapper *wrapper = malloc(sizeof(EngineAudioWrapper));
	wrapper->process = process;
	wrapper->release = release;
	wrapper->context = (__bridge void *)self;
	[self.videoEngine setVideoWrapper:wrapper];
}

- (void)startPip {
	if (self.playerConfig.enablePip) {
		if (self.pipController.isPictureInPictureActive) {
			[self.pipController stopPictureInPicture];
		} else {
			[self.pipController startPictureInPicture];
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

- (void)__dispatchPixelBuffer:(CVPixelBufferRef)pixelBuffer {
	if (!pixelBuffer) {
		return;
	}
	CMSampleTimingInfo timing = {kCMTimeInvalid, kCMTimeInvalid, kCMTimeInvalid};
	CMVideoFormatDescriptionRef videoInfo = NULL;
	OSStatus result = CMVideoFormatDescriptionCreateForImageBuffer(NULL, pixelBuffer, &videoInfo);
	NSParameterAssert(result == 0 && videoInfo != NULL);
	
	CMSampleBufferRef sampleBuffer = NULL;
	result = CMSampleBufferCreateForImageBuffer(kCFAllocatorDefault,pixelBuffer, true, NULL, NULL, videoInfo, &timing, &sampleBuffer);
	NSParameterAssert(result == 0 && sampleBuffer != NULL);
	CFRelease(videoInfo);
	CFArrayRef attachments = CMSampleBufferGetSampleAttachmentsArray(sampleBuffer, YES);
	CFMutableDictionaryRef dict = (CFMutableDictionaryRef)CFArrayGetValueAtIndex(attachments, 0);
	CFDictionarySetValue(dict, kCMSampleAttachmentKey_DisplayImmediately, kCFBooleanTrue);
	[self enqueueSampleBuffer:sampleBuffer toLayer:self.displayLayer];
	CFRelease(sampleBuffer);
}

- (void)enqueueSampleBuffer:(CMSampleBufferRef)sampleBuffer toLayer:(AVSampleBufferDisplayLayer*)layer {
	if (!sampleBuffer || !layer.readyForMoreMediaData) {
		NSLog(@"volc--sampleBuffer invalid");
		return;
	}
	if (@available(iOS 16.0, *)) {
		if (layer.status == AVQueuedSampleBufferRenderingStatusFailed) {
			NSLog(@"volc--sampleBufferLayer error:%@",layer.error);
			[layer flush];
		}
	} else {
		[layer flush];
	}
	if (@available(iOS 15.0, *)) {
		[layer enqueueSampleBuffer:sampleBuffer];
	} else {
		VEPlayerContextRunOnMainThread(^{
			[layer enqueueSampleBuffer:sampleBuffer];
		});
	}
}

static void process(void *context, CVPixelBufferRef frame, int64_t timestamp) {
	NSLog(@"volc--frame=%@, ts=%.f", frame, timestamp);
	id ocContext = (__bridge id)context;
	VEVideoPlayerController *controller = ocContext;
	[controller __dispatchPixelBuffer:frame];
}

static void release(void *context) {
	NSLog(@"volc--frame release");
}

- (void)didBecomeActiveNotification {
	NSLog(@"volc--didBecomeActive");
	if (self.playerConfig.enablePip) {
		[self.pipController stopPictureInPicture];
		[self.pipController invalidatePlaybackState];
	}
}

- (void)didLockScreen:(NSNotificationCenter *)notification {
	if (self.playerConfig.enablePip) {
		[self __resetPipController];
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

#pragma mark - AVPictureInPictureControllerDelegate
- (void)pictureInPictureControllerWillStartPictureInPicture:(AVPictureInPictureController *)pictureInPictureController {
	NSLog(@"volc--pictureInPictureControllerWillStartPictureInPicture");
}

- (void)pictureInPictureControllerDidStartPictureInPicture:(AVPictureInPictureController *)pictureInPictureController {
	NSLog(@"volc--pictureInPictureControllerDidStartPictureInPicture");
}

- (void)pictureInPictureController:(AVPictureInPictureController *)pictureInPictureController
failedToStartPictureInPictureWithError:(NSError *)error {
	NSLog(@"volc--failedToStartPictureInPictureWithError");
}

- (void)pictureInPictureController:(AVPictureInPictureController *)pictureInPictureController
restoreUserInterfaceForPictureInPictureStopWithCompletionHandler:(void (^)(BOOL))completionHandler {
	NSLog(@"volc--restoreUserInterfaceForPictureInPictureStopWithCompletionHandler");
	completionHandler(true);
}

- (void)pictureInPictureControllerWillStopPictureInPicture:(AVPictureInPictureController *)pictureInPictureController {
	NSLog(@"volc--pictureInPictureControllerWillStopPictureInPicture");
}

- (void)pictureInPictureControllerDidStopPictureInPicture:(AVPictureInPictureController *)pictureInPictureController {
	NSLog(@"volc--pictureInPictureControllerDidStopPictureInPicture");
}


#pragma mark - AVPictureInPictureSampleBufferPlaybackDelegate
- (BOOL)pictureInPictureControllerIsPlaybackPaused:(nonnull AVPictureInPictureController *)pictureInPictureController {
	NSLog(@"volc--pictureInPictureControllerIsPlaybackPaused");
	return self.playbackState != VEVideoPlaybackStatePlaying;
}

- (CMTimeRange)pictureInPictureControllerTimeRangeForPlayback:(AVPictureInPictureController *)pictureInPictureController {
	NSLog(@"volc--pictureInPictureControllerTimeRangeForPlayback");
	// 需要在初始化时预设视频时长(从播放器读取有延迟)，此处以10min为例
	return CMTimeRangeMake(kCMTimeZero, CMTimeMakeWithSeconds(10 * 60, NSEC_PER_SEC));
}

- (void)pictureInPictureController:(AVPictureInPictureController *)pictureInPictureController
		 didTransitionToRenderSize:(CMVideoDimensions)newRenderSize {
	NSLog(@"volc--didTransitionToRenderSize");
}

- (void)pictureInPictureController:(AVPictureInPictureController *)pictureInPictureController setPlaying:(BOOL)playing {
	NSLog(@"volc--pictureInPictureController setPlaying");
	if (playing) {
		[self.videoEngine play];
	} else {
		[self.videoEngine pause];
	}
	[self.pipController invalidatePlaybackState];
}

- (void)pictureInPictureController:(AVPictureInPictureController *)pictureInPictureController
					skipByInterval:(CMTime)skipInterval
				 completionHandler:(void (^)(void))completionHandler {
	NSLog(@"volc--pictureInPictureController skipByInterval");
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
        if (self.playerConfig.isSupportPictureInPictureMode) {
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
}

#pragma mark - UI

- (void)configuratoinCustomView {
    self.view.backgroundColor = [UIColor blackColor];
    
    [self.view addSubview:self.posterImageView];
    [self.posterImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
	
	[self __setupDisplayerView];
}

- (void)reLayoutVideoPlayerView {
	if (!self.playerConfig.enablePip) {
		self.videoEngine.playerView.clipsToBounds = YES;
		[self.view insertSubview:self.videoEngine.playerView aboveSubview:self.posterImageView];
		[self.videoEngine.playerView mas_makeConstraints:^(MASConstraintMaker *make) {
			make.edges.equalTo(self.view);
		}];
	}
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
}

- (void)videoEngine:(TTVideoEngine *)videoEngine mdlKey:(NSString *)key hitCacheSze:(NSInteger)cacheSize {
    if (self.delegate && [self.delegate respondsToSelector:@selector(videoPlayer:key:hitVideoPreloadDataSize:)]) {
        [self.delegate videoPlayer:self key:key hitVideoPreloadDataSize:cacheSize];
    }
    BTDLog(@"EngineStrategy: ===== hitCacheSze %@, vid = %@", @(cacheSize), [self.mediaSource getUniqueId]);
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
		[self.pipController invalidatePlaybackState];
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
