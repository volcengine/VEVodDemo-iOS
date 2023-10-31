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
#import <YYKit/NSString+YYAdd.h>
#import "VESettingManager.h"

static NSString *longVideoZone = @"long-video";

static NSString *feedVideoZone = @"feedvideo";

static NSString *shortVideoZone = @"short-video";

static NSString *requestVidSourceUrl = @"https://vevod-demo-server.volcvod.com/api/general/v1/getFeedStreamWithPlayAuthToken";
static NSString *requestUrlSouceUrl = @"https://vevod-demo-server.volcvod.com/api/general/v1/getFeedStreamWithVideoModel";

@implementation VEDataManager

+ (void)dataForScene:(VESceneType)type range:(NSRange)range result:(void(^)(NSArray<VEVideoModel *> *))result  {
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
                        NSDictionary *tempDic = [[dic objectForKey:@"videoModel"] jsonValueDecoded];
                        VEVideoEngineInfoModel *videoEngineInfoModel = [[VEVideoEngineInfoModel alloc] initWithDictionary:tempDic error:nil];
                        VEVideoModel *videoModel = [[VEVideoModel alloc] initWithDictionary:dic error:nil];
                        videoModel.videoEngineInfoModel = videoEngineInfoModel;
                        [medias addObject:videoModel];
                    }
                }
            }
            if (result) result(medias);
        } failure:^(NSString * _Nonnull errorMessage) {
            
        }];
    });
}

+ (VERequestPlaySourceType)getRequestSourceType {
    VESettingModel *vidSource = [[VESettingManager universalManager] settingForKey:VESettingKeyPlaySourceTypeVid];
    VESettingModel *urlSource = [[VESettingManager universalManager] settingForKey:VESettingKeyPlaySourceTypeUrl];
    if (vidSource.open) {
        return VERequestPlaySourceType_Vid;
    } else if (urlSource.open) {
        return VERequestPlaySourceType_Url;
    }
    return VERequestPlaySourceType_Vid;
}

@end

