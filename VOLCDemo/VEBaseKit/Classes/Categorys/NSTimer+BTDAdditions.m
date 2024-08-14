//
//  NSTimer+BTDAdditions.m
//

#import "NSTimer+BTDAdditions.h"
#import "BTDWeakProxy.h"
#import <objc/runtime.h>

@interface NSTimer ()

@property (nonatomic, strong) NSDate *btd_pausedDate;

@property (nonatomic, strong) NSDate *btd_nextFireDate;

@end

@implementation NSTimer (BTDAdditions)

+ (void)btd_execBlock:(NSTimer *)timer
{    
    if (!timer || ![timer isValid]) {
        return;
    }
    CFRunLoopTimerContext context;
    CFRunLoopTimerGetContext((CFRunLoopTimerRef)timer, &context);
    if (!context.info) {
        return;
    }
    if ([timer userInfo]) {
        void (^block)(NSTimer *timer) = (void (^)(NSTimer *timer))[timer userInfo];
        if (block) {
            block(timer);
        }
    }
}

+ (NSTimer *)btd_scheduledTimerWithTimeInterval:(NSTimeInterval)interval repeats:(BOOL)repeats block:(void (^)(NSTimer * _Nonnull timer))block {
    return [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(btd_execBlock:) userInfo:[block copy] repeats:repeats];
}

+ (NSTimer *)btd_timerWithTimeInterval:(NSTimeInterval)interval repeats:(BOOL)repeats block:(void (^)(NSTimer * _Nonnull timer))block {
    return [NSTimer timerWithTimeInterval:interval target:self selector:@selector(btd_execBlock:) userInfo:[block copy] repeats:repeats];
}

+ (NSTimer *)btd_scheduledTimerWithTimeInterval:(NSTimeInterval)interval weakTarget:(id)weakTarget selector:(SEL)aSelector userInfo:(id)userInfo repeats:(BOOL)yesOrNo {
    return [self scheduledTimerWithTimeInterval:interval target:[BTDWeakProxy proxyWithTarget:weakTarget] selector:aSelector userInfo:userInfo repeats:yesOrNo];
}

+ (NSTimer *)btd_timerWithTimeInterval:(NSTimeInterval)interval weakTarget:(id)weakTarget selector:(SEL)aSelector userInfo:(id)userInfo repeats:(BOOL)yesOrNo {
    return [self timerWithTimeInterval:interval target:[BTDWeakProxy proxyWithTarget:weakTarget] selector:aSelector userInfo:userInfo repeats:yesOrNo];
}

- (void)btd_pause {
    if (self.btd_pausedDate || self.btd_nextFireDate) {
        return;
    }
    
    self.btd_pausedDate = [NSDate date];
    self.btd_nextFireDate = [self fireDate];
    
    [self setFireDate:[NSDate distantFuture]];
}

- (void)btd_resume {
    if (!self.btd_pausedDate || !self.btd_nextFireDate) {
        return;
    }
    
    float pauseTime = -1 * [self.btd_pausedDate timeIntervalSinceNow];
    [self setFireDate:[self.btd_nextFireDate initWithTimeInterval:pauseTime sinceDate:self.btd_nextFireDate]];
    
    self.btd_pausedDate = nil;
    self.btd_nextFireDate = nil;
}

- (NSDate *)btd_pausedDate {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setBtd_pausedDate:(NSDate *)btd_pausedDate {
    objc_setAssociatedObject(self, @selector(btd_pausedDate), btd_pausedDate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSDate *)btd_nextFireDate {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setBtd_nextFireDate:(NSDate *)btd_nextFireDate {
    objc_setAssociatedObject(self, @selector(btd_nextFireDate), btd_nextFireDate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
@end
