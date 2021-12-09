//
//  NSTimer+VE.m
//  VOLCDemo
//
//  Created by wangzhiyong on 2021/11/8.
//  Copyright © 2021 ByteDance. All rights reserved.
//

#import "NSTimer+VE.h"

@interface VETimerTarget : NSObject

@property (nonatomic, weak) id wTarget;

@end

@implementation VETimerTarget

- (instancetype)initWithTarget:(id)target {
    self = [super init];
    if (self) {
        self.wTarget = target;
    }
    return self;
}

- (id)forwardingTargetForSelector:(SEL)aSelector {
    return self.wTarget;
}

@end

@implementation NSTimer (VE)

+ (instancetype)ve_scheduledTimerWithTimeInterval:(NSTimeInterval)inTimeInterval
                                            queue:(dispatch_queue_t)queue
                                            block:(void (^)(void))inBlock
                                          repeats:(BOOL)inRepeats {
    void (^block)(void) = ^() {
        dispatch_queue_t taskQueue = queue;
        if (!taskQueue) {
            taskQueue = dispatch_get_main_queue();
        }
        dispatch_async(taskQueue, ^{
            if (inBlock) {
                inBlock();
            }
        });
    };
    id ret = [self scheduledTimerWithTimeInterval:inTimeInterval target:self selector:@selector(excuteBlock:) userInfo:block repeats:inRepeats];
    [[NSRunLoop currentRunLoop] addTimer:ret forMode:NSRunLoopCommonModes];
    return ret;
}

+ (void)excuteBlock:(NSTimer *)inTimer {
    if([inTimer userInfo]) {
        void (^block)(void) = (void (^)(void))[inTimer userInfo];
        block();
    }
}

+ (NSTimer *)ve_scheduledNoRetainTimerWithTimeInterval:(NSTimeInterval)ti
                                                target:(id)aTarget
                                              selector:(SEL)aSelector
                                              userInfo:(id)userInfo
                                               repeats:(BOOL)yesOrNo {
    VETimerTarget * timerTarget = [[VETimerTarget alloc] initWithTarget:aTarget];
    return [self scheduledTimerWithTimeInterval:ti target:timerTarget selector:aSelector userInfo:userInfo repeats:yesOrNo];
}
@end
