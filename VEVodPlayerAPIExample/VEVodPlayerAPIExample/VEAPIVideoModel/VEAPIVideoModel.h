// Copyright (c) 2025 Beijing Volcano Engine Technology Co., Ltd.
// SPDX-License-Identifier: MIT
//
//  VEAPIVideoModel.h
//  VEVodPlayerAPIExample
//
//  Created by ByteDance on 2025/5/27.
//

#import <Foundation/Foundation.h>
#import <TTSDKFramework/TTSDKFramework.h>

NS_ASSUME_NONNULL_BEGIN

@interface VEAPIVideoModel : NSObject

@property (nonatomic, strong, nonnull) NSString *vid;
@property (nonatomic, strong, nonnull) NSString *playAuthToken;
@property (nonatomic, strong, nonnull) NSString *subtitleAuthToken;
@property (nonatomic, strong, nonnull) NSString *videoUrl;
@property (nonatomic, strong, nonnull) NSString *subtitleModels;
@property (nonatomic, strong, nonnull) NSString *coverUrl;

+ (NSArray<VEAPIVideoModel *> *)defaultVideoModel;
+ (NSArray<NSDictionary<NSString *, NSNumber *> *> *)defaultSubtitleSubIDs;
+ (instancetype)modelWithVid:(NSString *)vid
               PlayAuthToken:(NSString *)playAuthToken
           SubtitleAuthToken:(NSString *)subtitleAuthToken
                    VideoUrl:(NSString *)videoUrl
               SubtitleModel:(NSString *)subtitleModels
                    CoverUrl:(NSString *)coverUrl;
+ (void)removeAllCaches:(BOOL)flag;

@end

NS_ASSUME_NONNULL_END
