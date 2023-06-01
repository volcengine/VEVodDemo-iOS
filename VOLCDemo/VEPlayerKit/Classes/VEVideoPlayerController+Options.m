//
//  VEVideoPlayerController+Options.m
//  VOLCDemo
//
//  Created by wangzhiyong on 2021/12/5.
//

#import "VEVideoPlayerController+Options.h"
#import <objc/message.h>

@implementation VEVideoPlayerController (EngineOptions)

- (void)setH265Open:(BOOL)h265Open {
    objc_setAssociatedObject(self, @selector(h265Open), @(h265Open), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)h265Open {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setHardwareDecodeOpen:(BOOL)hardwareDecodeOpen {
    objc_setAssociatedObject(self, @selector(hardwareDecodeOpen), @(hardwareDecodeOpen), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)hardwareDecodeOpen {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)openVideoEngineDefaultOptions {
    // system idle
    
    [self.videoEngine setOptionForKey:VEKKeyProxyServerEnable_BOOL value:@(YES)];
    
    [self.videoEngine setOptionForKey:VEKKeyPlayerIdleTimerAuto_NSInteger value:@(1)];
    self.videoEngine.medialoaderEnable = YES;
    // hardware Decode
//    [self.videoEngine setOptionForKey:VEKKeyPlayerHardwareDecode_BOOL value:@(self.hardwareDecodeOpen)];
    [self.videoEngine setOptionForKey:VEKKeyPlayerHardwareDecode_BOOL value:@(YES)];

    // h265
//    [self.videoEngine setOptionForKey:VEKKeyPlayerh265Enabled_BOOL value:@(self.h265Open)];
    [self.videoEngine setOptionForKey:VEKKeyPlayerh265Enabled_BOOL value:@(YES)];

    
    [self.videoEngine setOptionForKey:VEKKeyPlayerSeekEndEnabled_BOOL value:@(YES)];
    [self.videoEngine setOptionForKey:VEKKeyPlayerPreferSpdlForHDR_BOOL value:@(YES)];
    [self.videoEngine setOptionForKey:VEKKeyPlayerSetSpdlForHDRUrl_BOOL value:@(YES)];
    //[self.videoEngine setOptionForKey:VEKKeyIsEnableFindAmbientForHDR value:@(YES)];
    
}

@end
