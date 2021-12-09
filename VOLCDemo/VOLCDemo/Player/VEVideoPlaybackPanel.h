//
//  VEVideoPlaybackPanel.h
//  VOLCDemo
//
//  Created by wangzhiyong on 2021/12/3.
//

#import <Foundation/Foundation.h>
#import "VEVideoPlayback.h"


@protocol VEVideoPlaybackPanelPotocol <NSObject>

- (instancetype)initWithVideoPlayer:(id<VEVideoPlayback>)videoPlayer;

- (void)videoPlayerPlaybackStateChanged:(VEVideoPlaybackState)oldState
                               newState:(VEVideoPlaybackState)newState;

- (void)videoPlayerLoadStateChanged:(VEVideoLoadState)oldState
                           newState:(VEVideoLoadState)newState;

- (void)videoPlayerTimeTrigger:(NSTimeInterval)duration
           currentPlaybackTime:(NSTimeInterval)currentPlaybackTime
              playableDuration:(NSTimeInterval)playableDuration;

@end
