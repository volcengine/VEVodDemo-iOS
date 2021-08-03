//
//  VOLCVideoPlayer.m
//  VOLCDemo
//
//  Created by wangzhiyong on 2021/5/27.
//  Copyright © 2021 ByteDance. All rights reserved.
//

#import "VOLCVideoPlayer.h"
#import <TTSDK/TTVideoEngineHeader.h>
#import <TTSDK/TTVideoEngineDebugTools.h>
#import <TTSDK/TTVideoEngine+Mask.h>
#import <TTSDK/TTVideoEngine+Preload.h>
#import "VOLCUserGlobalConfiguration.h"
#import <TTSDK/TTVideoEngineDebugTools.h>
#import <Reachability/Reachability.h>
#import "NSString+VOLC.h"

@interface VOLCVideoPlayer () <TTVideoEngineDelegate, TTVideoEngineDataSource>

@property (nonatomic, strong) TTVideoEngine *videoEngine;
@property (nonatomic, strong, readwrite) UIView *playerView;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *videoId;
@property (nonatomic, copy) NSString *playAuthToken;
@property (nonatomic, assign, readwrite) VOLCVideoPlaybackState playbackState;
@property (nonatomic, assign, readwrite) VOLCVideoLoadState loadState;
@property (nonatomic, assign) BOOL needResumePlay;

@property (nonatomic, strong) TTVideoEngineDebugTools *videoEngineDebugTool; // debug tool

@end

@implementation VOLCVideoPlayer

- (void)dealloc {
    [self removeObserver];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self configurationVideoEngine];
        [self addObserver];
        [[Reachability reachabilityForInternetConnection] startNotifier];
    }
    return self;
}

- (void)configurationVideoEngine {
    TTVideoEngine* engine = [[TTVideoEngine alloc] initWithOwnPlayer:YES];
    self.videoEngine = engine;
    self.videoEngine.delegate = self;
    self.videoEngine.reportLogEnable = YES;
    self.videoEngine.dataSource = self;
    [self.videoEngine configResolution:TTVideoEngineResolutionTypeHD];
    self.playerView = self.videoEngine.playerView;

    [TTVideoEngine startSpeedPredictor:NetworkPredictAlgoTypeHECNET interval:100];
    [TTVideoEngine ls_setSpeedInfoCallback:^(int64_t timeIntervalMs, int64_t size, NSString * _Nonnull type, NSString * _Nonnull key) {
//        NSLog(@"timeIntervalMs: %lld, size: %lld, speed: %f", timeIntervalMs, size, ((float)size / (float)timeIntervalMs));
    }];
    
    [self __configPlayerSetttings];
}

#pragma mark - Public Method

- (void)setVideoId:(NSString *)videoId
     playAuthToken:(NSString *)playAuthToken {
    self.videoId = videoId;
    self.playAuthToken = playAuthToken;
    
    [self __configMDLOptionBeforePlay];
    [self.videoEngine setPlayAuthToken:playAuthToken];
    [self.videoEngine setVideoID:videoId];
}

- (void)setContentUrl:(NSString *)url {
    [self __configMDLOptionBeforePlay];
    [self.videoEngine ls_setDirectURL:url key:url.vloc_md5String];
}

- (void)prepareToPlay {
    [self.videoEngine prepareToPlay];
}

- (void)play {
    [self.videoEngine play];
}

- (void)pause {
    [self.videoEngine pause];
}

- (void)stop {
    [self.videoEngine stop];
}

- (void)close {
    [self.videoEngine closeAysnc];
}

- (BOOL)isPlaying {
    return (self.playbackState == VOLCVideoPlaybackStatePlaying);
}

- (BOOL)isPause {
    return (self.playbackState == VOLCVideoPlaybackStatePaused);
}

- (void)seekToTime:(NSTimeInterval)time
          complete:(void(^)(BOOL success))finish {
    [self.videoEngine setCurrentPlaybackTime:time complete:^(BOOL success) {
        if (finish) {
            finish(success);
        }
    }];
}

- (void)seekToTime:(NSTimeInterval)time
          complete:(void(^)(BOOL success))finised
    renderComplete:(void(^)(void))renderComplete {
    @weakify(self);
    [self.videoEngine setCurrentPlaybackTime:time complete:^(BOOL success) {
        @strongify(self);
        [self.videoEngine setCurrentPlaybackTime:time complete:^(BOOL success) {
            if (finised) {
                finised(success);
            }
        } renderComplete:^{
            if (renderComplete) {
                renderComplete();
            }
        }];
    }];
}

