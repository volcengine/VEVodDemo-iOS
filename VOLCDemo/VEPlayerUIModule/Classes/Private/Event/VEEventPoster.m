//
//  VEEventPoster.m
//  VEPlayerUIModule
//
//  Created by real on 2021/9/7.
//

#import "VEEventPoster.h"
#import "VEEventPoster+Private.h"
#import "VEInterfaceBridge.h"

@interface VEEventPoster ()

/**
 * 这些比较特殊，暂时提供setter & getter，寄存状态,
 * 命名/含义 与BOOL默认值相同
 */
@property (nonatomic, assign) BOOL screenIsLocking;

@property (nonatomic, assign) BOOL screenIsClear;

@end

@implementation VEEventPoster

static id sharedInstance = nil;
+ (instancetype)currentPoster {
    if (!sharedInstance) {
        sharedInstance = [[self alloc] init];
    }
    return sharedInstance;
}

+ (void)destroyUnit {
    @autoreleasepool {
        sharedInstance = nil;
    }
}

- (VEPlaybackState)currentPlaybackState {
    return [[VEInterfaceBridge bridge] currentPlaybackState];
}

- (NSTimeInterval)duration {
    return [[VEInterfaceBridge bridge] duration];
}

- (NSTimeInterval)playableDuration {
    return [[VEInterfaceBridge bridge] playableDuration];
}

- (NSString *)title {
    return [[VEInterfaceBridge bridge] title];
}

- (BOOL)loopPlayOpen {
    return [[VEInterfaceBridge bridge] loopPlayOpen];
}

- (NSArray *)playSpeedSet {
    return [[VEInterfaceBridge bridge] playSpeedSet];
}

- (CGFloat)currentPlaySpeed {
    return [[VEInterfaceBridge bridge] currentPlaySpeed];
}

- (NSString *)currentPlaySpeedForDisplay {
    return [[VEInterfaceBridge bridge] currentPlaySpeedForDisplay];
}

- (NSArray *)resolutionSet {
    return [[VEInterfaceBridge bridge] resolutionSet];
}

- (NSInteger)currentResolution {
    return [[VEInterfaceBridge bridge] currentResolution];
}

- (NSString *)currentResolutionForDisplay {
    return [[VEInterfaceBridge bridge] currentResolutionForDisplay];
}

- (CGFloat)currentVolume {
    return [[VEInterfaceBridge bridge] currentVolume];
}

- (CGFloat)currentBrightness {
    return [[VEInterfaceBridge bridge] currentBrightness];
}

@end
