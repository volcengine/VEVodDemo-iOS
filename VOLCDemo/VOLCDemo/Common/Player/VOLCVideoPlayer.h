//
//  VOLCVideoPlayer.h
//  VOLCDemo
//
//  Created by wangzhiyong on 2021/5/27.
//  Copyright © 2021 ByteDance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TTSDK/TTVideoEngineModel.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, VOLCVideoPlaybackState) {
    VOLCVideoPlaybackStateUnkown = 0,
    VOLCVideoPlaybackStatePlaying,
    VOLCVideoPlaybackStatePaused,
    VOLCVideoPlaybackStateStopped,
    VOLCVideoPlaybackStateError,
    VOLCVideoPlaybackStateFinished,
    VOLCVideoPlaybackStateFinishedBecauseUser
};

typedef NS_ENUM(NSInteger, VOLCVideoLoadState) {
    VOLCVideoLoadStateUnkown = 0,
    VOLCVideoLoadStateStalled,
    VOLCVideoLoadStatePlayable,
    VOLCVideoLoadStateError
};

@class VOLCVideoPlayer;

@protocol VOLCVideoPlayerDelegate <NSObject>

@optional

- (void)playerPrepared:(VOLCVideoPlayer *)player;

- (void)readyToDisplay:(VOLCVideoPlayer *)player;

- (void)player:(VOLCVideoPlayer *)player loadStateDidChange:(VOLCVideoLoadState)state;

- (void)player:(VOLCVideoPlayer *)player playbackStateDidChange:(VOLCVideoPlaybackState)state;

- (void)player:(VOLCVideoPlayer *)player key:(NSString *)key hitVideoPreloadDataSize:(NSInteger)dataSize;

@end


@interface VOLCVideoPlayer : NSObject

/**
 * VOLCVideoPlayer delegate
 */
@property (nonatomic, weak) id<VOLCVideoPlayerDelegate> delegate;

/**
 * Player view
 */
@property (nonatomic, strong, readonly) UIView *playerView;

/**
 * playback rate （ rate >= 0.1, default 1.0）
 */
@property (nonatomic, assign) CGFloat playbackRate;

/**
 * playback volume
 */
@property (nonatomic, assign) CGFloat playbackVolume;

/**
 * muted switch
 */
@property (nonatomic, assign) BOOL muted;

/**
 * audio mode switch
 */
@property (nonatomic, assign) BOOL audioMode;

/**
 * HardwareDecode switch
 */
@property (nonatomic, assign) BOOL hardwareDecode;

/**
 * Loop play mode
 */
@property (nonatomic, assign) BOOL looping;

/**
 * Current playback time
 */
@property (nonatomic, assign, readonly) NSTimeInterval currentPlaybackTime;

/**
 * The video duration
 */
@property (nonatomic, assign, readonly) NSTimeInterval duration;

/**
 * The video playable duration
 */
@property (nonatomic, assign, readonly) NSTimeInterval playableDuration;

/**
 * Current playback state, play or pause
 */
@property (nonatomic, assign, readonly) VOLCVideoPlaybackState playbackState;

/**
 * Current load state, stall or playable
 */
@property (nonatomic, assign, readonly) VOLCVideoLoadState loadState;

/**
 * Debug view, need add to superView and set frame
 */
@property (nonatomic, strong, nullable, readonly) UIView *debugInfoView;

/**
 play with video id and play auth token

 @param videoId video id
 @param playAuthToken playAuthToken
 */
- (void)setVideoId:(NSString *)videoId
     playAuthToken:(NSString *)playAuthToken;

/**
 set play url
 
 @param url url
 */
- (void)setContentUrl:(NSString *)url;

/**
 prepare complate It will not auto play , you need to call play to start playing
 */
- (void)prepareToPlay;

/**
 play
 */
- (void)play;

/**
 pause
 */
- (void)pause;

/**
 stop
 */
- (void)stop;

/**
 close
 */
- (void)close;

/**
 player is playing
 */
- (BOOL)isPlaying;

/**
 player is pause
 */
- (BOOL)isPause;

/**
 seek to a given time.

 @param time the time to seek to, in seconds
 @param finish the completion handler
 */
- (void)seekToTime:(NSTimeInterval)time
          complete:(void(^)(BOOL success))finish;

/**
 seek to a given time.

 @param time the time to seek to, in seconds.
 @param finised the completion handler
 @param renderComplete called when seek complate and target time video or audio rendered
 */
- (void)seekToTime:(NSTimeInterval)time
          complete:(void(^)(BOOL success))finised
    renderComplete:(void(^)(void)) renderComplete;

/**
 It's used to periodicly get something from the player,
 such as current currentPlaybackTime, playableDuration...

 @param interval the time interval in seconds
 @param queue target queue to perform action
 @param block periodic work to do
 */
- (void)addPeriodicTimeObserverForInterval:(NSTimeInterval)interval
                                     queue:(dispatch_queue_t)queue
                                usingBlock:(void (^)(void))block;

/**
remove the observer
 */
- (void)removeTimeObserver;

/**
 debug view
 */
- (void)showDebugViewInView:(UIView *)hudView zIndex:(NSInteger)index;
- (void)removeDebugTool;


@end

NS_ASSUME_NONNULL_END
