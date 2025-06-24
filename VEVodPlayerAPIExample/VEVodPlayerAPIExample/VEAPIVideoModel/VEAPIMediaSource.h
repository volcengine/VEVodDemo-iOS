// Copyright (c) 2025 Beijing Volcano Engine Technology Co., Ltd.
// SPDX-License-Identifier: MIT
//
//  VEAPIMediaSource.h
//  VEVodPlayerAPIExample
//
//  Created by ByteDance on 2025/6/25.
//

#import <Foundation/Foundation.h>
#import <TTSDKFramework/TTSDKFramework.h>

NS_ASSUME_NONNULL_BEGIN

@class VEAPIVideoModel;

@interface VEAPIMediaSource : NSObject

+ (TTVideoEngineUrlSource *)initDirectUrlSource:(NSString *)directUrl;
+ (TTVideoEngineVidSource *)initVidSource:(NSString *)vid playAuthToken:(NSString *)playAuthToken resolution:(TTVideoEngineResolutionType)resolution;
+ (NSArray<id<TTVideoEngineMediaSource>> *)covertVideoModelsToTTVideoEngineSources:(NSArray<VEAPIVideoModel *> *)videoModels;

@end

NS_ASSUME_NONNULL_END
