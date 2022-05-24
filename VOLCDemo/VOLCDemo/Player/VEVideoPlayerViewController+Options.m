//
//  VEVideoPlayerViewController+Options.m
//  VOLCDemo
//
//  Created by wangzhiyong on 2021/12/5.
//

#import "VEVideoPlayerViewController+Options.h"
#import "VEUserGlobalConfiguration.h"

@implementation VEVideoPlayerViewController (EngineOptions)

+ (void)setVideoEngineOptions:(TTVideoEngine *)videoEngine {
    if (!videoEngine) return;
    
    VEUserGlobalConfiguration *globalConfigs = [VEUserGlobalConfiguration sharedInstance];
    
    /// hardware decode,  suggest open
    [videoEngine setOptionForKey:VEKKeyPlayerHardwareDecode_BOOL value:@(globalConfigs.isHardDecodeOn)];

    /// h265 option
    [videoEngine setOptionForKey:VEKKeyPlayerh265Enabled_BOOL value:@(globalConfigs.isH265Enabled)];
}

@end
