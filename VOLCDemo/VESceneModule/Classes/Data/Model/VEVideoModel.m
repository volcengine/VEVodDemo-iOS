//
//  VEVideoModel.m
//  VOLCDemo
//
//  Created by wangzhiyong on 2021/5/24.
//  Copyright © 2021 ByteDance. All rights reserved.
//

#import "VEVideoModel.h"
#import "VEVideoPlayerController+Resolution.h"
#import "NSString+BTDAdditions.h"
#import "VESettingManager.h"
#import <JSONModel/JSONModel.h>
#import "VEDataManager.h"

@implementation VEVideoItemModel

+ (JSONKeyMapper*)keyMapper {
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{
        @"playUrl": @"MainPlayUrl",
        @"fileId": @"FileId",
    }];
}

+ (BOOL)propertyIsOptional:(NSString*)propertyName {
    return YES;
}

@end


@implementation VEVideoInfoModel

+ (JSONKeyMapper*)keyMapper {
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{
        @"urlList": @"PlayInfoList",
    }];
}

+ (Class)classForCollectionProperty:(NSString *)propertyName {
    if ([propertyName isEqualToString:@"urlList"]) {
        return VEVideoItemModel.class;
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
        @"subtitleAuthToken": @"subtitleAuthToken"
    }];
}

+ (BOOL)propertyIsOptional:(NSString*)propertyName {
    return YES;
}

+ (id<TTVideoEngineMediaSource>_Nullable)ConvertVideoEngineSource:(VEVideoModel *_Nullable)videoModel {
    return [VEVideoModel ConvertVideoEngineSource:videoModel forPreloadStrategy:NO];
}

+ (id<TTVideoEngineMediaSource>)ConvertVideoEngineSource:(VEVideoModel *)videoModel forPreloadStrategy:(BOOL)forPreloadStrategy {
    if ([VEDataManager getRequestSourceType] == VERequestPlaySourceType_Vid) {
        VESettingModel *h265 = [[VESettingManager universalManager] settingForKey:VESettingKeyUniversalH265];
        TTVideoEngineEncodeType codec = h265.open ? TTVideoEngineh265 : TTVideoEngineH264;
        TTVideoEngineVidSource *source = [[TTVideoEngineVidSource alloc] initWithVid:videoModel.videoId playAuthToken:videoModel.playAuthToken resolution:[VEVideoPlayerController getPlayerCurrentResolution] encodeType:codec isDash:NO isHLS:NO];
        source.title = videoModel.title;
        source.cover = videoModel.coverUrl;
        return source;
    } else if ([VEDataManager getRequestSourceType] == VERequestPlaySourceType_Url) {
        NSString *url = nil;
        VEVideoItemModel *videoItem = [videoModel.videoInfoModel.urlList lastObject];
        if (videoItem) {
            url = videoItem.playUrl;
        } else {
            url = videoModel.playUrl;
        }
        TTVideoEngineUrlSource *source = [[TTVideoEngineUrlSource alloc] initWithUrl:url cacheKey:url.btd_md5String videoId:videoModel.videoId];
        // 设置字幕预加载信息
        if ([[VESettingManager universalManager] settingForKey:VESettingKeySubtitleEnable].open && videoModel.subtitleInfoDict && (!forPreloadStrategy || ([[VESettingManager universalManager] settingForKey:VESettingKeySubtitlePreloadEnable].open && [[VESettingManager universalManager] settingForKey:VESettingKeyShortVideoPreloadStrategy].open))) {
            TTVideoEngineSubDecInfoModel *subtitleInfoModel = [[TTVideoEngineSubDecInfoModel alloc] initWithDictionary:videoModel.subtitleInfoDict];
            source.subtitleId = [VEDataManager getMatchedSubtitleId:subtitleInfoModel];
            source.subtitleInfoModel = subtitleInfoModel;
        }
        source.title = videoModel.title;
        source.cover = videoModel.coverUrl;
        return source;
    }
    return nil;
}

@end
