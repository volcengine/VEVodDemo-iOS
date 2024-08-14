//
//  VEVideoPlayerConfiguration.m
//  VEPlayerKit
//
//  Created by zyw on 2024/7/16.
//

#import "VEVideoPlayerConfiguration.h"
#import "VESettingManager.h"
#import <TTSDKFramework/TTSDKFramework.h>

@implementation VEVideoPlayerConfiguration

+ (VEVideoPlayerConfiguration *)defaultPlayerConfiguration {
    VEVideoPlayerConfiguration *playerConfigration = [[VEVideoPlayerConfiguration alloc] init];
    return playerConfigration;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.videoViewMode = VEVideoViewModeAspectFill;
        self.audioMode = NO;
        self.muted = NO;
        self.looping = NO;
        self.playbackRate = 1.0;
        self.startTime = 0;
        self.isSupportPictureInPictureMode = NO;
        self.enableLoadSpeed = YES;
        
        VESettingModel *h265 = [[VESettingManager universalManager] settingForKey:VESettingKeyUniversalH265];
        VESettingModel *hardwareDecode = [[VESettingManager universalManager] settingForKey:VESettingKeyUniversalHardwareDecode];
        VESettingModel *sr = [[VESettingManager universalManager] settingForKey:VESettingKeyUniversalSR];
        self.isH265 = h265; // 默认设置为 NO；
        self.isOpenHardware = hardwareDecode; // 默认设置为 YES；
        self.isOpenSR = sr; // 默认设置 NO；
    }
    return self;
}

@end
