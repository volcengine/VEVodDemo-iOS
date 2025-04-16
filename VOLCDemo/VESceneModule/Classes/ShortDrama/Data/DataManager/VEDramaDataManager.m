//
//  VEDramaDataManager.m
//  VEPlayModule
//

#import "VEDramaDataManager.h"
#import "VENetworkHelper.h"
#import "VESettingModel.h"
#import "ShortDramaCachePayManager.h"
#import "BTDMacros.h"
#import "VEDataManager.h"
#import "NSString+BTDAdditions.h"
#import "VEVideoPlayerConfiguration.h"

static NSString *requestDramaListUrl = @"https://vevod-demo-server.volcvod.com/api/drama/v1/listDrama";
static NSString *requestDramaRecommondListUrl = @"https://vevod-demo-server.volcvod.com/api/drama/episode/v1/getEpisodeFeedStreamWithPlayAuthToken";
static NSString *requestDramaEpisodeUrl = @"https://vevod-demo-server.volcvod.com/api/drama/episode/v1/getDramaEpisodeWithPlayAuthToken";
static NSString *requestDramaRecommondListDirectUrl = @"https://vevod-demo-server.volcvod.com/api/drama/episode/v1/getEpisodeFeedStreamWithVideoModel";
static NSString *requestDramaEpisodeDirectUrl = @"https://vevod-demo-server.volcvod.com/api/drama/episode/v1/getDramaEpisodeWithVideoModel";

@implementation VEDramaDataManager

+ (void)requestDramaList:(NSInteger)offset pageSize:(NSInteger)pageSize result:(RequestDataComplete)complete  {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray *dramas = [NSMutableArray array];

        NSMutableDictionary *param = [NSMutableDictionary dictionary];
        [param setObject:@"mini-drama-video" forKey:@"authorId"];
        [param setObject:@"mini-drama-video" forKey:@"userID"];
        [param setObject:@(offset) forKey:@"offset"];
        [param setObject:@(pageSize) forKey:@"pageSize"];

        [VENetworkHelper requestDataWithUrl:requestDramaListUrl httpMethod:@"POST" parameters:param success:^(id _Nonnull responseObject) {
            if (responseObject && [responseObject isKindOfClass:[NSDictionary class]]) {
                NSArray* results = [responseObject objectForKey:@"result"];
                for (NSDictionary *dic in results) {
                    VEDramaInfoModel *dramaModel = [[VEDramaInfoModel alloc] initWithDictionary:dic error:nil];
                    [dramas addObject:dramaModel];
                }
            }
            if (complete) {
                complete(dramas, nil);
            }
        } failure:^(NSString * _Nonnull errorMessage) {
            if (complete) {
                complete(nil, errorMessage);
            }
        }];
    });
}

