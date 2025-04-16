//
//  VEVideoPlayerController+DebugTool.m
//  VOLCDemo
//
//  Created by wangzhiyong on 2021/12/6.
//

#import "VEVideoPlayerController+DebugTool.h"
#import <objc/runtime.h>
#import <RangersAppLog/RangersAppLog.h>

@implementation VEVideoPlayerController (DebugTool)

- (void)showDebugViewInView:(UIView *)hudView {
    self.videoEngineDebugTool.videoEngine = self.videoEngine;
    [self.videoEngineDebugTool setDebugInfoView:hudView];
    self.videoEngineDebugTool.indexForSuperView = 0;
    [self.videoEngineDebugTool start];
}

- (void)removeDebugTool {
    [self.videoEngineDebugTool remove];
}

- (void)setVideoEngineDebugTool:(TTVideoEngineDebugTools *)videoEngineDebugTool {
    objc_setAssociatedObject(self, @selector(videoEngineDebugTool), videoEngineDebugTool, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (TTVideoEngineDebugTools *)videoEngineDebugTool {
    TTVideoEngineDebugTools *debugTools = objc_getAssociatedObject(self, @selector(videoEngineDebugTool));
    if (debugTools == nil) {
        debugTools = [[TTVideoEngineDebugTools alloc] init];
        debugTools.debugToolsEnable = YES;
        [self setVideoEngineDebugTool:debugTools];
    }
    return debugTools;
}

+ (NSString *)deviceID {
    // 这里需要业务填写自己的 Appid
    NSString *appId = @"";
    return appId.length > 0 ? [[BDAutoTrack trackWithAppID:appId] rangersDeviceID] : @"请查看源码，替换 Appid";
}

@end
