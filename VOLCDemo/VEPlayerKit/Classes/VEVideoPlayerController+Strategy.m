//
//  VEVideoPlayerController+Strategy.m
//  VOLCDemo
//
//  Created by real on 2022/8/22.
//  Copyright © 2022 ByteDance. All rights reserved.
//

#import "VEVideoPlayerController+Strategy.h"
#import <TTSDKFramework/TTVideoEngine+Strategy.h>
#import <objc/message.h>

@implementation VEVideoPlayerController (Strategy)

- (void)setPreloadOpen:(BOOL)preloadOpen {
    objc_setAssociatedObject(self, @selector(preloadOpen), @(preloadOpen), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)preloadOpen {
    return [objc_getAssociatedObject(self, _cmd) unsignedIntegerValue];
}

- (void)setPreRenderOpen:(BOOL)preRenderOpen {
    objc_setAssociatedObject(self, @selector(preRenderOpen), @(preRenderOpen), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)preRenderOpen {
    return [objc_getAssociatedObject(self, _cmd) unsignedIntegerValue];
}

+ (BOOL)enableEngineStrategy:(TTVideoEngineStrategyType)strategyType scene:(NSString *)scene {
    return [TTVideoEngine enableEngineStrategy:strategyType scene:scene];
}

+ (void)setStrategyVideoSources:(NSArray<id<TTVideoEngineMediaSource>> *)videoSources {
    [TTVideoEngine setStrategyVideoSources:videoSources];
}

+ (void)addStrategyVideoSources:(NSArray<id<TTVideoEngineMediaSource>> *)videoSources {
    [TTVideoEngine addStrategyVideoSources:videoSources];
}

+ (void)clearAllEngineStrategy {
    [TTVideoEngine clearAllEngineStrategy];
}

@end
