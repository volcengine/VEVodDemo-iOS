//
//  VESettingManager.m
//  VOLCDemo
//
//  Created by real on 2022/8/22.
//  Copyright © 2022 ByteDance. All rights reserved.
//

#import "VESettingManager.h"
#import "VEVideoPlayerController.h"
#import "VEVideoPlayerController+DebugTool.h"

#import <MBProgressHUD/MBProgressHUD.h>

const NSString *debugSectionKey = @"title_setting_debug_type";

const NSString *shortVideoSectionKey = @"title_setting_short_strategy";

const NSString *universalSectionKey = @"title_setting_common_option";

const NSString *universalActionSectionKey = @"universal_action"; // clear, log out?

@interface VESettingManager ()

@property (nonatomic, strong) NSMutableDictionary *settings;

@end

@implementation VESettingManager

static VESettingManager *instance;
static dispatch_once_t onceToken;
+ (VESettingManager *)universalManager {
    dispatch_once(&onceToken, ^{
        instance = [VESettingManager new];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.settings = [NSMutableDictionary dictionary];
        [self initialDefaultSettings];
    }
    return self;
}

- (void)initialDefaultSettings {
    NSMutableArray *playSourceSection = [NSMutableArray array];
    [playSourceSection addObject:({
        VESettingModel *model = [VESettingModel new];
        model.settingKey = VESettingKeyDebugCustomPlaySourceType;
        model.displayText = NSLocalizedString(@"title_setting_debug_type_custom_source", nil);
        model.settingType = VESettingTypeMutilSelector;
        model;
    })];
    [self.settings setValue:playSourceSection forKey:NSLocalizedString(debugSectionKey.copy, nil)];
    
    NSMutableArray *shortVideoSection = [NSMutableArray array];
    [shortVideoSection addObject:({
        VESettingModel *model = [VESettingModel new];
        model.displayText = NSLocalizedString(@"title_setting_short_strategy_preload", nil);
        model.settingKey = VESettingKeyShortVideoPreloadStrategy;
        model.open = YES;
        model.settingType = VESettingTypeSwitcher;
        model;
    })];
    [shortVideoSection addObject:({
        VESettingModel *model = [VESettingModel new];
        model.displayText = NSLocalizedString(@"title_setting_short_strategy_preRender", nil);
        model.settingKey = VESettingKeyShortVideoPreRenderStrategy;
        model.open = YES;
        model.settingType = VESettingTypeSwitcher;
        model;
    })];
    [self.settings setValue:shortVideoSection forKey:NSLocalizedString(shortVideoSectionKey.copy, nil)];
    
    NSMutableArray *universalSection = [NSMutableArray array];
    [universalSection addObject:({
        VESettingModel *model = [VESettingModel new];
        model.settingKey = VESettingKeyUniversalPlaySourceType;
        model.currentValue = @(VEPlaySourceType_Vid);
        model.displayText = NSLocalizedString(@"title_setting_Source_Type_Select", nil);
        model.detailText = NSLocalizedString(@"title_setting_Source_Type_Vid", nil);
        model.settingType = VESettingTypeMutilSelector;
        model;
    })];
    [universalSection addObject:({
        VESettingModel *model = [VESettingModel new];
        model.displayText = NSLocalizedString(@"title_setting_common_option_h265", nil);
        model.settingKey = VESettingKeyUniversalH265;
        model.open = YES;
        model.settingType = VESettingTypeSwitcher;
        model;
    })];
    [universalSection addObject:({
        VESettingModel *model = [VESettingModel new];
        model.displayText = NSLocalizedString(@"title_setting_common_option_hardware", nil);
        model.settingKey = VESettingKeyUniversalHardwareDecode;
        model.open = YES;
        model.settingType = VESettingTypeSwitcher;
        model;
    })];
    
    [universalSection addObject:({
        VESettingModel *model = [VESettingModel new];
        model.displayText = NSLocalizedString(@"title_setting_common_option_sr", nil);
        model.settingKey = VESettingKeyUniversalSR;
        model.settingType = VESettingTypeSwitcher;
        model;
    })];
    [universalSection addObject:({
        VESettingModel *model = [VESettingModel new];
        model.displayText = NSLocalizedString(@"title_setting_common_option_deviceId", nil);
        model.settingKey = VESettingKeyUniversalDeviceID;
        model.detailText = [VEVideoPlayerController deviceID];
        model.settingType = VESettingTypeDisplayDetail;
        model;
    })];
    [self.settings setValue:universalSection forKey:NSLocalizedString(universalSectionKey.copy, nil)];
    
    NSMutableArray *universalActionSection = [NSMutableArray array];
    [universalActionSection addObject:({
        VESettingModel *model = [VESettingModel new];
        model.displayText = NSLocalizedString(@"title_setting_clean_cache", nil);
        model.settingKey = VESettingKeyUniversalActionCleanCache;
        model.settingType = VESettingTypeDisplay;
        model.allAreaAction = ^{
            [VEVideoPlayerController cleanCache];
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:UIApplication.sharedApplication.keyWindow animated:YES];
            hud.mode = MBProgressHUDModeText;
            hud.label.text = NSLocalizedString(@"tip_clean_success", nil);
            [hud hideAnimated:YES afterDelay:1.0];
        };
        model;
    })];
    [self.settings setValue:universalActionSection forKey:NSLocalizedString(universalActionSectionKey.copy, nil)];
}

- (NSArray *)settingSections {
    @autoreleasepool {
        return @[NSLocalizedString(debugSectionKey.copy, nil),
                 NSLocalizedString(shortVideoSectionKey.copy, nil),
                 NSLocalizedString(universalSectionKey.copy, nil),
                 NSLocalizedString(universalActionSectionKey.copy, nil)];
    }
}

- (VESettingModel *)settingForKey:(VESettingKey)key {
    NSArray *settings = [NSArray array];
    switch (key / 1000) {
        case 0:{
            settings = [self.settings objectForKey:NSLocalizedString(universalSectionKey.copy, nil)];
        }
            break;
        case 1:{
            settings = [self.settings objectForKey:NSLocalizedString(universalActionSectionKey.copy, nil)];
        }
            break;
        case 10:{
            settings = [self.settings objectForKey:NSLocalizedString(shortVideoSectionKey.copy, nil)];
            break;
        }
        case 100:{
            settings = [self.settings objectForKey:NSLocalizedString(debugSectionKey.copy, nil)];
        }
            break;
    }
    for (VESettingModel *model in settings) {
        if (model.settingKey == key) return model;
    }
    return nil;
}

@end
