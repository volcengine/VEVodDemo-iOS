//
//  VEVideoModel.m
//  VOLCDemo
//
//  Created by wangzhiyong on 2021/5/24.
//  Copyright © 2021 ByteDance. All rights reserved.
//

#import "VEVideoModel.h"
#import "VEVideoPlayerController+Resolution.h"
#import "NSString+VE.h"
#import "VESettingManager.h"
#import <JSONModel/JSONModel.h>
#import "VEDataManager.h"

@implementation VEVideoEngineURLInfo

+ (JSONKeyMapper*)keyMapper {
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{
        @"playUrl": @"MainPlayUrl",
    }];
}

+ (BOOL)propertyIsOptional:(NSString*)propertyName {
    return YES;
}

@end


@implementation VEVideoEngineInfoModel

+ (JSONKeyMapper*)keyMapper {
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{
        @"videoID": @"Vid",
        @"urlList": @"PlayInfoList",
    }];
}

+ (Class)classForCollectionProperty:(NSString *)propertyName {
    if ([propertyName isEqualToString:@"urlList"]) {
        return VEVideoEngineURLInfo.class;
    }
    return nil;
}

+ (BOOL)propertyIsOptional:(NSString*)propertyName {
    return YES;
}

@end


@implementation VEVideoModel

+ (JSONKeyMapper*)keyMapper {
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{
        @"videoId": @"vid",
        @"title": @"caption",
        @"coverUrl": @"coverUrl",
        @"playAuthToken": @"playAuthToken",
        @"duration": @"duration",
    }];
}

+ (BOOL)propertyIsOptional:(NSString*)propertyName {
    return YES;
}

+ (id<TTVideoEngineMediaSource>)ConvertVideoEngineSource:(VEVideoModel *)videoModel {
    if ([VEDataManager getRequestSourceType] == VERequestPlaySourceType_Vid) {
        VESettingModel *h265 = [[VESettingManager universalManager] settingForKey:VESettingKeyUniversalH265];
        TTVideoEngineEncodeType codec = h265.open ? TTVideoEngineh265 : TTVideoEngineH264;
        TTVideoEngineVidSource *source = [[TTVideoEngineVidSource alloc] initWithVid:videoModel.videoId playAuthToken:videoModel.playAuthToken resolution:[VEVideoPlayerController getPlayerCurrentResolution] encodeType:codec isDash:NO isHLS:NO];
        source.title = videoModel.title;
        source.cover = videoModel.coverUrl;
        return source;
    } else if ([VEDataManager getRequestSourceType] == VERequestPlaySourceType_Url) {
        NSString *url = nil;
        VEVideoEngineURLInfo *urlInfo = [videoModel.videoEngineInfoModel.urlList lastObject];
        if (urlInfo) {
            url = urlInfo.playUrl;
        } else {
            url = videoModel.playUrl;
        }
        TTVideoEngineUrlSource *source = [[TTVideoEngineUrlSource alloc] initWithUrl:url cacheKey:url.vloc_md5String videoId:videoModel.videoId];
        source.title = videoModel.title;
        source.cover = videoModel.coverUrl;
        return source;
    }
    return nil;
}

@end
