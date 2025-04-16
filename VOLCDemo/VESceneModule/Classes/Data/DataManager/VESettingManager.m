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

const NSString *adSectionKey = @"title_setting_ad";

const NSString *subtitleSectionKey = @"title_setting_subtitle";

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
        model.displayText = NSLocalizedStringFromTable(@"title_setting_debug_type_custom_source", @"VodLocalizable", nil);
        model.settingType = VESettingTypeMutilSelector;
        model;
    })];
    [self.settings setValue:playSourceSection forKey:NSLocalizedStringFromTable(debugSectionKey.copy, @"VodLocalizable", nil)];
    
    NSMutableArray *shortVideoSection = [NSMutableArray array];
    [shortVideoSection addObject:({
        VESettingModel *model = [VESettingModel new];
        model.displayText = NSLocalizedStringFromTable(@"title_setting_short_strategy_preload", @"VodLocalizable", nil);
        model.settingKey = VESettingKeyShortVideoPreloadStrategy;
        model.open = YES;
        model.settingType = VESettingTypeSwitcher;
        model.switchAction = ^{
            VESettingModel *subtitlePreloadEnable = [self settingForKey:VESettingKeySubtitlePreloadEnable];
            if (!model.open && subtitlePreloadEnable.open) {
                subtitlePreloadEnable.open = NO;
            }
        };
        model;
    })];
    [shortVideoSection addObject:({
        VESettingModel *model = [VESettingModel new];
        model.displayText = NSLocalizedStringFromTable(@"title_setting_short_strategy_preRender", @"VodLocalizable", nil);
        model.settingKey = VESettingKeyShortVideoPreRenderStrategy;
        model.open = YES;
        model.settingType = VESettingTypeSwitcher;
        model;
    })];
    [self.settings setValue:shortVideoSection forKey:NSLocalizedStringFromTable(shortVideoSectionKey.copy, @"VodLocalizable", nil)];
    
    NSMutableArray *universalSection = [NSMutableArray array];
    [universalSection addObject:({
        VESettingModel *model = [VESettingModel new];
        model.settingKey = VESettingKeyUniversalPlaySourceType;
        model.currentValue = @(VEPlaySourceType_Vid);
        model.displayText = NSLocalizedStringFromTable(@"title_setting_Source_Type_Select", @"VodLocalizable", nil);
        model.detailText = NSLocalizedStringFromTable(@"title_setting_Source_Type_Vid", @"VodLocalizable", nil);
        model.settingType = VESettingTypeMutilSelector;
        model.selectAction = ^{
            VESettingModel *subtitleSourceType = [self settingForKey:VESettingKeySubtitleSourceType];
            if ([model.currentValue integerValue] == VEPlaySourceType_Url && [subtitleSourceType.currentValue integerValue] == VEPlayerKitSubtitleSourceAuthToken) {
                subtitleSourceType.currentValue = @(VEPlayerKitSubtitleSourceDirectUrl);
                subtitleSourceType.detailText = @"DirectUrl";
            }
        };
        model;
    })];
    [universalSection addObject:({
        VESettingModel *model = [VESettingModel new];
        model.displayText = NSLocalizedStringFromTable(@"title_setting_common_option_h265", @"VodLocalizable", nil);
        model.settingKey = VESettingKeyUniversalH265;
        model.open = YES;
        model.settingType = VESettingTypeSwitcher;
        model;
    })];
    [universalSection addObject:({
        VESettingModel *model = [VESettingModel new];
        model.displayText = NSLocalizedStringFromTable(@"title_setting_common_option_hardware", @"VodLocalizable", nil);
        model.settingKey = VESettingKeyUniversalHardwareDecode;
        model.open = YES;
        model.settingType = VESettingTypeSwitcher;
        model;
    })];
    
    [universalSection addObject:({
        VESettingModel *model = [VESettingModel new];
        model.displayText = NSLocalizedStringFromTable(@"title_setting_common_option_sr", @"VodLocalizable", nil);
        model.settingKey = VESettingKeyUniversalSR;
        model.settingType = VESettingTypeSwitcher;
        model;
    })];
    [universalSection addObject:({
        VESettingModel *model = [VESettingModel new];
        model.displayText = NSLocalizedStringFromTable(@"title_setting_common_option_pip", @"VodLocalizable", nil);
        model.settingKey = VESettingKeyUniversalPip;
        model.settingType = VESettingTypeSwitcher;
        model.open = NO;
        model;
    })];
    [universalSection addObject:({
        VESettingModel *model = [VESettingModel new];
        model.displayText = NSLocalizedStringFromTable(@"title_setting_common_option_deviceId", @"VodLocalizable", nil);
        model.settingKey = VESettingKeyUniversalDeviceID;
        model.detailText = [VEVideoPlayerController deviceID];
        model.settingType = VESettingTypeDisplayDetail;
        model;
    })];
    [self.settings setValue:universalSection forKey:NSLocalizedStringFromTable(universalSectionKey.copy, @"VodLocalizable", nil)];

    NSMutableArray *adSection = [NSMutableArray array];
    [adSection addObject:({
        VESettingModel *model = [VESettingModel new];
        model.displayText = NSLocalizedStringFromTable(@"title_setting_ad_enable", @"VodLocalizable", nil);
        model.settingKey = VESettingKeyAdEnable;
        model.open = NO;
        model.settingType = VESettingTypeSwitcher;
        model;
    })];
    [adSection addObject:({
        VESettingModel *model = [VESettingModel new];
        model.settingKey = VESettingKeyAdPreloadCount;
        model.currentValue = @(10);
        model.displayText = NSLocalizedStringFromTable(@"title_setting_ad_preload_count", @"VodLocalizable", nil);
        model.detailText = @"10";
        model.settingType = VESettingTypeMutilSelector;
        model;
    })];
    [adSection addObject:({
        VESettingModel *model = [VESettingModel new];
        model.settingKey = VESettingKeyAdInterval;
        model.currentValue = @(5);
        model.displayText = NSLocalizedStringFromTable(@"title_setting_ad_interval", @"VodLocalizable", nil);
        model.detailText = @"5";
        model.settingType = VESettingTypeMutilSelector;
        model;
    })];
    [self.settings setValue:adSection forKey:NSLocalizedStringFromTable(adSectionKey.copy, @"VodLocalizable", nil)];

    NSMutableArray *subtitleSection = [NSMutableArray array];
    [subtitleSection addObject:({
        VESettingModel *model = [VESettingModel new];
        model.settingKey = VESettingKeySubtitleEnable;
        model.open = NO;
        model.displayText = NSLocalizedStringFromTable(@"title_setting_subtitle_enable", @"VodLocalizable", nil);
        model.settingType = VESettingTypeSwitcher;
        model;
    })];
    [subtitleSection addObject:({
        VESettingModel *model = [VESettingModel new];
        model.settingKey = VESettingKeySubtitlePreloadEnable;
        model.open = YES;
        model.displayText = NSLocalizedStringFromTable(@"title_setting_subtitle_preload_enable", @"VodLocalizable", nil);
        model.settingType = VESettingTypeSwitcher;
        model.switchAction = ^{
            VESettingModel *preloadEnable = [self settingForKey:VESettingKeyShortVideoPreloadStrategy];
            if (model.open && !preloadEnable.open) {
                preloadEnable.open = YES;
            }
        };
        model;
    })];
    [subtitleSection addObject:({
        VESettingModel *model = [VESettingModel new];
        model.settingKey = VESettingKeySubtitleSourceType;
        model.currentValue = @(0);
        model.displayText = NSLocalizedStringFromTable(@"title_setting_subtitle_source_type", @"VodLocalizable", nil);
        model.detailText = @"Vid+SubtitleAuthToken";
        model.settingType = VESettingTypeMutilSelector;
        model.selectAction = ^{
            VESettingModel *playSourceType = [self settingForKey:VESettingKeyUniversalPlaySourceType];
            if ([model.currentValue integerValue] == 0 && [playSourceType.currentValue integerValue] == VEPlaySourceType_Url) {
                playSourceType.currentValue = @(VEPlaySourceType_Vid);
                playSourceType.detailText = NSLocalizedStringFromTable(@"title_setting_Source_Type_Vid", @"VodLocalizable", nil);
            }
        };
        model;
    })];
    [subtitleSection addObject:({
        VESettingModel *model = [VESettingModel new];
        model.settingKey = VESettingKeySubtitleDefaultLang;
        model.currentValue = @(1);
        model.displayText = NSLocalizedStringFromTable(@"title_setting_subtitle_default_language", @"VodLocalizable", nil);
        model.detailText = @"中文";
        model.settingType = VESettingTypeMutilSelector;
        model;
    })];
    [self.settings setValue:subtitleSection forKey:NSLocalizedStringFromTable(subtitleSectionKey.copy, @"VodLocalizable", nil)];

    NSMutableArray *universalActionSection = [NSMutableArray array];
    [universalActionSection addObject:({
        VESettingModel *model = [VESettingModel new];
        model.displayText = NSLocalizedStringFromTable(@"title_setting_clean_cache", @"VodLocalizable", nil);
        model.settingKey = VESettingKeyUniversalActionCleanCache;
        model.settingType = VESettingTypeDisplay;
        model.allAreaAction = ^{
            [VEVideoPlayerController cleanCache];
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:UIApplication.sharedApplication.keyWindow animated:YES];
            hud.mode = MBProgressHUDModeText;
            hud.label.text = NSLocalizedStringFromTable(@"tip_clean_success", @"VodLocalizable", nil);
            [hud hideAnimated:YES afterDelay:1.0];
        };
        model;
    })];
    [self.settings setValue:universalActionSection forKey:NSLocalizedStringFromTable(universalActionSectionKey.copy, @"VodLocalizable", nil)];
}

