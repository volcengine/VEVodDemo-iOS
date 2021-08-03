//
//  VOLCSmallVideoViewModel.m
//  VOLCDemo
//
//  Created by wangzhiyong on 2021/5/24.
//  Copyright © 2021 ByteDance. All rights reserved.
//

#import "VOLCSmallVideoViewModel.h"
#import "VOLCVideoModel.h"

NSString * const VOLCSmallVideoRequestVideoModels = @"http://vod-app-server.snssdk.com/api/general/v1/getFeedStreamWithPlayAuthToken";

@interface VOLCSmallVideoViewModel ()

@property (nonatomic, readwrite, strong) NSMutableArray<VOLCVideoModel *> *videoModels;

@end

@implementation VOLCSmallVideoViewModel

- (void)requestVideoModels:(HttpSuccessResponseBlock)success
                   failure:(HttpFailureResponseBlock)failure {
    NSDictionary *paramDic = @{ @"userID" : @"small-video" };
    [VOLCNetworkHelper requestDataWithUrl:VOLCSmallVideoRequestVideoModels httpMethod:@"POST" parameters:paramDic success:^(id  _Nonnull responseObject) {
        [self.videoModels removeAllObjects];
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *responseDictionary = responseObject;
            NSArray *retVideoList = [responseDictionary objectForKey:@"result"];
            NSInteger i = 0;
            for (NSDictionary *itemDictionary in retVideoList) {
                VOLCVideoModel *videoModel = [[VOLCVideoModel alloc] initWithJsonDictionary:itemDictionary];
                videoModel.extendIndex = i;
                [self.videoModels addObject:videoModel];
                i++;
            }
            if (success) {
                success(self.videoModels);
            }
        }
    } failure:^(NSString * _Nonnull errorMessage) {
        if (failure) {
            failure(errorMessage);
        }
    }];
}

- (VOLCVideoModel *)cellVideoModelForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self.videoModels objectAtIndex:indexPath.row];
}

- (NSInteger)numberOfRowsInSection:(NSInteger)section {
    return [self.videoModels count];
}


#pragma mark - lazy load

- (NSMutableArray *)videoModels {
    if (!_videoModels) {
        _videoModels = [NSMutableArray array];
    }
    return _videoModels;
}

@end
