// Copyright (c) 2025 Beijing Volcano Engine Technology Co., Ltd.
// SPDX-License-Identifier: MIT
//
//  VEAPIMediaSource.m
//  VEVodPlayerAPIExample
//
//  Created by ByteDance on 2025/6/25.
//

#import "VEAPIMediaSource.h"
#import "VEAPITools.h"
#import "VEAPIVideoModel.h"

@implementation VEAPIMediaSource

+ (TTVideoEngineUrlSource *)initDirectUrlSource:(NSString *)directUrl {
    NSString *cacheKey = [VEAPITools md5With:directUrl];
    return [[TTVideoEngineUrlSource alloc] initWithUrl:directUrl cacheKey:cacheKey];
}

+ (TTVideoEngineVidSource *)initVidSource:(NSString *)vid playAuthToken:(NSString *)playAuthToken resolution:(TTVideoEngineResolutionType)resolution {
    return [[TTVideoEngineVidSource alloc] initWithVid:vid playAuthToken:playAuthToken resolution:resolution];
}

+ (NSArray<id<TTVideoEngineMediaSource>> *)covertVideoModelsToTTVideoEngineSources:(NSArray<VEAPIVideoModel *> *)videoModels {
    NSMutableArray *retArray = [NSMutableArray array];
    [videoModels enumerateObjectsUsingBlock:^(VEAPIVideoModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSObject *tempObj = [VEAPIMediaSource convertVideoModelToTTVideoEngineSource:obj];
        if (tempObj) {
            [retArray addObject:tempObj];
        }
    }];
    return [retArray copy];
}

+ (id<TTVideoEngineMediaSource>)convertVideoModelToTTVideoEngineSource:(VEAPIVideoModel *)videoModel {
    id<TTVideoEngineMediaSource> source = nil;
    if (videoModel.videoUrl != NULL) {
        NSString *cacheKey = [VEAPITools md5With:videoModel.videoUrl];
        source = [[TTVideoEngineUrlSource alloc] initWithUrl:videoModel.videoUrl cacheKey:cacheKey];
    }else if (videoModel.vid != NULL && videoModel.playAuthToken != NULL) {
        TTVideoEngineResolutionType resolution = TTVideoEngineResolutionTypeFullHD;
        source = [[TTVideoEngineVidSource alloc] initWithVid:videoModel.vid playAuthToken:videoModel.playAuthToken resolution:resolution];
    }
    return source;
}

@end
