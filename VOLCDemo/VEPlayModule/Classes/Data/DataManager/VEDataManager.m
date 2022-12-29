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

static NSString *longVideoZone = @"long-video";

static NSString *feedVideoZone = @"feedvideo";

static NSString *shortVideoZone = @"short-video";

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
        NSString *urlString = @"https://vevod-demo-server.volcvod.com/api/general/v1/getFeedStreamWithPlayAuthToken";
        [VENetworkHelper requestDataWithUrl:urlString httpMethod:@"POST" parameters:param success:^(id _Nonnull responseObject) {
            if (responseObject && [responseObject isKindOfClass:[NSDictionary class]]) {
                NSArray* results = [responseObject objectForKey:@"result"];
                for (NSDictionary *dic in results) {
                    VEVideoModel *videoModel = [[VEVideoModel alloc] initWithDictionary:dic error:nil];
                    [medias addObject:videoModel];
                }
            }
            if (result) result(medias);
        } failure:^(NSString * _Nonnull errorMessage) {
            
        }];
    });
}

@end

