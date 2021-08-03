//
//  VOLCPreloadHelper.m
//  VOLCDemo
//
//  Created by wangzhiyong on 2021/6/1.
//  Copyright © 2021 ByteDance. All rights reserved.
//

#import "VOLCPreloadHelper.h"
#import <TTSDK/TTVideoEngine+Preload.h>
#import "VOLCUserGlobalConfiguration.h"
#import "VOLCVideoModel.h"

NSInteger const kDefaultVideoPreloadSize = 500 * 1024; // video preload size (500K)

@interface VOLCPreloadHelper ()

@end

@implementation VOLCPreloadHelper

+ (VOLCPreloadHelper *)shareInstance {
    static dispatch_once_t onceToken;
    static VOLCPreloadHelper *preloadHelper = nil;
    dispatch_once(&onceToken, ^{
        if (preloadHelper == nil) {
            preloadHelper = [[VOLCPreloadHelper alloc] init];
        }
    });
    return preloadHelper;
}


#pragma mark - Public

- (void)addPreloadTaskWithVideoModels:(NSArray<VOLCVideoModel *> *)videoModels {
    VOLCUserGlobalConfiguration *setting = [VOLCUserGlobalConfiguration sharedInstance];
    if (setting.isMDLPreloadOn) {
        for (VOLCVideoModel *videoModel in videoModels) {
            [self _preloadVideo:videoModel.videoId playAuthToken:videoModel.playAuthToken];
        }
    } else {
        NSLog(@"preload fail. mdl preload closed. ");
    }
}

- (void)addPreloadTaskWithVideoModel:(VOLCVideoModel *)videoModel {
    if (videoModel) {
        [self addPreloadTaskWithVideoModels:@[videoModel]];
    }
}

- (void)cancelAllPreloadTask {
    [TTVideoEngine ls_cancelAllTasks];
}

- (void)cleanAllCacheData {
    [TTVideoEngine ls_clearAllCaches];
}


#pragma mark - Private

- (void)_preloadVideo:(NSString *)vid playAuthToken:(NSString *)playAuthToken {
    VOLCUserGlobalConfiguration *globalConfig = [VOLCUserGlobalConfiguration sharedInstance];
    TTVideoEnginePreloaderVidItem *item = [TTVideoEnginePreloaderVidItem preloaderVidItem:vid
                                                                                    token:playAuthToken
                                                                                reslution:TTVideoEngineResolutionTypeHD
                                                                              preloadSize:kDefaultVideoPreloadSize
                                                                                   ish265:globalConfig.isH265Enabled
                                                                               encryption:NO
                                                                                hlsEnable:NO];
    item.preloadEnd = ^(TTVideoEngineLocalServerTaskInfo * _Nullable info, NSError * _Nullable error) {
        if (error) {
            NSLog(@"preload error, vid: %@, error %@", info.videoId, error);
        } else {
            NSLog(@"preload finished, vid: %@, total size %lld, preload size %lld", info.videoId, info.mediaSize, info.preloadSize);
        }
    };
    
    [TTVideoEngine ls_addTaskWithVidItem:item];
}

@end
