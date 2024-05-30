//
//  VEDramaVideoInfoModel.m
//  VEPlayModule
//

#import "VEDramaVideoInfoModel.h"
#import "VEVideoPlayerController+Resolution.h"

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

+ (id<TTVideoEngineMediaSource>_Nullable)toVideoEngineSource:(VEDramaVideoInfoModel *_Nullable)dramaVideoModel {
    if (dramaVideoModel && dramaVideoModel.videoId && dramaVideoModel.playAuthToken) {
        TTVideoEngineVidSource *vidSource = [[TTVideoEngineVidSource alloc] initWithVid:dramaVideoModel.videoId playAuthToken:dramaVideoModel.playAuthToken resolution:[VEVideoPlayerController getPlayerCurrentResolution]];
        vidSource.title = dramaVideoModel.title;
        vidSource.cover = dramaVideoModel.coverUrl;
        vidSource.startTime = dramaVideoModel.startTime;
        return vidSource;
    }
    return nil;
}

@end
