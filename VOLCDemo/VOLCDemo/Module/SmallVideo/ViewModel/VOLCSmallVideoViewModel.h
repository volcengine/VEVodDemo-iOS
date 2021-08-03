//
//  VOLCSmallVideoViewModel.h
//  VOLCDemo
//
//  Created by wangzhiyong on 2021/5/24.
//  Copyright © 2021 ByteDance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VOLCNetworkHelper.h"

NS_ASSUME_NONNULL_BEGIN

@class VOLCVideoModel;

typedef NS_ENUM(NSInteger, VOLCSmallVideoPlayState) {
    VOLCSmallVideoPlayStatePlay = 0,
    VOLCSmallVideoPlayStateStop = 1,
    VOLCSmallVideoPlayStatePause = 2,
};

@interface VOLCSmallVideoViewModel : NSObject

@property (nonatomic, readonly, strong) NSMutableArray<VOLCVideoModel *> *videoModels;

- (void)requestVideoModels:(HttpSuccessResponseBlock)success
                   failure:(HttpFailureResponseBlock)failure;

- (VOLCVideoModel *)cellVideoModelForRowAtIndexPath:(NSIndexPath *)indexPath;

- (NSInteger)numberOfRowsInSection:(NSInteger)section;

@end

NS_ASSUME_NONNULL_END