+ (void)requestDramaRecommondList:(NSInteger)offset pageSize:(NSInteger)pageSize result:(RequestDataComplete)complete {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray *dramas = [NSMutableArray array];

        NSMutableDictionary *param = [NSMutableDictionary dictionary];
        [param setObject:@"mini-drama-video" forKey:@"authorId"];
        [param setObject:@"mini-drama-video" forKey:@"userID"];
        [param setObject:@(VEVideoCodecType_H264) forKey:@"codec"];
        [param setObject:@(VEVideoFormatType_MP4) forKey:@"format"];
        [param setObject:@(offset) forKey:@"offset"];
        [param setObject:@(pageSize) forKey:@"pageSize"];

        NSString *urlString = requestDramaRecommondListUrl;
        if ([VEDataManager getRequestSourceType] == VERequestPlaySourceType_Vid) {
            urlString = requestDramaRecommondListUrl;
        } else if ([VEDataManager getRequestSourceType] == VERequestPlaySourceType_Url) {
            urlString = requestDramaRecommondListDirectUrl;
        }

        [VENetworkHelper requestDataWithUrl:urlString httpMethod:@"POST" parameters:param success:^(id _Nonnull responseObject) {
            if (responseObject && [ responseObject isKindOfClass:[NSDictionary class]]) {
                NSArray* results = [responseObject objectForKey:@"result"];
                for (NSDictionary *dic in results) {
                    VEDramaVideoInfoModel *dramaVideoInfoModel = nil;
                    if ([VEDataManager getRequestSourceType] == VERequestPlaySourceType_Vid) {
                        dramaVideoInfoModel = [[VEDramaVideoInfoModel alloc] initWithDictionary:dic error:nil];
                    } else if ([VEDataManager getRequestSourceType] == VERequestPlaySourceType_Url) {
                        NSDictionary *videoModelDict = [self dictionaryWithJsonString:[dic objectForKey:@"videoModel"]];
                        VEDramaVideoModel *videoModel = [[VEDramaVideoModel alloc] initWithDictionary:videoModelDict error:nil];
                        dramaVideoInfoModel = [[VEDramaVideoInfoModel alloc] initWithDictionary:dic error:nil];
                        dramaVideoInfoModel.videoModel = videoModel;
                    }

                    if (dramaVideoInfoModel) {
                        // 解析对应的字幕信息subtitleModel，保存为NSDictionary，使用时直接通过dict转换为TTVideoEngineSubDecInfoModel
                        if ([VEDataManager getSubtitleSourceType] == VESubtitleSourceType_Url) {
                            NSDictionary *subtitleModelDict = [self dictionaryWithJsonString:[dic objectForKey:@"subtitleModel"]];
                            dramaVideoInfoModel.subtitleInfoDict = [VEDataManager subtitleDictionaryFromSubtitleArray:subtitleModelDict];
                        }
                        [dramas addObject:dramaVideoInfoModel];
                    }
                }
            }
            if (complete) {
                complete(dramas, nil);
            }
        } failure:^(NSString * _Nonnull errorMessage) {
            if (complete) {
                complete(nil, errorMessage);
            }
        }];
    });
}

+ (void)requestDramaEpisodeList:(NSString *)dramaId episodeNumber:(NSInteger)episodeNumber offset:(NSInteger)offset pageSize:(NSInteger)pageSize result:(RequestDataComplete)complete {
    if (!dramaId) {
        if (complete) {
            complete(nil, @"dramaId is nil !!!");
        }
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray *dramas = [NSMutableArray array];

        NSMutableDictionary *param = [NSMutableDictionary dictionary];
        [param setObject:@"mini-drama-video" forKey:@"authorId"];
        [param setObject:@"mini-drama-video" forKey:@"userID"];
        [param setObject:@(VEVideoCodecType_H264) forKey:@"codec"];
        [param setObject:@(VEVideoFormatType_MP4) forKey:@"format"];
        [param setObject:@(offset) forKey:@"offset"];
        [param setObject:@(pageSize) forKey:@"pageSize"];
        [param setObject:dramaId ?: @"" forKey:@"dramaId"];

        NSString *urlString = requestDramaEpisodeUrl;
        if ([VEDataManager getRequestSourceType] == VERequestPlaySourceType_Vid) {
            urlString = requestDramaEpisodeUrl;
        } else if ([VEDataManager getRequestSourceType] == VERequestPlaySourceType_Url) {
            urlString = requestDramaEpisodeDirectUrl;
        }

        @weakify(self);
        [VENetworkHelper requestDataWithUrl:urlString httpMethod:@"POST" parameters:param success:^(id _Nonnull responseObject) {
            @strongify(self);
            if (responseObject && [ responseObject isKindOfClass:[NSDictionary class]]) {
                NSArray* results = [responseObject objectForKey:@"result"];
                for (NSDictionary *dic in results) {
                    VEDramaVideoInfoModel *dramaVideoInfoModel = nil;
                    if ([VEDataManager getRequestSourceType] == VERequestPlaySourceType_Vid) {
                        dramaVideoInfoModel = [[VEDramaVideoInfoModel alloc] initWithDictionary:dic error:nil];
                    } else if ([VEDataManager getRequestSourceType] == VERequestPlaySourceType_Url) {
                        NSDictionary *videoModelDict = [self dictionaryWithJsonString:[dic objectForKey:@"videoModel"]];
                        VEDramaVideoModel *videoModel = [[VEDramaVideoModel alloc] initWithDictionary:videoModelDict error:nil];
                        dramaVideoInfoModel = [[VEDramaVideoInfoModel alloc] initWithDictionary:dic error:nil];
                        dramaVideoInfoModel.videoModel = videoModel;
                    }

                    if (dramaVideoInfoModel) {
                        // 解析对应的字幕信息subtitleModel，保存为NSDictionary，使用时直接通过dict转换为TTVideoEngineSubDecInfoModel
                        if ([VEDataManager getSubtitleSourceType] == VESubtitleSourceType_Url) {
                            NSDictionary *subtitleModelDict = [self dictionaryWithJsonString:[dic objectForKey:@"subtitleModel"]];
                            dramaVideoInfoModel.subtitleInfoDict = [VEDataManager subtitleDictionaryFromSubtitleArray:subtitleModelDict];
                        }
                        [dramas addObject:dramaVideoInfoModel];
                    }
                }
                // test drama pay
                if ([ShortDramaCachePayManager shareInstance].openPayTest) {
                    [[self class] testDramaPayVideoInfo:dramas];
                }
            }
            if (complete) {
                complete(dramas, nil);
            }
        } failure:^(NSString * _Nonnull errorMessage) {
            if (complete) {
                complete(nil, errorMessage);
            }
        }];
    });
}

