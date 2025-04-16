//
//  VEDramaVideoInfoModel.m
//  VEPlayModule
//

#import "VEDramaVideoInfoModel.h"
#import "VEVideoPlayerController+Resolution.h"
#import "VEDataManager.h"
#import "VESettingManager.h"
#import "NSString+BTDAdditions.h"

@implementation VEDramaItemModel

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


@implementation VEDramaVideoModel

+ (JSONKeyMapper*)keyMapper {
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{
        @"urlList": @"PlayInfoList",
    }];
}

+ (Class)classForCollectionProperty:(NSString *)propertyName {
    if ([propertyName isEqualToString:@"urlList"]) {
        return VEDramaItemModel.class;
    }
    return nil;
}

+ (BOOL)propertyIsOptional:(NSString*)propertyName {
    return YES;
}

@end

@implementation VEDramaVideoInfoModel

+ (JSONKeyMapper*)keyMapper {
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{
        @"title": @"caption",
        @"videoId": @"vid",
        @"coverUrl": @"coverUrl",
        @"duration": @"duration",
        @"playAuthToken": @"playAuthToken",
        @"subtitleAuthToken": @"subtitleAuthToken",
        @"dramaEpisodeInfo": @"episodeDetail",
    }];
}

+ (Class)classForCollectionProperty:(NSString *)propertyName {
    if ([propertyName isEqualToString:@"dramaEpisodeInfo"]) {
        return VEDramaEpisodeInfoModel.class;
    }
    return nil;
}

+ (BOOL)propertyIsOptional:(NSString*)propertyName {
    return YES;
}

#pragma mark - Public

+ (id<TTVideoEngineMediaSource>_Nullable)toVideoEngineSource:(VEDramaVideoInfoModel *_Nullable)dramaVideoModel {
    return [VEDramaVideoInfoModel toVideoEngineSource:dramaVideoModel forPreloadStrategy:NO];
}

+ (id<TTVideoEngineMediaSource>_Nullable)toVideoEngineSource:(VEDramaVideoInfoModel *_Nullable)dramaVideoModel forPreloadStrategy:(BOOL)forPreloadStrategy{
    if (!dramaVideoModel || !dramaVideoModel.videoId) {
        return nil;
    }

    if ([VEDataManager getRequestSourceType] == VERequestPlaySourceType_Vid) {
        TTVideoEngineVidSource *vidSource = [[TTVideoEngineVidSource alloc] initWithVid:dramaVideoModel.videoId playAuthToken:dramaVideoModel.playAuthToken resolution:[VEVideoPlayerController getPlayerCurrentResolution]];
        vidSource.title = dramaVideoModel.title;
        vidSource.cover = dramaVideoModel.coverUrl;
        vidSource.startTime = dramaVideoModel.startTime;
        return vidSource;
    } else if ([VEDataManager getRequestSourceType] == VERequestPlaySourceType_Url) {
        NSString *url = nil;
        VEDramaItemModel *videoItem = [dramaVideoModel.videoModel.urlList lastObject];
        if (videoItem) {
            url = videoItem.playUrl;
        }
        TTVideoEngineUrlSource *urlSource = [[TTVideoEngineUrlSource alloc] initWithUrl:url cacheKey:url.btd_md5String videoId:dramaVideoModel.videoId];
        // 设置字幕预加载信息
        if ([[VESettingManager universalManager] settingForKey:VESettingKeySubtitleEnable].open && dramaVideoModel.subtitleInfoDict && (!forPreloadStrategy || ([[VESettingManager universalManager] settingForKey:VESettingKeySubtitlePreloadEnable].open && [[VESettingManager universalManager] settingForKey:VESettingKeyShortVideoPreloadStrategy].open))) {
            TTVideoEngineSubDecInfoModel *subtitleInfoModel = [[TTVideoEngineSubDecInfoModel alloc] initWithDictionary:dramaVideoModel.subtitleInfoDict];
            urlSource.subtitleId = [VEDataManager getMatchedSubtitleId:subtitleInfoModel];
            urlSource.subtitleInfoModel = subtitleInfoModel;
        }
        urlSource.title = dramaVideoModel.title;
        urlSource.cover = dramaVideoModel.coverUrl;
        return urlSource;
    }
    return nil;
}

#pragma mark - Getter

// client test
- (VEDramaPayInfoModel *)payInfo {
    if (_payInfo == nil) {
        _payInfo = [[VEDramaPayInfoModel alloc] init];
    }
    return _payInfo;
}

@end
