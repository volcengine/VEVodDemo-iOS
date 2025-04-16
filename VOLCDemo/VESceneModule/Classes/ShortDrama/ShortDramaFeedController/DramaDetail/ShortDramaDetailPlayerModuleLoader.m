//
//  ShortDramaDetailPlayerModuleLoader.m
//  ModularPlayerDemo
//

#import "ShortDramaDetailPlayerModuleLoader.h"
#import "VEPlayerLoadingModule.h"
#import "ShortDramaPlayButtonModule.h"
#import "ShortDramaPlayerMaskModule.h"
#import "VEPlayerSeekModule.h"
#import "VEPlayerSeekProgressModule.h"
#import "ShortDramaIntroduceModule.h"
#import "ShortDramaSelectionModule.h"
#import "ShortDramaPlayerSpeedModule.h"
#import "ShortDramaPayModule.h"
#import "ShortDramaPlayerToastModule.h"
#import "ShortDramaRecordStartTimeModule.h"
#import "VEPlayerSubtitleModule.h"
#import "VEPlayerPipModule.h"
#import "VESettingManager.h"

@interface ShortDramaDetailPlayerModuleLoader () <ShortDramaSelectionModuleDelegate>

@property (nonatomic, strong) ShortDramaSelectionModule *selectionModule;

@property (nonatomic, strong) VEPlayerSubtitleModule *subtitleModule;

@end

@implementation ShortDramaDetailPlayerModuleLoader

- (NSArray<id<VEPlayerBaseModuleProtocol>> *)getCoreModules {
    NSMutableArray *coreModules = [NSMutableArray array];
    [coreModules addObject:[ShortDramaPlayerMaskModule new]];
    [coreModules addObject:[VEPlayerLoadingModule new]];
    [coreModules addObject:[ShortDramaPlayButtonModule new]];
    [coreModules addObject:[VEPlayerSeekModule new]];
    [coreModules addObject:[VEPlayerSeekProgressModule new]];
    [coreModules addObject:[ShortDramaIntroduceModule new]];
    
    self.selectionModule = [ShortDramaSelectionModule new];
    self.selectionModule.delegate = self;
    [coreModules addObject:self.selectionModule];
    
    [coreModules addObject:[ShortDramaPlayerSpeedModule new]];
    [coreModules addObject:[ShortDramaPayModule new]];
    [coreModules addObject:[ShortDramaPlayerToastModule new]];
    [coreModules addObject:[ShortDramaRecordStartTimeModule new]];
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

#pragma mark - ShortDramaSelectionModuleDelegate

- (void)onClickDramaSelectionCallback {
    if (self.delegate && [self.delegate respondsToSelector:@selector(onClickDramaSelectionCallback)]) {
        [self.delegate onClickDramaSelectionCallback];
    }
}

@end
