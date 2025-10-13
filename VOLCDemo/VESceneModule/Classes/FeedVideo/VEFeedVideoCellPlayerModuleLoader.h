//
//  VEFeedVideoCellPlayerModuleLoader.h
//  VESceneModule
//
//  Created by zys on 2025/10/22.
//

#import "VEPlayerBaseModuleLoader.h"
#import "VEPlayerBackModule.h"

NS_ASSUME_NONNULL_BEGIN

@interface VEFeedVideoCellPlayerModuleLoader : VEPlayerBaseModuleLoader

@property (nonatomic, strong) VEPlayerBackModule *backModule;

@end

NS_ASSUME_NONNULL_END