- (NSArray *)settingSections {
    @autoreleasepool {
        return @[NSLocalizedStringFromTable(debugSectionKey.copy, @"VodLocalizable", nil),
                 NSLocalizedStringFromTable(shortVideoSectionKey.copy, @"VodLocalizable", nil),
                 NSLocalizedStringFromTable(universalSectionKey.copy, @"VodLocalizable", nil),
                 NSLocalizedStringFromTable(adSectionKey.copy, @"VodLocalizable", nil),
                 NSLocalizedStringFromTable(subtitleSectionKey.copy, @"VodLocalizable", nil),
                 NSLocalizedStringFromTable(universalActionSectionKey.copy, @"VodLocalizable", nil)];
    }
}

- (VESettingModel *)settingForKey:(VESettingKey)key {
    NSArray *settings = [NSArray array];
    switch (key / 1000) {
        case 0:{
            settings = [self.settings objectForKey:NSLocalizedStringFromTable(universalSectionKey.copy, @"VodLocalizable", nil)];
        }
            break;
        case 1:{
            settings = [self.settings objectForKey:NSLocalizedStringFromTable(universalActionSectionKey.copy, @"VodLocalizable", nil)];
        }
            break;
        case 10:{
            settings = [self.settings objectForKey:NSLocalizedStringFromTable(shortVideoSectionKey.copy, @"VodLocalizable", nil)];
            break;
        }
        case 100:{
            settings = [self.settings objectForKey:NSLocalizedStringFromTable(debugSectionKey.copy, @"VodLocalizable", nil)];
            break;
        }
        case 1000:{
            settings = [self.settings objectForKey:NSLocalizedStringFromTable(adSectionKey.copy, @"VodLocalizable", nil)];
            break;
        }
        case 10000:{
            settings = [self.settings objectForKey:NSLocalizedStringFromTable(subtitleSectionKey.copy, @"VodLocalizable", nil)];
        }
            break;
    }
    for (VESettingModel *model in settings) {
        if (model.settingKey == key) return model;
    }
    return nil;
}

@end
