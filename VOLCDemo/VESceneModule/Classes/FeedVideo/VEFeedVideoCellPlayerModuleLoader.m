//
//  VEFeedVideoCellPlayerModuleLoader.m
//  VESceneModule
//
//  Created by zys on 2025/10/22.
//

#import "VEFeedVideoCellPlayerModuleLoader.h"
#import "VELongVideoPlayButtonModule.h"
#import "VEPlayerBackModule.h"
#import "VEPlayerVisibleModule.h"
#import "VELongVideoSeekModule.h"

@implementation VEFeedVideoCellPlayerModuleLoader

- (NSArray<id<VEPlayerBaseModuleProtocol>> *)getCoreModules {
    NSMutableArray *coreModules = [NSMutableArray array];
    [coreModules addObject:[VELongVideoPlayButtonModule new]];
    [coreModules addObject:[VEPlayerVisibleModule new]];
    [coreModules addObject:[[VELongVideoSeekModule alloc] initForCell:YES]];
    
    return coreModules;
}

@end
