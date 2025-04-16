//
//  VEVideoPlayerConfiguration.m
//  VEPlayerKit
//
//  Created by zyw on 2024/7/16.
//

#import "VEVideoPlayerConfiguration.h"
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
        self.enableLoadSpeed = NO;

        self.isH265 = NO;
        self.isOpenHardware = YES;
        self.isOpenSR = NO;

        self.enableSubtitle = YES;
        self.subtitleSourceType = VEPlayerKitSubtitleSourceAuthToken;
    }
    return self;
}

@end
