//
//  BTDMacros.h
//  Pods
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <pthread/pthread.h>

#ifndef __BTDMacros_H__
#define __BTDMacros_H__

#ifndef BTDAssertMainThread
#define BTDAssertMainThread() NSAssert([NSThread isMainThread], @"This method must be called on the main thread")
#endif

#ifndef weakify
    #if DEBUG
        #if __has_feature(objc_arc)
        #define weakify(object) \
            _Pragma("clang diagnostic push") \
            _Pragma("clang diagnostic ignored \"-Wshadow\"") \
            autoreleasepool{} __weak __unused __typeof__(object) weak##_##object = object; \
            _Pragma("clang diagnostic pop")
        #else
        #define weakify(object) \
            _Pragma("clang diagnostic push") \
            _Pragma("clang diagnostic ignored \"-Wshadow\"") \
            autoreleasepool{} __block __unused __typeof__(object) block##_##object = object; \
            _Pragma("clang diagnostic pop")
        #endif
    #else
        #if __has_feature(objc_arc)
        #define weakify(object) \
            _Pragma("clang diagnostic push") \
            _Pragma("clang diagnostic ignored \"-Wshadow\"") \
            try{} @finally{} {} __weak __unused __typeof__(object) weak##_##object = object; \
            _Pragma("clang diagnostic pop")
        #else
        #define weakify(object) \
            _Pragma("clang diagnostic push") \
            _Pragma("clang diagnostic ignored \"-Wshadow\"") \
            try{} @finally{} {} __block __unused __typeof__(object) block##_##object = object; \
            _Pragma("clang diagnostic pop")
        #endif
    #endif
#endif

#ifndef strongify
    #if DEBUG
        #if __has_feature(objc_arc)
        #define strongify(object) \
            _Pragma("clang diagnostic push") \
            _Pragma("clang diagnostic ignored \"-Wshadow\"") \
            autoreleasepool{} __unused __typeof__(object) object = weak##_##object; \
            _Pragma("clang diagnostic pop")
        #else
        #define strongify(object) \
            _Pragma("clang diagnostic push") \
            _Pragma("clang diagnostic ignored \"-Wshadow\"") \
            autoreleasepool{} __unused __typeof__(object) object = block##_##object; \
            _Pragma("clang diagnostic pop")
        #endif
    #else
        #if __has_feature(objc_arc)
        #define strongify(object) \
            _Pragma("clang diagnostic push") \
            _Pragma("clang diagnostic ignored \"-Wshadow\"") \
            try{} @finally{} __unused __typeof__(object) object = weak##_##object; \
            _Pragma("clang diagnostic pop")
        #else
        #define strongify(object) \
            _Pragma("clang diagnostic push") \
            _Pragma("clang diagnostic ignored \"-Wshadow\"") \
            try{} @finally{} __unused __typeof__(object) object = block##_##object; \
            _Pragma("clang diagnostic pop")
        #endif
    #endif
#endif

#ifndef btd_keywordify
#if DEBUG
    #define btd_keywordify autoreleasepool {}
#else
    #define btd_keywordify try {} @catch (...) {}
#endif
#endif

FOUNDATION_EXPORT void btd_dispatch_async_on_main_queue(void (^block)(void));
FOUNDATION_EXPORT void btd_dispatch_sync_on_main_queue(void (^block)(void));

#ifndef onExit
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wunused-function"
static void blockCleanUp(__strong void(^*block)(void))
{
    (*block)();
}
#pragma clang diagnostic pop

#define onExit \
        btd_keywordify __strong void(^__on_exit_block)(void) __attribute__((cleanup(blockCleanUp), unused)) = ^
#endif

#ifndef BTD_MUTEX_LOCK
#define BTD_MUTEX_LOCK(lock) \
    pthread_mutex_lock(&(lock)); \
    @onExit{ \
        pthread_mutex_unlock(&(lock)); \
    };
#endif

#ifndef BTD_SEMAPHORE_LOCK
#define BTD_SEMAPHORE_LOCK(lock) \
    dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER); \
    @onExit{ \
        dispatch_semaphore_signal(lock); \
    };
#endif

#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wunused-function"
static NSString *currentTimeString(void)
{
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSSSSS"];
    return [dateFormatter stringFromDate:[NSDate date]];
}
#pragma clang diagnostic pop

#ifndef BTDLog
#if DEBUG
    #define BTDLog(s, ...) \
    fprintf(stderr, "%s <%s:%d> %s\n", [currentTimeString() UTF8String], [[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String], __LINE__, [[NSString stringWithFormat:(s), ##__VA_ARGS__] UTF8String])
#else
    #define BTDLog(s, ...)
#endif
#endif

#ifndef BTD_isEmptyString
FOUNDATION_EXPORT BOOL BTD_isEmptyString(id param);
#endif

#ifndef BTD_isEmptyArray
FOUNDATION_EXPORT BOOL BTD_isEmptyArray(id param);
#endif

#ifndef BTD_isEmptyDictionary
FOUNDATION_EXPORT BOOL BTD_isEmptyDictionary(id param);
#endif

#ifndef BTD_isEmptySet
FOUNDATION_EXPORT BOOL BTD_isEmptySet(id param);
#endif

#ifndef BTD_DYNAMIC_CAST
#define BTD_DYNAMIC_CAST(TYPE, OBJECT)  ({ id __obj__ = OBJECT;[__obj__ isKindOfClass:[TYPE class]] ? (TYPE *) __obj__: nil; })
#endif

#ifndef BTD_BLOCK_INVOKE
#define BTD_BLOCK_INVOKE(block, ...) ({block ? block(__VA_ARGS__) : 0;})
#endif

#endif
