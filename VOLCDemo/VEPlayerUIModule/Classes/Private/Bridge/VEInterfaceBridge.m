//
//  VEInterfaceBridge.m
//  VEPlayerUIModule
//
//  Created by real on 2021/9/15.
//

#import "VEInterfaceBridge.h"
#import "VEEventConst.h"
#import "VEPlayProtocol.h"

NSString *const VEPlayEventStateChanged = @"VEPlayEventStateChanged";

NSString *const VEPlayEventTimeIntervalChanged = @"VEPlayEventTimeIntervalChanged";

@interface VEInterfaceBridge () <VEPlayCoreCallBackAbilityProtocol>

@property (nonatomic, weak) id<VEPlayCoreAbilityProtocol> core;

@property (nonatomic, assign) BOOL stopMark;

@end

@implementation VEInterfaceBridge

static id sharedInstance = nil;
+ (instancetype)bridge {
    if (!sharedInstance) {
        sharedInstance = [[self alloc] init];
        [sharedInstance registEvents];
    }
    return sharedInstance;
}

+ (void)destroyUnit {
    @autoreleasepool {
        sharedInstance = nil;
    }
}


#pragma mark ----- Action / Message

- (void)registEvents {
    [[VEEventMessageBus universalBus] registEvent:VETaskPlayCoreTransfer withAction:@selector(bindPlayerCore:) ofTarget:self];
    [[VEEventMessageBus universalBus] registEvent:VEPlayEventPlay withAction:@selector(playAction:) ofTarget:self];
    [[VEEventMessageBus universalBus] registEvent:VEPlayEventPause withAction:@selector(pauseAction:) ofTarget:self];
    [[VEEventMessageBus universalBus] registEvent:VEPlayEventSeek withAction:@selector(seekAction:) ofTarget:self];
    [[VEEventMessageBus universalBus] registEvent:VEPlayEventChangeLoopPlayMode withAction:@selector(changeLoopPlayModeAction:) ofTarget:self];
    [[VEEventMessageBus universalBus] registEvent:VEPlayEventChangeSREnable withAction:@selector(changeSREnableAction:) ofTarget:self];
    [[VEEventMessageBus universalBus] registEvent:VEPlayEventChangePlaySpeed withAction:@selector(changePlaySpeedAction:) ofTarget:self];
    [[VEEventMessageBus universalBus] registEvent:VEPlayEventChangeResolution withAction:@selector(changeResolutionAction:) ofTarget:self];
    [[VEEventMessageBus universalBus] registEvent:VEUIEventBrightnessIncrease withAction:@selector(changeBrightnessAction:) ofTarget:self];
    [[VEEventMessageBus universalBus] registEvent:VEUIEventVolumeIncrease withAction:@selector(changeVolumeAction:) ofTarget:self];
}

- (void)bindPlayerCore:(id)param {
    if ([param isKindOfClass:[NSDictionary class]]) {
        NSDictionary *paramDic = (NSDictionary *)param;
        id core = paramDic.allValues.firstObject;
        if ([core conformsToProtocol:@protocol(VEPlayCoreAbilityProtocol)]) {
            self.core = core;
            self.core.receiver = self;
        }
    }
}

- (void)playAction:(id)param {
    if ([self.core respondsToSelector:@selector(play)]) {
        [self.core play];
    }
}

- (void)pauseAction:(id)param {
    if ([self.core respondsToSelector:@selector(pause)]) {
        [self.core pause];
    }
}

- (void)seekAction:(id)param {
    if ([param isKindOfClass:[NSDictionary class]]) {
        NSDictionary *paramDic = (NSDictionary *)param;
        id value = paramDic.allValues.firstObject;
        if ([value isKindOfClass:[NSNumber class]]) {
            NSTimeInterval interval = [((NSNumber *)value) doubleValue];
            if ([self.core respondsToSelector:@selector(seek:)]) {
                [self.core seek:interval];
            }
        }
    }
}

- (void)changeLoopPlayModeAction:(id)param {
    if ([self.core respondsToSelector:@selector(setLooping:)]) {
        [self.core setLooping:!self.core.looping];
    }
}

- (void)changeSREnableAction:(BOOL)srEnable {
    if ([self.core respondsToSelector:@selector(setSuperResolutionEnable:)]) {
        [self.core setSuperResolutionEnable:!self.core.superResolutionEnable];
    }
}

- (void)changePlaySpeedAction:(id)param {
    if ([param isKindOfClass:[NSDictionary class]]) {
        NSDictionary *paramDic = (NSDictionary *)param;
        id value = paramDic.allValues.firstObject;
        if ([value isKindOfClass:[NSNumber class]]) {
            CGFloat speed = [(NSNumber *)value floatValue];
            if ([self.core respondsToSelector:@selector(setPlaybackSpeed:)]) {
                [self.core setPlaybackSpeed:speed];
                [[VEEventMessageBus universalBus] postEvent:VEPlayEventPlaySpeedChanged withObject:nil rightNow:YES];
            }
        }
    }
}

- (void)changeResolutionAction:(id)param {
    if ([param isKindOfClass:[NSDictionary class]]) {
        NSDictionary *paramDic = (NSDictionary *)param;
        id value = paramDic.allValues.firstObject;
        if ([value isKindOfClass:[NSNumber class]]) {
            NSInteger resolutionType = [(NSNumber *)value integerValue];
            if ([self.core respondsToSelector:@selector(setCurrentResolution:)]) {
                [self.core setCurrentResolution:resolutionType];
            }
        }
    }
}

