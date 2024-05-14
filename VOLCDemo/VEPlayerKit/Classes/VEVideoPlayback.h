//
//  VEVideoPlayback.h
//  VOLCDemo
//
//  Created by wangzhiyong on 2021/12/3.
//  Copyright © 2021 ByteDance. All rights reserved.
//

@import Foundation;
#import <TTSDKFramework/TTSDKFramework.h>

typedef NS_ENUM(NSInteger, VEVideoPlaybackState) {
    VEVideoPlaybackStateUnkown = 0,
    VEVideoPlaybackStatePlaying,
    VEVideoPlaybackStatePaused,
    VEVideoPlaybackStateStopped,
    VEVideoPlaybackStateError,
    VEVideoPlaybackStateFinished,
    VEVideoPlaybackStateFinishedBecauseUser
};

typedef NS_ENUM(NSInteger, VEVideoLoadState) {
    VEVideoLoadStateUnkown = 0,
    VEVideoLoadStateStalled,
    VEVideoLoadStatePlayable,
    VEVideoLoadStateError
};

typedef NS_ENUM(NSInteger, VEVideoViewMode) {
    VEVideoViewModeNone = 0,
    VEVideoViewModeAspectFit,
    VEVideoViewModeAspectFill,
    VEVideoViewModeModeFill
};

@protocol VEVideoPlayback;

@protocol VEVideoPlaybackDelegate <NSObject>

@optional

- (void)videoPlayerPrepared:(id<VEVideoPlayback> _Nullable)player;

- (void)videoPlayerReadyToDisplay:(id<VEVideoPlayback> _Nullable)player;

- (void)videoPlayer:(id<VEVideoPlayback> _Nullable)player loadStateDidChange:(VEVideoLoadState)state;

- (void)videoPlayer:(id<VEVideoPlayback> _Nullable)player playbackStateDidChange:(VEVideoPlaybackState)state;

- (void)videoPlayer:(id<VEVideoPlayback> _Nullable)player key:(NSString * _Nullable)key hitVideoPreloadDataSize:(NSInteger)dataSize;

- (void)videoPlayerBitrateDidChange:(id<VEVideoPlayback> _Nullable)player resolution:(TTVideoEngineResolutionType)resolution bitrate:(NSInteger)bitrate;

- (void)videoPlayerViewSizeDidChange:(id<VEVideoPlayback> _Nullable)player videoWidth:(NSInteger)videoWidth videoHeight:(NSInteger)videoHeight;

@end


@protocol VEVideoPlayback <NSObject>

@property (nonatomic, weak, nullable) id<VEVideoPlaybackDelegate> delegate;
@property (nonatomic, strong, nullable, readonly) UIView *playerView;

@property (nonatomic, assign, readonly) NSTimeInterval duration;
@property (nonatomic, assign, readonly) NSTimeInterval currentPlaybackTime;
@property (nonatomic, assign, readonly) NSTimeInterval playableDuration;

@property (nonatomic, assign, readonly) VEVideoPlaybackState playbackState;
@property (nonatomic, assign, readonly) VEVideoLoadState loadState;

@property (nonatomic, assign) VEVideoViewMode videoViewMode;

@property (nonatomic, assign) NSTimeInterval startTime;

@property (nonatomic, assign) CGFloat playbackRate;
@property (nonatomic, assign) CGFloat playbackVolume;

@property (nonatomic, assign) BOOL muted;
@property (nonatomic, assign) BOOL audioMode;
@property (nonatomic, assign) BOOL looping;
@property (nonatomic, strong, nullable) NSString *playerTitle;

/// Set play media source, initialization TTVideoEngine
/// @param mediaSource media source
- (void)setMediaSource:(id<TTVideoEngineMediaSource> _Nonnull)mediaSource;

- (id<TTVideoEngineMediaSource>_Nullable)mediaSource;

/// Reset video engien, initialization TTVideoEngine,  example pre render
/// @param videoEngine  ttsdk video engine
/// @param mediaSource  media source
- (void)resetVideoEngine:(TTVideoEngine * _Nonnull)videoEngine
             mediaSource:(id<TTVideoEngineMediaSource> _Nonnull)mediaSource;

/// Play with media source
/// @param mediaSource media source
- (void)playWithMediaSource:(id<TTVideoEngineMediaSource> _Nonnull)mediaSource;

- (void)prepareToPlay;
- (void)play;
- (void)pause;
- (void)stop;
- (void)close;

- (BOOL)isPlaying;
- (BOOL)isPause;

/// Seek to a given time.
/// @param time the time to seek to, in seconds.
/// @param finised the completion handler
/// @param renderComplete called when seek complete and target time video or audio rendered
- (void)seekToTime:(NSTimeInterval)time
          complete:(void(^ _Nullable)(BOOL success))finised
    renderComplete:(void(^ _Nullable)(void)) renderComplete;

@end




