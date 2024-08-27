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

@implementation VEShortVideoPlayerModuleLoader

- (NSArray<id<VEPlayerBaseModuleProtocol>> *)getCoreModules {
    NSMutableArray *coreModules = [NSMutableArray array];
    [coreModules addObject:[ShortDramaPlayerMaskModule new]];
    [coreModules addObject:[VEPlayerLoadingModule new]];
    [coreModules addObject:[ShortVideoPlayButtonModule new]];
    [coreModules addObject:[VEPlayerSeekModule new]];
    [coreModules addObject:[VEPlayerSeekProgressModule new]];
    [coreModules addObject:[ShortDramaPlayerSpeedModule new]];
    
    return coreModules;
}

@end
