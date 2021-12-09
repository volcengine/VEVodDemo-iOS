//
//  VEUtils.m
//  VOLCDemo
//
//  Created by wangzhiyong on 2021/11/8.
//  Copyright © 2021 ByteDance. All rights reserved.
//

#import "VEUtils.h"

BOOL VEIsMainQueue() {
    static const void* mainQueueKey = &mainQueueKey;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dispatch_queue_set_specific(dispatch_get_main_queue(), mainQueueKey, (void *)mainQueueKey, nil);
    });
    return dispatch_get_specific(mainQueueKey) == mainQueueKey;
}

void VERunOnMainQueue(dispatch_block_t block, BOOL sync) {
    if ([NSThread isMainThread]) {
        block();
    }
    else {
        if (sync) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                block();
            });
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                block();
            });
        }
    }
}

@implementation VEUtils

@end
