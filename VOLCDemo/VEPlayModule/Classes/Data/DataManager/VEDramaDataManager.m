//
//  VEDramaDataManager.m
//  VEPlayModule
//

#import "VEDramaDataManager.h"
#import "VENetworkHelper.h"

static NSString *requestDramaListUrl = @"https://vevod-demo-server.volcvod.com/api/drama/v1/listDrama";
static NSString *requestDramaRecommondListUrl = @"https://vevod-demo-server.volcvod.com/api/drama/episode/v1/getEpisodeFeedStreamWithPlayAuthToken";
static NSString *requestDramaEpisodeUrl = @"https://vevod-demo-server.volcvod.com/api/drama/episode/v1/getDramaEpisodeWithPlayAuthToken";

@implementation VEDramaDataManager

+ (void)requestDramaList:(NSInteger)offset pageSize:(NSInteger)pageSize result:(RequestDataComplete)complete  {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray *dramas = [NSMutableArray array];

        NSMutableDictionary *param = [NSMutableDictionary dictionary];
        [param setObject:@"mini-drama-video" forKey:@"authorId"];
        [param setObject:@"mini-drama-video" forKey:@"userID"];
        [param setObject:@"H264" forKey:@"Codec"];
        [param setObject:@"mp4" forKey:@"Format"];
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
        [param setObject:@"H264" forKey:@"Codec"];
        [param setObject:@"mp4" forKey:@"Format"];
        [param setObject:@(offset) forKey:@"offset"];
        [param setObject:@(pageSize) forKey:@"pageSize"];
        [VENetworkHelper requestDataWithUrl:requestDramaRecommondListUrl httpMethod:@"POST" parameters:param success:^(id _Nonnull responseObject) {
            if (responseObject && [ responseObject isKindOfClass:[NSDictionary class]]) {
                NSArray* results = [responseObject objectForKey:@"result"];
                for (NSDictionary *dic in results) {
                    VEDramaVideoInfoModel *dramaVideoInfoModel = [[VEDramaVideoInfoModel alloc] initWithDictionary:dic error:nil];
                    [dramas addObject:dramaVideoInfoModel];
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

+ (void)requestDramaEpisodeList:(NSString *)dramaId offset:(NSInteger)offset pageSize:(NSInteger)pageSize result:(RequestDataComplete)complete {
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
        [param setObject:@"H264" forKey:@"Codec"];
        [param setObject:@"mp4" forKey:@"Format"];
        [param setObject:@(offset) forKey:@"offset"];
        [param setObject:@(pageSize) forKey:@"pageSize"];
        [param setObject:dramaId ?: @"" forKey:@"dramaId"];
        [VENetworkHelper requestDataWithUrl:requestDramaEpisodeUrl httpMethod:@"POST" parameters:param success:^(id _Nonnull responseObject) {
            if (responseObject && [ responseObject isKindOfClass:[NSDictionary class]]) {
                NSArray* results = [responseObject objectForKey:@"result"];
                for (NSDictionary *dic in results) {
                    VEDramaVideoInfoModel *dramaVideoInfoModel = [[VEDramaVideoInfoModel alloc] initWithDictionary:dic error:nil];
                    [dramas addObject:dramaVideoInfoModel];
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

@end
