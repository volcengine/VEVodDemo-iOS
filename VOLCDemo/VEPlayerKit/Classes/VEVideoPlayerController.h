//
//  VEVideoPlayerController.h
//  VOLCDemo
//
//  Created by wangzhiyong on 2021/11/11.
//  Copyright © 2021 ByteDance. All rights reserved.
//

@import UIKit;
#import "VEVideoPlayback.h"
#import "VEVideoPlaybackPanel.h"
#import <TTSDK/TTVideoEngineHeader.h>
#import <VEPlayerUIModule/VEPlayerUIModule.h>

NS_ASSUME_NONNULL_BEGIN

@interface VEPreRenderVideoEngineMediatorDelegate : NSObject <TTVideoEnginePreRenderDelegate>

+ (VEPreRenderVideoEngineMediatorDelegate *)shareInstance;

@end


@interface VEVideoPlayerController : UIViewController <VEVideoPlayback, VEPlayCoreAbilityProtocol>

@property (nonatomic, strong, readonly) TTVideoEngine *videoEngine;

// VEPlayCoreAbilityProtocol
@property (nonatomic, weak) id<VEPlayCoreCallBackAbilityProtocol> _Nullable receiver;

- (void)loadBackgourdImageWithMediaSource:(id<TTVideoEngineMediaSource> _Nonnull)mediaSource;

+ (void)cleanCache;

@end

NS_ASSUME_NONNULL_END
