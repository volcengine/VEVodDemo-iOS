//
//  VEPlayerContextMacros.h
//  VEPlayerKit
//

#ifndef VEPlayerContextMacros_h
#define VEPlayerContextMacros_h

typedef void(^VEPlayerContextHandler)(id _Nullable object, NSString * _Nullable key);

typedef id _Nullable (^VEPlayerContextObjectCreator)(void);

static inline void VEPlayerContextRunOnMainThread(void (^ _Nullable block)(void)) {
    if ([NSThread isMainThread]) {
        block();
    } else {
        dispatch_async(dispatch_get_main_queue(), block);
    }
}

#endif /* VEPlayerContextMacros_h */
