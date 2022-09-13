//
//  VEPlayProtocol.h
//  Pods
//
//  Created by real on 2021/9/14.
//

/**
 * This file helps you to give a role class make me know the ability of your player.
 * The protocol 'VEPlayCoreAbilityProtocol' describes the player active ability.
 * The protocol 'VEPlayCoreCallBackAbilityProtocol' lists the player callback methods.
 */

/**
 * Player state enum, you should transfer player origin state to this state.
 * If player could not matching all the state, you can give 'VEPlaybackStateUnknown' or 'NSNotFound' for backup.
 */
typedef enum : NSUInteger {
    VEPlaybackStateUnknown,
    VEPlaybackStateError,
    VEPlaybackStateStopped,
    VEPlaybackStatePause,
    VEPlaybackStatePlaying,
} VEPlaybackState;

@protocol VEPlayCoreAbilityProtocol;

@protocol VEPlayCoreCallBackAbilityProtocol <NSObject>

- (void)playerCore:(id<VEPlayCoreAbilityProtocol>)core playbackStateDidChanged:(VEPlaybackState)currentState info:(NSDictionary *)info;

- (void)playerCore:(id<VEPlayCoreAbilityProtocol>)core playTimeDidChanged:(NSTimeInterval)interval info:(NSDictionary *)info;

- (void)playerCore:(id<VEPlayCoreAbilityProtocol>)core resolutionChanged:(NSInteger)currentResolution info:(NSDictionary *)info;

@end

@protocol VEPlayCoreAbilityProtocol <NSObject>

// The receiver means you should provide a instance to help the implementor of this protocol(VEPlayCoreAbilityProtocol) to notify message of protocol 'VEPlayCoreCallBackAbilityProtocol'.
@property (nonatomic, weak) id<VEPlayCoreCallBackAbilityProtocol> receiver;

// Looping means a switcher, if looping = YES, it will start a new play action by interval zero after play end.
@property (nonatomic, assign) BOOL looping;

// Playback speed means the speed how many times faster do you want it to be.
@property (nonatomic, assign) CGFloat playbackSpeed;

// Current resolution means the resolution type now using.
@property (nonatomic, assign) NSInteger currentResolution;

// The volume of system / Player core.
@property (nonatomic, assign) CGFloat volume;

// Play method fire player start.
- (void)play;

// Pause method fire player temporary stop.
- (void)pause;

// Seek method fire player to find the point which you give(destination).
- (void)seek:(NSTimeInterval)destination;

// Reture the current state of VEInterface, not origin player state.
- (VEPlaybackState)currentPlaybackState;

// Reture the title of current playing video.
- (NSString *)title;

// Return the duration of current playing video.
- (NSTimeInterval)duration;
 
// Return the duration of the cached data can support playing.
- (NSTimeInterval)playableDuration;

/**
 * Return the map of play speed.
 * @"1.5x" : @(1.5) -> UI-title : speed-param
 */
- (NSArray<NSDictionary<NSString *, NSNumber *> *> *)playSpeedSet;

/**
 * Return the map of resolution can be play.
 * @"720P" : @"720" -> UI-title : resolution-Key
 */
- (NSArray<NSDictionary<NSString *, NSString *> *> *)resolutionSet;

@end