+ (void)testDramaPayVideoInfo:(NSArray<VEDramaVideoInfoModel *> *)dramaVideoInfos {
    for (NSInteger i = 5; i < dramaVideoInfos.count; i++) {
        VEDramaVideoInfoModel *videoInfo = [dramaVideoInfos objectAtIndex:i];
        if ([[ShortDramaCachePayManager shareInstance] isPaidDrama:videoInfo.dramaEpisodeInfo.dramaInfo.dramaId episodeNumber:videoInfo.dramaEpisodeInfo.episodeNumber]) {
            videoInfo.payInfo.payStatus = VEDramaPayStatus_Paid;
        } else {
            videoInfo.payInfo.payStatus = VEDramaPayStatus_Unpaid;
        }
    }
}

+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }

    NSError *error;
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dictionay = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&error];
    if(error) {
        return nil;
    }
    return dictionay;
}

+ (NSDictionary *)buildSubtitleModels:(NSArray<id> *)dramaVideoModels {
    NSMutableDictionary *models = nil;
    if ([VEDataManager getSubtitleSourceType] == VEPlayerKitSubtitleSourceAuthToken) {
        models = [NSMutableDictionary dictionary];
        [dramaVideoModels enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[VEDramaVideoInfoModel class]]) {
                VEDramaVideoInfoModel *videoInfoModel = obj;
                if (videoInfoModel.subtitleAuthToken) {
                    [models setObject: videoInfoModel.subtitleAuthToken forKey:videoInfoModel.videoId];
                }
            }
        }];
    } else if ([VEDataManager getSubtitleSourceType] == VEPlayerKitSubtitleSourceDirectUrl) {
        models = [NSMutableDictionary dictionary];
        [dramaVideoModels enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[VEDramaVideoInfoModel class]]) {
                VEDramaVideoInfoModel *videoInfoModel = obj;
                if (videoInfoModel.subtitleInfoDict) {
                    TTVideoEngineSubDecInfoModel *subtitleInfoModel = [[TTVideoEngineSubDecInfoModel alloc] initWithDictionary:videoInfoModel.subtitleInfoDict];
                    NSInteger subtitleId = [VEDataManager getMatchedSubtitleId:subtitleInfoModel];
                    NSDictionary *subInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                             @(subtitleId),         @"id",
                                             subtitleInfoModel,     @"model",
                                             nil];
                    if ([VEDataManager getRequestSourceType] == VERequestPlaySourceType_Vid) {
                        [models setObject:subInfo forKey:videoInfoModel.videoId];
                    } else if ([VEDataManager getRequestSourceType] == VERequestPlaySourceType_Url) {
                        NSString *url = nil;
                        VEDramaItemModel *videoItem = [videoInfoModel.videoModel.urlList lastObject];
                        if (videoItem) {
                            url = videoItem.playUrl;
                        }
                        [models setObject:subInfo forKey:url.btd_md5String];
                    }
                }
            }
        }];
    }
    return [models copy];
}

@end
