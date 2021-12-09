//
//  VEUtils.h
//  VOLCDemo
//
//  Created by wangzhiyong on 2021/11/8.
//  Copyright © 2021 ByteDance. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#if defined(__cplusplus)
#define VOLC_EXTERN extern "C" __attribute__((visibility("default")))
#else
#define VOLC_EXTERN extern __attribute__((visibility("default")))
#endif

VOLC_EXTERN BOOL VEIsMainQueue(void);

VOLC_EXTERN void VERunOnMainQueue(dispatch_block_t block, BOOL sync);

@interface VEUtils : NSObject

@end

NS_ASSUME_NONNULL_END
