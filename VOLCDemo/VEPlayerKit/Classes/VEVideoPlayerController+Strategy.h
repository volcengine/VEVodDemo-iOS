//
//  VEVideoPlayerController+Strategy.h
//  VOLCDemo
//
//  Created by real on 2022/8/22.
//  Copyright © 2022 ByteDance. All rights reserved.
//

#import "VEVideoPlayerController.h"

@interface VEVideoPlayerController (Strategy)

@property (nonatomic, assign) BOOL preRenderOpen;

@property (nonatomic, assign) BOOL preloadOpen;

+ (BOOL)enableEngineStrategy:(TTVideoEngineStrategyType)strategyType scene:(NSString *)scene;

+ (void)setStrategyVideoSources:(NSArray<id<TTVideoEngineMediaSource>> *)videoSources;

+ (void)addStrategyVideoSources:(NSArray<id<TTVideoEngineMediaSource>> *)videoSources;

+ (void)clearAllEngineStrategy;

@end

