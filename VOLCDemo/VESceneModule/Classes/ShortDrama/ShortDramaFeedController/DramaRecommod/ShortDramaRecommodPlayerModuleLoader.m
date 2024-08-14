//
//  ShortDramaRecommodPlayerModuleLoader.m
//  VEPlayModule
//
//  Created by zyw on 2024/7/16.
//

#import "ShortDramaRecommodPlayerModuleLoader.h"
#import "VEPlayerLoadingModule.h"
#import "ShortDramaPlayButtonModule.h"
#import "ShortDramaPlayerMaskModule.h"
#import "VEPlayerSeekModule.h"
#import "VEPlayerSeekProgressModule.h"
#import "ShortDramaRecommodIntroduceModule.h"
#import "ShortDramaPlayerSpeedModule.h"
#import "ShortDramaSeriesModule.h"

@interface ShortDramaRecommodPlayerModuleLoader () <ShortDramaSeriesModuleDelegate>

@property (nonatomic, strong) ShortDramaSeriesModule *seriesModel;

@end

@implementation ShortDramaRecommodPlayerModuleLoader

- (NSArray<id<VEPlayerBaseModuleProtocol>> *)getCoreModules {
    NSMutableArray *coreModules = [NSMutableArray array];
    [coreModules addObject:[ShortDramaPlayerMaskModule new]];
    [coreModules addObject:[VEPlayerLoadingModule new]];
    [coreModules addObject:[ShortDramaPlayButtonModule new]];
    [coreModules addObject:[VEPlayerSeekModule new]];
    [coreModules addObject:[VEPlayerSeekProgressModule new]];
    [coreModules addObject:[ShortDramaRecommodIntroduceModule new]];
    [coreModules addObject:[ShortDramaPlayerSpeedModule new]];
    
    self.seriesModel = [ShortDramaSeriesModule new];
    self.seriesModel.delegate = self;
    [coreModules addObject:self.seriesModel];
    
    return coreModules;
}

#pragma mark - ShortDramaSeriesModuleDelegate

- (void)onClickSeriesViewCallback {
    if (self.delegate && [self.delegate respondsToSelector:@selector(onClickSeriesViewCallback)]) {
        [self.delegate onClickSeriesViewCallback];
    }
}

@end
