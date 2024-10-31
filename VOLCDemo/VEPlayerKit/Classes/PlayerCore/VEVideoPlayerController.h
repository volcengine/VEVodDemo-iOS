//
//  VEVideoPlayerController.h
//  VOLCDemo
//
//  Created by wangzhiyong on 2021/11/11.
//  Copyright © 2021 ByteDance. All rights reserved.
//

@import UIKit;
#import "VEVideoPlayback.h"
#import <TTSDKFramework/TTSDKFramework.h>
#import "VEPlayerUIModule.h"
#import "VEPlayerBaseModule.h"
#import "VEVideoPlayerConfiguration.h"

NS_ASSUME_NONNULL_BEGIN

@interface VEPreRenderVideoEngineMediatorDelegate : NSObject <TTVideoEnginePreRenderDelegate>

+ (VEPreRenderVideoEngineMediatorDelegate *)shareInstance;

@end

@interface VEVideoPlayerController : UIViewController <VEPlayCoreAbilityProtocol, VEVideoPlayback>

@property (nonatomic, strong, readonly) TTVideoEngine *videoEngine;

@property (nonatomic, readonly) VEVideoPlayerConfiguration *playerConfig;

// VEPlayCoreAbilityProtocol
@property (nonatomic, weak) id<VEPlayCoreCallBackAbilityProtocol> _Nullable receiver;

- (instancetype)initWithConfiguration:(VEVideoPlayerConfiguration *)configuration;

- (instancetype)initWithConfiguration:(VEVideoPlayerConfiguration *)configuration 
                         moduleLoader:(VEPlayerBaseModule *)moduleLoader;

- (instancetype)initWithConfiguration:(VEVideoPlayerConfiguration *)configuration 
                         moduleLoader:(VEPlayerBaseModule *)moduleLoader
                  playerContainerView:(UIView * _Nullable)containerView;

- (void)loadBackgourdImageWithMediaSource:(id<TTVideoEngineMediaSource> _Nonnull)mediaSource;

- (void)startPip;

+ (void)cleanCache;

@end

NS_ASSUME_NONNULL_END
