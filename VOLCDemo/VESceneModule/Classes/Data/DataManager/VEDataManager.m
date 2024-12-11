//
//  VEDataManager.m
//  VOLCDemo
//
//  Created by real on 2022/8/22.
//  Copyright © 2022 ByteDance. All rights reserved.
//

#import "VEDataManager.h"
#import "VENetworkHelper.h"
#import "VEVideoModel.h"
#import "VESettingManager.h"

static NSString *longVideoZone = @"long-video";

static NSString *feedVideoZone = @"feedvideo";

static NSString *shortVideoZone = @"short-video";

static NSString *requestVidSourceUrl = @"https://vevod-demo-server.volcvod.com/api/general/v1/getFeedStreamWithPlayAuthToken";
static NSString *requestUrlSouceUrl = @"https://vevod-demo-server.volcvod.com/api/general/v1/getFeedStreamWithVideoModel";

@implementation VEDataManager

+ (void)dataForScene:(VESceneType)type range:(NSRange)range result:(void(^)(NSArray<VEVideoModel *> *))result  onError:(void(^)(NSString* errorMessage))onError {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray *medias = [NSMutableArray array];
        NSString *key;
        switch (type) {
            case VESceneTypeShortVideo: key = shortVideoZone; break;
            case VESceneTypeFeedVideo:  key = feedVideoZone; break;
            case VESceneTypeLongVideo:  key = longVideoZone; break;
        }
        NSDictionary *param;
        if (range.length) {
            param = @{@"userID" : key, @"offset" : @(range.location), @"pageSize" : @(range.length)};
        } else {
            param = @{@"userID" : key};
        }
        
        NSString *urlString = requestVidSourceUrl;
        if ([VEDataManager getRequestSourceType] == VERequestPlaySourceType_Vid) {
            urlString = requestVidSourceUrl;
        } else if ([VEDataManager getRequestSourceType] == VERequestPlaySourceType_Url) {
            urlString = requestUrlSouceUrl;
        }
        [VENetworkHelper requestDataWithUrl:urlString httpMethod:@"POST" parameters:param success:^(id _Nonnull responseObject) {
            if (responseObject && [responseObject isKindOfClass:[NSDictionary class]]) {
                NSArray* results = [responseObject objectForKey:@"result"];
                for (NSDictionary *dic in results) {
                    if ([VEDataManager getRequestSourceType] == VERequestPlaySourceType_Vid) {
                        VEVideoModel *videoModel = [[VEVideoModel alloc] initWithDictionary:dic error:nil];
                        [medias addObject:videoModel];
                    } else if ([VEDataManager getRequestSourceType] == VERequestPlaySourceType_Url) {
                        NSDictionary *tempDic = [self dictionaryFromJsonString:[dic objectForKey:@"videoModel"]];
                        VEVideoEngineInfoModel *videoEngineInfoModel = [[VEVideoEngineInfoModel alloc] initWithDictionary:tempDic error:nil];
                        VEVideoModel *videoModel = [[VEVideoModel alloc] initWithDictionary:dic error:nil];
                        videoModel.videoEngineInfoModel = videoEngineInfoModel;
                        [medias addObject:videoModel];
                    }
                }
            }
            if (result) {
                result(medias);
            }
        } failure:^(NSString * _Nonnull errorMessage) {
            if (onError) {
                onError(errorMessage);
            }
        }];
    });
}

+ (void)dataForScene:(VESceneType)type range:(NSRange)range result:(void(^)(NSArray<VEVideoModel *> *))result {
    [VEDataManager dataForScene:type range:range result:result onError:nil];
}

+ (VERequestPlaySourceType)getRequestSourceType {
    VESettingModel *model = [[VESettingManager universalManager] settingForKey:VESettingKeyUniversalPlaySourceType];
    return (VERequestPlaySourceType)[model.currentValue integerValue];
}

+ (NSDictionary *)dictionaryFromJsonString:(NSString *)jsonString {
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

