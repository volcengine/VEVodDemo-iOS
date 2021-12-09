//
//  NSTimer+VE.h
//  VOLCDemo
//
//  Created by wangzhiyong on 2021/11/8.
//  Copyright © 2021 ByteDance. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSTimer (VE)

+ (instancetype)ve_scheduledTimerWithTimeInterval:(NSTimeInterval)inTimeInterval
                                            queue:(dispatch_queue_t)queue
                                            block:(void (^)(void))inBlock
                                          repeats:(BOOL)inRepeats;

+ (NSTimer *)ve_scheduledNoRetainTimerWithTimeInterval:(NSTimeInterval)ti
                                                target:(id)aTarget
                                              selector:(SEL)aSelector
                                              userInfo:(id)userInfo
                                               repeats:(BOOL)yesOrNo;

@end

NS_ASSUME_NONNULL_END
