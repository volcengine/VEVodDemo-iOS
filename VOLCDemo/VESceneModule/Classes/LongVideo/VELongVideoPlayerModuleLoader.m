//
//  VELongVideoPlayerModuleLoader.m
//  VESceneModule
//
//  Created by zys on 2025/10/13.
//

#import "VELongVideoPlayerModuleLoader.h"
#import "ShortDramaPlayerMaskModule.h"
#import "VEPlayerLoadingModule.h"
#import "ShortVideoPlayButtonModule.h"
#import "VELongVideoSeekModule.h"
#import "ShortDramaPlayerSpeedModule.h"
#import "VEPlayerPipModule.h"
#import "VESettingManager.h"
#import "VELongVideoIntroduceModule.h"
#import "VEPlayerVisibleModule.h"
#import "VELongVideoPlayButtonModule.h"
#import "VELongVideoOtherFunctionsModule.h"
#import "VEPlayerBackModule.h"
#import "VEPlayerFullScreenModule.h"
#import "VEPlayerResolutionModule.h"
#import "VEPlayerLockModule.h"
#import "VEPlayerSpeedModule.h"

@implementation VELongVideoPlayerModuleLoader

- (NSArray<id<VEPlayerBaseModuleProtocol>> *)getCoreModules {
    NSMutableArray *coreModules = [NSMutableArray array];
    [coreModules addObject:[VEPlayerVisibleModule new]];
    [coreModules addObject:[VELongVideoSeekModule new]];
    [coreModules addObject:[ShortDramaPlayerSpeedModule new]];
    [coreModules addObject:[VEPlayerLoadingModule new]];
    [coreModules addObject:[VELongVideoIntroduceModule new]];
    [coreModules addObject:[VELongVideoPlayButtonModule new]];
    [coreModules addObject:[VELongVideoOtherFunctionsModule new]];
    [coreModules addObject:[[VEPlayerBackModule alloc] initWithCurVC:self.curVC]];
    [coreModules addObject:[[VEPlayerFullScreenModule alloc] initWithCurVC:self.curVC]];
    [coreModules addObject:[VEPlayerResolutionModule new]];
    [coreModules addObject:[VEPlayerLockModule new]];
    [coreModules addObject:[VEPlayerSpeedModule new]];
    
    if ([[VESettingManager universalManager] settingForKey:VESettingKeyUniversalPip].open) {
        [coreModules addObject:[[VEPlayerPipModule alloc] initWithLeftOffset:12 TopOffset:150]];
    }
    
    return coreModules;
}

@end