- (void)addPeriodicTimeObserverForInterval:(NSTimeInterval)interval
                                     queue:(dispatch_queue_t)queue
                                usingBlock:(void (^)(void))block {
    [self.videoEngine addPeriodicTimeObserverForInterval:interval queue:queue usingBlock:block];
}

- (void)removeTimeObserver {
    [self.videoEngine removeTimeObserver];
}

- (void)setLogReportEnable:(BOOL)enable {
    self.videoEngine.reportLogEnable = enable;
}

- (void)showDebugViewInView:(UIView *)hudView zIndex:(NSInteger)index {
    [self.videoEngineDebugTool setDebugInfoView:hudView];
    self.videoEngineDebugTool.indexForSuperView = index;
    [self.videoEngineDebugTool start];
}

- (void)removeDebugTool {
    [self.videoEngineDebugTool remove];
}

#pragma mark - Property

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
    return self.muted;
}

- (void)setAudioMode:(BOOL)audioMode {
    self.videoEngine.radioMode = audioMode;
}

- (BOOL)audioMode {
    return self.videoEngine.radioMode;
}

- (void)setHardwareDecode:(BOOL)hardwareDecode {
    self.videoEngine.hardwareDecode = hardwareDecode;
}

- (BOOL)hardwareDecode {
    return self.videoEngine.hardwareDecode;
}

- (void)setLooping:(BOOL)looping {
    self.videoEngine.looping = looping;
}

- (BOOL)looping {
    return self.videoEngine.looping;
}

- (NSTimeInterval)currentPlaybackTime {
    return self.videoEngine.currentPlaybackTime;
}

- (NSTimeInterval)duration {
    return self.videoEngine.duration;
}

- (NSTimeInterval)playableDuration {
    return self.videoEngine.playableDuration;
}

#pragma mark - Pirvate Method

- (void)__configPlayerSetttings {
    if (!self.videoEngine) return;
    VOLCUserGlobalConfiguration *globalConfigs = [VOLCUserGlobalConfiguration sharedInstance];
    
    /// hardware decode,  suggest open
    [self.videoEngine setOptionForKey:VEKKeyPlayerHardwareDecode_BOOL value:@(globalConfigs.isHardDecodeOn)];
    
    /// h265 option
    [self.videoEngine setOptionForKey:VEKKeyPlayerh265Enabled_BOOL value:@(globalConfigs.isH265Enabled)];
    
    /// render engine, suggest use TTVideoEngineRenderEngineMetal
    [self.videoEngine setOptionForKey:VEKKeyViewRenderEngine_ENUM value:@(TTVideoEngineRenderEngineMetal)];
    
    /// async init, suggest open
    [self.videoEngine setOptionForKey:VEKKeyPlayerAsyncInit_BOOL value:@(YES)];
    
    /// Can optimize  the first frame
    [self.videoEngine setOptionForKey:VEKKeyPlayerOpenTimeOut_NSInteger value:@(20)];
    
    /// optimize seek time-consuming, suggest open
    [self.videoEngine setOptionForKey:VEKKeyPlayerPreferNearestSampleEnable value:@(YES)];
    
    /// Can optimize video id to play the first frame
    [self.videoEngine setOptionForKey:VEKKeyModelCacheVideoInfoEnable_BOOL value:@(YES)];
    
    /// report engine log
    self.videoEngine.reportLogEnable = globalConfigs.isEngineReportLog;
}

- (void)__configMDLOptionBeforePlay {
    // config before "setVideoID:"
    [self.videoEngine setOptionForKey:VEKKeyProxyServerEnable_BOOL value:@(YES)];
    [self.videoEngine setOptionForKey:VEKKeyModelCacheVideoInfoEnable_BOOL value:@(YES)];
}

- (void)__handlePlaybackStateChanged:(VOLCVideoPlaybackState)state {
    self.playbackState = state;
    if (self.delegate && [self.delegate respondsToSelector:@selector(player:playbackStateDidChange:)]) {
        [self.delegate player:self playbackStateDidChange:self.playbackState];
    }
}

- (void)__handleLoadStateChanged:(VOLCVideoLoadState)state {
    self.loadState = state;
    if (_delegate && [_delegate respondsToSelector:@selector(player:loadStateDidChange:)]) {
        [_delegate player:self loadStateDidChange:self.loadState];
    }
}

- (VOLCVideoPlaybackState)__getPlaybackState:(TTVideoEnginePlaybackState)state {
    switch (state) {
        case TTVideoEnginePlaybackStatePlaying:
            return VOLCVideoPlaybackStatePlaying;
        case TTVideoEnginePlaybackStatePaused:
            return VOLCVideoPlaybackStatePaused;
        case TTVideoEnginePlaybackStateStopped:
            return VOLCVideoPlaybackStateStopped;
        case TTVideoEnginePlaybackStateError:
            return VOLCVideoPlaybackStateError;
        default:
            return VOLCVideoPlaybackStateUnkown;
    }
}

