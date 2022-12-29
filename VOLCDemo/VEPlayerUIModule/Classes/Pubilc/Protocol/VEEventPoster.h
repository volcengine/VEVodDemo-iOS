//
//  VEEventPoster.h
//  VEPlayerUIModule
//
//  Created by real on 2021/9/7.
//

#pragma mark ----- Public Event
#pragma mark ----- Call Play Event
// Player should play.
extern NSString *const VEPlayEventPlay;
// Player should pause.
extern NSString *const VEPlayEventPause;
// Player should seek.
extern NSString *const VEPlayEventSeek;
// Player should change loop mode, param -> VEEventPoster.loopPlayOpen.
extern NSString *const VEPlayEventChangeLoopPlayMode;


#pragma mark ----- Play Callback Event
// Player progress did changed, param @{VEPlayEventProgressValueIncrease : (NSNumber *)}.
extern NSString *const VEPlayEventProgressValueIncrease;
// Player state did changed, param -> VEEventPoster.currentPlaybackState or @{VEPlayEventStateChanged : @{(NSString *)state : NSDictionary *(stateChangeInfo)}}.
extern NSString *const VEPlayEventStateChanged;
// Player time interval did changed, param -> @{VEPlayEventTimeIntervalChanged : (NSNumber *)}.
extern NSString *const VEPlayEventTimeIntervalChanged;
// Player current resolution did changed, param -> VEEventPoster.currentResolution or @{VEPlayEventResolutionChanged : @{(NSInteger)resolution : NSDictionary *(resolutionChangeInfo)}}.
extern NSString *const VEPlayEventResolutionChanged;
// Player current play speed ratio did changed, param -> VEEventPoster.currentPlaySpeed or @{VEPlayEventPlaySpeedChanged : @{(NSInteger)speed : NSDictionary *(speedChangeInfo)}}.
extern NSString *const VEPlayEventPlaySpeedChanged;


#pragma mark ----- Call UI Event
// The screen of VEInterface should rotation.
extern NSString *const VEUIEventScreenRotation;
// The page of VEInterface should back.
extern NSString *const VEUIEventPageBack;
// VEInterface should lock, param -> VEEventPoster.screenIsLocking
extern NSString *const VEUIEventLockScreen;
// VEInterface should clear, param -> VEEventPoster.screenIsClear
extern NSString *const VEUIEventClearScreen;
// VEInterface should show slide menu.
extern NSString *const VEUIEventShowMoreMenu;
// VEInterface should show resolution menu.
extern NSString *const VEUIEventShowResolutionMenu;
// VEInterface should show play speed menu.
extern NSString *const VEUIEventShowPlaySpeedMenu;
// The volume should changed which implemented in protocol 'VEPlayProtocol'.
extern NSString *const VEUIEventVolumeIncrease;
// The brightness should changed which implemented in protocol 'VEPlayProtocol'.
extern NSString *const VEUIEventBrightnessIncrease;


#pragma mark ----- UI Callback Event
// VEInterface's state of lock did changed, param -> VEEventPoster.screenIsLocking
extern NSString *const VEUIEventScreenLockStateChanged;
// VEInterface's state of screen clear did changed, param -> VEEventPoster.screenIsClear or @{VEUIEventClearScreen : (NSNumber *)}.
extern NSString *const VEUIEventScreenClearStateChanged;


#import "VEPlayProtocol.h"
@protocol VEInterfaceElementDescription;

@interface VEEventPoster : NSObject

+ (instancetype)currentPoster;

+ (void)destroyUnit;

// The playback state of the player current runing.
- (VEPlaybackState)currentPlaybackState;
// The play duration of the player current runing.
- (NSTimeInterval)duration;
// The cache duration of current player loaded.
- (NSTimeInterval)playableDuration;
// The play title of current play session.
- (NSString *)title;
// The loop mode of the player current runing.
- (BOOL)loopPlayOpen;
// The play speed range which you want in protocol 'VEPlayProtocol'.
- (NSArray *)playSpeedSet;
// The method param by play speed of the player current runing.
- (CGFloat)currentPlaySpeed;
// The UI display param by play speed of the player current runing.
- (NSString *)currentPlaySpeedForDisplay;
// The resolutions all you want in protocol 'VEPlayProtocol'.
- (NSArray *)resolutionSet;
// The method param by resolution of the player current runing.
- (NSInteger)currentResolution;
// The UI display param by resolution of the player current runing.
- (NSString *)currentResolutionForDisplay;
// The volume value of you want which implemented in protocol 'VEPlayProtocol'.
- (CGFloat)currentVolume;
// The brightness value of you want which implemented in protocol 'VEPlayProtocol'.
- (CGFloat)currentBrightness;
// The locking state of VEInterface.
- (BOOL)screenIsLocking;
// The clear state of VEInterface.
- (BOOL)screenIsClear;

@end
