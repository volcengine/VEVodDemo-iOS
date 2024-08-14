//
//  VEPlayerExceptionLoggerDefine.h
//  VEPlayerKit
//

#ifndef VEPlayerExceptionLoggerDefine_h
#define VEPlayerExceptionLoggerDefine_h
#import "VEPlayerExceptionLogger.h"

#define VEPlayerAssertMainThreadException() \
        NSAssert([NSThread isMainThread], @"This method must be called on the main thread");\
        if(![NSThread isMainThread]) { \
            [VEPlayerExceptionLogger trackThreadExceptionLog:NSStringFromClass(self.class) currentParams:nil]; \
        } \

static inline void VEPlayerThreadExceptionTrack(NSString * _Nullable exceptionType, NSDictionary<NSString *, id> *_Nullable currentParams) {
    [VEPlayerExceptionLogger trackThreadExceptionLog:exceptionType currentParams:currentParams];
}

#endif /* VEPlayerExceptionLoggerDefine_h */
