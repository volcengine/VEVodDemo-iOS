//
//  VOLCPreloadHelper.h
//  VOLCDemo
//
//  Created by wangzhiyong on 2021/6/1.
//  Copyright © 2021 ByteDance. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VOLCVideoModel;

NS_ASSUME_NONNULL_BEGIN

@interface VOLCPreloadHelper : NSObject

+ (VOLCPreloadHelper *)shareInstance;

/**
 add preload tasks.

 @param videoModels video models
 */
- (void)addPreloadTaskWithVideoModels:(NSArray<VOLCVideoModel *> *)videoModels;

/**
 add signle preload tasks.

 @param videoModel video model
 */
- (void)addPreloadTaskWithVideoModel:(VOLCVideoModel *)videoModel;

/**
 cancel all preload task
 */
- (void)cancelAllPreloadTask;

/**
 clean all cache data
 */
- (void)cleanAllCacheData;

@end

NS_ASSUME_NONNULL_END
