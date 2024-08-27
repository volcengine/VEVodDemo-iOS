//
//  NSTimer+BTDAdditions.h
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSTimer (BTDAdditions)

#pragma mark - Block Timer

+ (NSTimer *)btd_scheduledTimerWithTimeInterval:(NSTimeInterval)interval repeats:(BOOL)repeats block:(void (^)(NSTimer * _Nonnull timer))block;

+ (NSTimer *)btd_timerWithTimeInterval:(NSTimeInterval)interval repeats:(BOOL)repeats block:(void (^)(NSTimer * _Nonnull timer))block;

#pragma mark - Not Retain Target Timer

+ (NSTimer *)btd_scheduledTimerWithTimeInterval:(NSTimeInterval)interval weakTarget:(id)weakTarget selector:(SEL)aSelector userInfo:(nullable id)userInfo repeats:(BOOL)yesOrNo;

+ (NSTimer *)btd_timerWithTimeInterval:(NSTimeInterval)interval weakTarget:(id)weakTarget selector:(SEL)aSelector userInfo:(nullable id)userInfo repeats:(BOOL)yesOrNo;

- (void)btd_pause;

- (void)btd_resume;

@end

NS_ASSUME_NONNULL_END
