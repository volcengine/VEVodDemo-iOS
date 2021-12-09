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
    
    /// render engine, suggest use TTVideoEngineRenderEngineMetal
    [videoEngine setOptionForKey:VEKKeyViewRenderEngine_ENUM value:@(TTVideoEngineRenderEngineMetal)];
    
    /// optimize seek time-consuming, suggest open
    [videoEngine setOptionForKey:VEKKeyPlayerPreferNearestSampleEnable value:@(YES)];
    
    [videoEngine setOptionForKey:VEKKeyProxyServerEnable_BOOL value:@(YES)];
    
    /// Can optimize video id to play the first frame
    [videoEngine setOptionForKey:VEKKeyModelCacheVideoInfoEnable_BOOL value:@(YES)];
    
    /// report engine log
    videoEngine.reportLogEnable = globalConfigs.isEngineReportLog;
}

@end
