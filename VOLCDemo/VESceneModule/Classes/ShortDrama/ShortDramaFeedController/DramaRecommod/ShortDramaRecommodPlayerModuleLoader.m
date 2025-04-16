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
#import "ShortDramaRecordStartTimeModule.h"
#import "VEPlayerSubtitleModule.h"

@interface ShortDramaRecommodPlayerModuleLoader () <ShortDramaSeriesModuleDelegate>

@property (nonatomic, strong) ShortDramaSeriesModule *seriesModel;

@property (nonatomic, strong) VEPlayerSubtitleModule *subtitleModule;

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
    [coreModules addObject:[ShortDramaRecordStartTimeModule new]];
    
    self.seriesModel = [ShortDramaSeriesModule new];
    self.seriesModel.delegate = self;
    [coreModules addObject:self.seriesModel];
    
    self.subtitleModule = [VEPlayerSubtitleModule new];
    [coreModules addObject:self.subtitleModule];

    return coreModules;
}

- (void)setSubtitle:(NSString *)subtitle {
    [self.subtitleModule setSubtitle:subtitle];
}

#pragma mark - ShortDramaSeriesModuleDelegate

- (void)onClickSeriesViewCallback {
    if (self.delegate && [self.delegate respondsToSelector:@selector(onClickSeriesViewCallback)]) {
        [self.delegate onClickSeriesViewCallback];
    }
}

@end
