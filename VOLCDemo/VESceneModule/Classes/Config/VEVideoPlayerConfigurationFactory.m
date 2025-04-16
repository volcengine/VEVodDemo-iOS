//
//  VEVideoPlayerConfigurationFactory.m
//  VOLCDemo
//
//  Created by litao.he on 2025/3/7.
//

#import "VEVideoPlayerConfigurationFactory.h"
#import "VESettingManager.h"

@implementation VEVideoPlayerConfigurationFactory

+ (VEVideoPlayerConfiguration *)getConfiguration {
    VEVideoPlayerConfiguration *configration = [VEVideoPlayerConfiguration defaultPlayerConfiguration];

    configration.isH265 = [[VESettingManager universalManager] settingForKey:VESettingKeyUniversalH265].open;
    configration.isOpenHardware = [[VESettingManager universalManager] settingForKey:VESettingKeyUniversalHardwareDecode].open;
    configration.isOpenSR = [[VESettingManager universalManager] settingForKey:VESettingKeyUniversalSR].open;
    configration.enableSubtitle = [[VESettingManager universalManager] settingForKey:VESettingKeySubtitleEnable].open;
    configration.subtitleSourceType = [[[VESettingManager universalManager] settingForKey:VESettingKeySubtitleSourceType].currentValue integerValue];

    if (@available(iOS 15.0, *)) {
        configration.enablePip = [[VESettingManager universalManager] settingForKey:VESettingKeyUniversalPip].open;
    } else {
        configration.enablePip = NO;
    }
    return configration;
}

@end
