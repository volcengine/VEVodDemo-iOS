//
//  VEDataManager.h
//  VOLCDemo
//
//  Created by real on 2022/8/22.
//  Copyright © 2022 ByteDance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VESettingModel.h"

typedef NS_ENUM(NSInteger, VERequestPlaySourceType) {
    VERequestPlaySourceType_Vid,
    VERequestPlaySourceType_Url,
};

typedef NS_ENUM(NSInteger, VESubtitleSourceType) {
    VESubtitleSourceType_Vid_AuthToken,
    VESubtitleSourceType_Url,
};

@class VEVideoModel;
@class TTVideoEngineSubDecInfoModel;
@interface VEDataManager : NSObject

+ (void)dataForScene:(VESceneType)type range:(NSRange)range result:(void(^)(NSArray<VEVideoModel *> *))result onError:(void(^)(NSString* errorMessage))onError;

+ (void)dataForScene:(VESceneType)type range:(NSRange)range result:(void(^)(NSArray<VEVideoModel *> *))result;

+ (VERequestPlaySourceType)getRequestSourceType;

+ (VESubtitleSourceType)getSubtitleSourceType;

+ (NSDictionary *)subtitleDictionaryFromSubtitleArray:(NSArray *)subtitleArray;

+ (NSInteger)getMatchedSubtitleId:(TTVideoEngineSubDecInfoModel *)subtitleInfoModel;

+ (NSDictionary *)buildSubtitleModels:(NSArray<VEVideoModel *> *)videoModels;

@end
