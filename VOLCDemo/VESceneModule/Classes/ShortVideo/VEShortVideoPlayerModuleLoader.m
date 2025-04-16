//
//  VEShortVideoPlayerModuleLoader.m
//  VEPlayModule
//
//  Created by zyw on 2024/7/29.
//

#import "VEShortVideoPlayerModuleLoader.h"
#import "ShortDramaPlayerMaskModule.h"
#import "VEPlayerLoadingModule.h"
#import "ShortVideoPlayButtonModule.h"
#import "VEPlayerSeekModule.h"
#import "VEPlayerSeekProgressModule.h"
#import "ShortDramaPlayerSpeedModule.h"
#import "VEPlayerPipModule.h"
#import "VESettingManager.h"
#import "VEPlayerSubtitleModule.h"

@interface VEShortVideoPlayerModuleLoader ()

@property (nonatomic, strong) VEPlayerSubtitleModule *subtitleModule;

@end

@implementation VEShortVideoPlayerModuleLoader

- (NSArray<id<VEPlayerBaseModuleProtocol>> *)getCoreModules {
    NSMutableArray *coreModules = [NSMutableArray array];
    [coreModules addObject:[ShortDramaPlayerMaskModule new]];
    [coreModules addObject:[VEPlayerLoadingModule new]];
    [coreModules addObject:[ShortVideoPlayButtonModule new]];
    [coreModules addObject:[VEPlayerSeekModule new]];
    [coreModules addObject:[VEPlayerSeekProgressModule new]];
    [coreModules addObject:[ShortDramaPlayerSpeedModule new]];
    self.subtitleModule = [VEPlayerSubtitleModule new];
    [coreModules addObject:self.subtitleModule];

    if ([[VESettingManager universalManager] settingForKey:VESettingKeyUniversalPip].open) {
        [coreModules addObject:[VEPlayerPipModule new]];
    }
    return coreModules;
}

- (void)setSubtitle:(NSString *)subtitle {
    [self.subtitleModule setSubtitle:subtitle];
}

@end
