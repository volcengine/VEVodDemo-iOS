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

const NSString *shortVideoSectionKey = @"短视频策略";

const NSString *universalSectionKey = @"通用选项";

const NSString *universalActionSectionKey = @"通用操作"; // clear, log out?

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
    NSMutableArray *shortVideoSection = [NSMutableArray array];
    [shortVideoSection addObject:({
        VESettingModel *model = [VESettingModel new];
        model.displayText = @"预加载策略";
        model.settingKey = VESettingKeyShortVideoPreloadStrategy;
        model.open = YES;
        model.settingType = VESettingTypeSwitcher;
        model;
    })];
    [shortVideoSection addObject:({
        VESettingModel *model = [VESettingModel new];
        model.displayText = @"预渲染策略";
        model.settingKey = VESettingKeyShortVideoPreRenderStrategy;
        model.open = YES;
        model.settingType = VESettingTypeSwitcher;
        model;
    })];
    [self.settings setValue:shortVideoSection forKey:shortVideoSectionKey];
    
    NSMutableArray *universalSection = [NSMutableArray array];
    [universalSection addObject:({
        VESettingModel *model = [VESettingModel new];
        model.displayText = @"H.265";
        model.settingKey = VESettingKeyUniversalH265;
        model.open = YES;
        model.settingType = VESettingTypeSwitcher;
        model;
    })];
    [universalSection addObject:({
        VESettingModel *model = [VESettingModel new];
        model.displayText = @"硬件解码";
        model.settingKey = VESettingKeyUniversalHardwareDecode;
        model.open = YES;
        model.settingType = VESettingTypeSwitcher;
        model;
    })];
    [universalSection addObject:({
        VESettingModel *model = [VESettingModel new];
        model.displayText = @"Device ID";
        model.settingKey = VESettingKeyUniversalDeviceID;
        model.detailText = [VEVideoPlayerController deviceID];
        model.settingType = VESettingTypeDisplayDetail;
        model;
    })];
    [self.settings setValue:universalSection forKey:universalSectionKey];
    
    NSMutableArray *universalActionSection = [NSMutableArray array];
    [universalActionSection addObject:({
        VESettingModel *model = [VESettingModel new];
        model.displayText = @"清理缓存";
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
    [self.settings setValue:universalActionSection forKey:universalActionSectionKey];
}

- (NSArray *)settingSections {
    @autoreleasepool {
        return @[shortVideoSectionKey, universalSectionKey, universalActionSectionKey];
    }
}

- (VESettingModel *)settingForKey:(VESettingKey)key {
    NSArray *settings = [NSArray array];
    switch (key / 1000) {
        case 0:{
            settings = [self.settings objectForKey:universalSectionKey];
        }
            break;
        case 1:{
            settings = [self.settings objectForKey:universalActionSectionKey];
        }
            break;
        case 10:{
            settings = [self.settings objectForKey:shortVideoSectionKey];
        }
            break;
    }
    for (VESettingModel *model in settings) {
        if (model.settingKey == key) return model;
    }
    return nil;
}

@end