- (VOLCVideoLoadState)__getLoadState:(TTVideoEngineLoadState)state {
    switch (state) {
        case TTVideoEngineLoadStateUnknown:
            return VOLCVideoLoadStateUnkown;
        case TTVideoEngineLoadStateStalled:
            return VOLCVideoLoadStateStalled;
        case TTVideoEngineLoadStatePlayable:
            return VOLCVideoLoadStatePlayable;
        case TTVideoEngineLoadStateError:
            return VOLCVideoLoadStateError;
        default:
            return VOLCVideoLoadStateUnkown;
    }
}

- (void)__showTip:(NSString *)tip {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.playerView animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.label.text = tip;
    [hud hideAnimated:YES afterDelay:2.0];
}

#pragma mark - Observer

- (void)addObserver {
    [self removeObserver];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(netStatusChanged) name:kReachabilityChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationEnterBackground) name: UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBecomeActiveNotification) name: UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willResignActiveNotification) name: UIApplicationWillResignActiveNotification object:nil];
}

- (void)removeObserver {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
}

- (void)netStatusChanged {
    dispatch_async(dispatch_get_main_queue(), ^{
        switch ([Reachability reachabilityForInternetConnection].currentReachabilityStatus) {
            case NotReachable: {
                [self.videoEngine pause];
                [self __showTip:NSLocalizedString(@"tip_net_not_reachable", nil)];
            }
                break;
                
            case ReachableViaWiFi: {
                [self.videoEngine play];
                [self __showTip:NSLocalizedString(@"tip_net_reachable_wifi", nil)];
            }
                break;
                
            case ReachableViaWWAN: {
                [self.videoEngine play];
                [self __showTip:NSLocalizedString(@"tip_net_reachable_4g", nil)];
            }
                break;
                
            default:
                break;
        }
    });
}

- (void)applicationEnterBackground {
    if ([self isPlaying]) {
        self.needResumePlay = YES;
    }
    [self.videoEngine pause];
}

- (void)willResignActiveNotification {
    if ([self isPlaying]) {
        self.needResumePlay = YES;
    }
    [self.videoEngine pause];
}

- (void)didBecomeActiveNotification {
    if (self.needResumePlay) {
        [self.videoEngine play];
    }
    self.needResumePlay = NO;
}


#pragma mark - TTVideoEngineDelegate

- (void)videoEnginePrepared:(TTVideoEngine *)videoEngine {
    if (self.delegate &&[self.delegate respondsToSelector:@selector(playerPrepared:)]) {
        [self.delegate playerPrepared:self];
    }
}

- (void)videoEngineReadyToDisPlay:(TTVideoEngine *)videoEngine {
    if (self.delegate && [self.delegate respondsToSelector:@selector(readyToDisplay:)]) {
        [self.delegate readyToDisplay:self];
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
    if (_delegate && [_delegate respondsToSelector:@selector(player:key:hitVideoPreloadDataSize:)]) {
        [_delegate player:self key:key hitVideoPreloadDataSize:cacheSize];
    }
}

- (void)videoEngineUserStopped:(TTVideoEngine *)videoEngine {
    [self __handlePlaybackStateChanged:VOLCVideoPlaybackStateFinishedBecauseUser];
}

- (void)videoEngineDidFinish:(TTVideoEngine *)videoEngine error:(nullable NSError *)error {
    if (error) {
        NSLog(@"videoEngineDidFinish with error : %@", [error description]);
        [self __handlePlaybackStateChanged:VOLCVideoPlaybackStateError];
        return;
    }
    [self __handlePlaybackStateChanged:VOLCVideoPlaybackStateFinished];
}

- (void)videoEngineDidFinish:(TTVideoEngine *)videoEngine videoStatusException:(NSInteger)status {
    [self __handlePlaybackStateChanged:VOLCVideoPlaybackStateError];
}

- (void)videoEngineCloseAysncFinish:(TTVideoEngine *)videoEngine {
    [self __handlePlaybackStateChanged:VOLCVideoPlaybackStateFinished];
}


#pragma mark - lazy load

- (TTVideoEngineDebugTools *)videoEngineDebugTool {
    if (!_videoEngineDebugTool) {
        _videoEngineDebugTool = [[TTVideoEngineDebugTools alloc] init];
        _videoEngineDebugTool.debugToolsEnable = YES;
        _videoEngineDebugTool.videoEngine = self.videoEngine;
    }
    return _videoEngineDebugTool;
}

@end
