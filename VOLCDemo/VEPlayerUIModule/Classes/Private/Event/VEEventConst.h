//
//  VEEventConst.h
//  VEPlayerUIModule
//
//  Created by real on 2021/9/9.
//

#import "VEEventMessageBus.h"
#import "VEEventPoster+Private.h"

// 静态string，谁post谁实现。
#pragma mark ----- task message

extern NSString *const VETaskPlayCoreTransfer;

#pragma mark ----- Call Play Event

extern NSString *const VEPlayEventPlay;

extern NSString *const VEPlayEventPause;

extern NSString *const VEPlayEventSeek;

extern NSString *const VEPlayEventProgressValueIncrease;

extern NSString *const VEPlayEventChangeLoopPlayMode;

extern NSString *const VEPlayEventChangePlaySpeed;

extern NSString *const VEPlayEventChangeResolution;

#pragma mark ----- Play Callback Event

extern NSString *const VEPlayEventStateChanged;

extern NSString *const VEPlayEventTimeIntervalChanged;

extern NSString *const VEPlayEventResolutionChanged;

extern NSString *const VEPlayEventPlaySpeedChanged;

#pragma mark ----- UI Event

extern NSString *const VEUIEventPageBack;

extern NSString *const VEUIEventScreenRotation;

extern NSString *const VEUIEventScreenOrientationChanged;

extern NSString *const VEUIEventShowMoreMenu;

extern NSString *const VEUIEventShowResolutionMenu;

extern NSString *const VEUIEventShowPlaySpeedMenu;

extern NSString *const VEUIEventLockScreen;

extern NSString *const VEUIEventScreenLockStateChanged;

extern NSString *const VEUIEventClearScreen;

extern NSString *const VEUIEventScreenClearStateChanged;

extern NSString *const VEUIEventVolumeIncrease;

extern NSString *const VEUIEventBrightnessIncrease;
