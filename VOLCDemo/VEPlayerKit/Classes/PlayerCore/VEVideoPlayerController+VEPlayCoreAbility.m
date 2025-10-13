//
//  VEVideoPlayerController+VEPlayCoreAbility.m
//  VOLCDemo
//
//  Created by real on 2022/1/11.
//

#import "VEVideoPlayerController+VEPlayCoreAbility.h"

@implementation VEVideoPlayerController (VEPlayCoreAbility)

#pragma mark ----- origin class implementated
/*
 @property (nonatomic, weak) id<VEPlayCoreCallBackAbilityProtocol> receiver;
 @property (nonatomic, assign) BOOL looping;
 - (void)play;
 - (void)pause;
 */


#pragma mark ----- implementatation

- (CGFloat)playbackSpeed {
    return [self playbackRate];
}

- (void)setPlaybackSpeed:(CGFloat)speed {
    [self setPlaybackRate:speed];
}

- (void)setVolume:(CGFloat)volume {
    [self setPlaybackVolume:volume];
}

- (CGFloat)volume {
    return [self playbackVolume];
}

- (void)seek:(NSTimeInterval)destination {
    if (destination > 0.00) {
        [self seekToTime:destination complete:^(BOOL success) {
            NSLog(@"call seek succeed");
        } renderComplete:^{
            NSLog(@"render succeed after seek");
        }];
    }
}

- (VEPlaybackState)currentPlaybackState {
    VEPlaybackState state = VEPlaybackStateError;
    if (self.videoEngine) {
        switch (self.videoEngine.playbackState) {
            case TTVideoEnginePlaybackStateError: {
                state = VEPlaybackStateError;
            }
                break;
            case TTVideoEnginePlaybackStateStopped: {
                state = VEPlaybackStateStopped;
            }
                break;
            case TTVideoEnginePlaybackStatePlaying: {
                state = VEPlaybackStatePlaying;
            }
                break;
            case TTVideoEnginePlaybackStatePaused: {
                state = VEPlaybackStatePause;
            }
                break;
            default: {
                state = VEPlaybackStateUnknown;
            }
                break;
        }
    }
    return state;
}

- (NSString *)title {
    return [self playerTitle];
}

- (NSArray *)playSpeedSet {
    return @[
        @{@"0.5x" : @(0.5)},
        @{@"1.0x" : @(1.0)},
        @{@"1.5x" : @(1.5)},
        @{@"2.0x" : @(2.0)},
        @{@"3.0x" : @(3.0)}
    ];
}

@end