- (void)changeVolumeAction:(id)param {
    if ([param isKindOfClass:[NSDictionary class]]) {
        NSDictionary *paramDic = (NSDictionary *)param;
        id value = paramDic.allValues.firstObject;
        if ([value isKindOfClass:[NSNumber class]]) {
            if ([self.core respondsToSelector:@selector(setVolume:)]) {
                CGFloat changeValue = [(NSNumber *)value floatValue];
                CGFloat currentVolume = [self currentVolume];
                currentVolume = MIN(MAX(currentVolume += changeValue, 0.0), 1.0);
                [self.core setVolume:currentVolume];
            }
        }
    }
}

- (void)changeBrightnessAction:(id)param {
    if ([param isKindOfClass:[NSDictionary class]]) {
        NSDictionary *paramDic = (NSDictionary *)param;
        id value = paramDic.allValues.firstObject;
        if ([value isKindOfClass:[NSNumber class]]) {
            CGFloat changeValue = [(NSNumber *)value floatValue];
            CGFloat currentBrightness = [[UIScreen mainScreen] brightness];
            currentBrightness = MIN(MAX(currentBrightness += changeValue, 0.0), 1.0);
            [[UIScreen mainScreen] setBrightness:currentBrightness];
        }
    }
}


#pragma mark ----- VEInfoProtocol, Static Info / Poster

- (NSInteger)currentPlaybackState {
    if ([self.core respondsToSelector:@selector(currentPlaybackState)]) {
        return [self.core currentPlaybackState];
    } else {
        return NSNotFound;
    }
}

- (NSTimeInterval)duration {
    if ([self.core respondsToSelector:@selector(duration)]) {
        return [self.core duration];
    } else {
        return 0.0;
    }
}

- (NSTimeInterval)playableDuration {
    if ([self.core respondsToSelector:@selector(playableDuration)]) {
        return [self.core playableDuration];
    } else {
        return 0.0;
    }
}

- (NSString *)title {
    if ([self.core respondsToSelector:@selector(title)]) {
        return [self.core title];
    } else {
        return @"";
    }
}

- (BOOL)loopPlayOpen {
    if ([self.core respondsToSelector:@selector(looping)]) {
        return [self.core looping];
    }
    return NO;
}

- (BOOL)srOpen {
    if ([self.core respondsToSelector:@selector(superResolutionEnable)]) {
        return [self.core superResolutionEnable];
    }
    return NO;
}

- (CGFloat)currentPlaySpeed {
    if ([self.core respondsToSelector:@selector(playbackSpeed)]) {
        return [self.core playbackSpeed];
    }
    return 1.0;
}

- (NSString *)currentPlaySpeedForDisplay {
    for (NSDictionary *playSpeedDic in [self playSpeedSet]) {
        if ([playSpeedDic.allValues.firstObject floatValue] == [self currentPlaySpeed]) {
            return playSpeedDic.allKeys.firstObject;
        }
    }
    return @"";
}

- (NSArray *)playSpeedSet {
    if ([self.core respondsToSelector:@selector(playSpeedSet)]) {
        return [self.core playSpeedSet];
    }
    return @[];
}

- (NSInteger)currentResolution {
    if ([self.core respondsToSelector:@selector(currentResolution)]) {
        return [self.core currentResolution];
    }
    return 6; // TTVideoEngineResolutionTypeUnknown == 6
}

- (NSString *)currentResolutionForDisplay {
    for (NSDictionary *resolutionDic in [self resolutionSet]) {
        if ([resolutionDic.allValues.firstObject integerValue] == [self currentResolution]) {
            return resolutionDic.allKeys.firstObject;
        }
    }
    return @"";
}

- (NSArray *)resolutionSet {
    if ([self.core respondsToSelector:@selector(resolutionSet)]) {
        return [self.core resolutionSet];
    }
    return @[];
}

- (CGFloat)currentVolume {
    if ([self.core respondsToSelector:@selector(volume)]) {
        return [self.core volume];
    }
    return 0.0;
}

- (CGFloat)currentBrightness {
    return [[UIScreen mainScreen] brightness];
}

#pragma mark ----- VEPlayCoreCallBackAbilityProtocol

- (void)playerCore:(id<VEPlayCoreAbilityProtocol>)core playbackStateDidChanged:(VEPlaybackState)currentState info:(NSDictionary *)info {
    if (core == self.core) {
        [[VEEventMessageBus universalBus] postEvent:VEPlayEventStateChanged withObject:@[@(currentState), info] rightNow:YES];
    }
}

- (void)playerCore:(id<VEPlayCoreAbilityProtocol>)core playTimeDidChanged:(NSTimeInterval)interval info:(NSDictionary *)info {
    if (core == self.core) {
        if (!self.stopMark) {
            [[VEEventMessageBus universalBus] postEvent:VEPlayEventTimeIntervalChanged withObject:@(interval) rightNow:YES];
        }
        VEPlaybackState state = [[VEEventPoster currentPoster] currentPlaybackState];
        if (state == VEPlaybackStatePlaying) {
            self.stopMark = NO;
        } else {
            self.stopMark = YES;
        }
    }
}

- (void)playerCore:(id<VEPlayCoreAbilityProtocol>)core resolutionChanged:(NSInteger)currentResolution info:(NSDictionary *)info {
    if (core == self.core) {
        [[VEEventMessageBus universalBus] postEvent:VEPlayEventResolutionChanged withObject:@[@(currentResolution), info] rightNow:YES];
    }
}

@end
