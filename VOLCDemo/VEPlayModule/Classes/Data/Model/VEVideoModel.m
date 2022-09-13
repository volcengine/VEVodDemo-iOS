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

@implementation VEVideoModel

+ (JSONKeyMapper*)keyMapper {
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{
        @"videoId": @"vid",
        @"title": @"caption",
        @"coverUrl": @"coverUrl",
        @"playAuthToken": @"playAuthToken",
        @"duration": @"duration"
    }];
}

+ (BOOL)propertyIsOptional:(NSString*)propertyName {
    return YES;
}

+ (TTVideoEngineVidSource *)videoEngineVidSource:(VEVideoModel *)videoModel {
    VESettingModel *h265 = [[VESettingManager universalManager] settingForKey:VESettingKeyUniversalH265];
    TTVideoEngineEncodeType codec = h265.open ? TTVideoEngineh265 : TTVideoEngineH264;
    TTVideoEngineVidSource *source = [[TTVideoEngineVidSource alloc] initWithVid:videoModel.videoId playAuthToken:videoModel.playAuthToken resolution:[VEVideoPlayerController getPlayerCurrentResolution] encodeType:codec isDash:NO isHLS:NO];
    source.title = videoModel.title;
    source.cover = videoModel.coverUrl;
    return source;
}

+ (TTVideoEngineUrlSource *)videoEngineUrlSource:(VEVideoModel *)videoModel {
    TTVideoEngineUrlSource *source = [[TTVideoEngineUrlSource alloc] initWithUrl:videoModel.playUrl cacheKey:videoModel.playUrl.vloc_md5String videoId:videoModel.videoId];
    source.title = videoModel.title;
    source.cover = videoModel.coverUrl;
    return source;
}



@end
