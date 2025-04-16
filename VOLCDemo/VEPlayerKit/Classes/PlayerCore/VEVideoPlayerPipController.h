//
//  VEVideoPlayerPipController.h
//  VOLCDemo
//
//  Created by litao.he on 2025/3/18.
//

@import UIKit;
#import <AVKit/AVKit.h>
#import <TTSDKFramework/TTVideoEngine+Video.h>
#import "VEVideoPlaybackDefine.h"

NS_ASSUME_NONNULL_BEGIN

@interface VEVideoPlayerPipDisplayView : UIView

@end

@protocol VEVideoPlayerPipControllerDelegate <NSObject>

- (void)willStartPictureInPicture;

- (void)didStopPictureInPicture;

- (VEVideoPlaybackState)getPlaybackState;

- (NSInteger)getDuration;

- (NSInteger)getPosition;

- (void)setPlaying:(BOOL)playing;

@end

@interface VEVideoPlayerPipController : NSObject

@property (nonatomic, weak) id<VEVideoPlayerPipControllerDelegate> delegate;
@property (nonatomic, strong) VEVideoPlayerPipDisplayView *displayView;
@property (nonatomic, strong) AVSampleBufferDisplayLayer *displayLayer;
@property (nonatomic, weak) id currentController;

+ (instancetype)shared;

- (instancetype)init;

- (void)setVideoViewMode:(VEVideoViewMode)videoViewMode;

- (void)startPip;

- (void)stopPip;

- (BOOL)isPipActive;

- (void)invalidatePlaybackState;

- (EngineVideoWrapper *)createVideoWrapper:(id)playerController;

@end

NS_ASSUME_NONNULL_END
