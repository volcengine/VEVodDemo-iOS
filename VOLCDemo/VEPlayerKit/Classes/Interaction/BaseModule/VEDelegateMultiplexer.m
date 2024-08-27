//
//  VEDelegateMultiplexer.m
//  VEPlayerKit
//

#import <objc/runtime.h>

#import "VEDelegateMultiplexer.h"
#import "NSPointerArray+AbstractionHelpers.h"
static void __VEDelegateMultiplexer_IS_CALLING_OUT_TO_A_DELEGATE__(NSInvocation *invocation, id target) {
    [invocation invokeWithTarget:target];
}

@implementation VEDelegateMultiplexer {
    NSHashTable *_delegates; 
    Protocol *_protocol;
    NSMapTable *_methodSignatureCache;
}

- (instancetype)init {
    NSAssert(NO, @"Calling init directly is not allowed.");
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
    return [self initWithProtocol:nil];
#pragma clang diagnostic pop
}

- (instancetype)initWithProtocol:(Protocol *)protocol {
    self = [super init];
    if (self) {
        _delegates = [NSHashTable weakObjectsHashTable];
        _protocol = protocol;
        _methodSignatureCache =
            [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsOpaqueMemory | NSPointerFunctionsOpaquePersonality
                                  valueOptions:NSPointerFunctionsStrongMemory];
    }
    return self;
}

- (void)addDelegate:(id)delegate {
    [_delegates addObject:delegate];
}

- (void)removeDelegate:(id)delegate {
    [_delegates removeObject:delegate];
}

- (void)removeAllDelegates {
    [_delegates removeAllObjects];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    void *key = (void *) aSelector;
    NSMethodSignature *methodSignature = [_methodSignatureCache objectForKey:(__bridge id) key];
    
    if (!methodSignature) {
        struct objc_method_description desc = protocol_getMethodDescription(_protocol, aSelector, NO, YES);
        if (!desc.types) {
            desc = protocol_getMethodDescription(_protocol, aSelector, YES, YES);
        }
        
        if (!desc.types) {
            return nil;
        }
        
        methodSignature = [NSMethodSignature signatureWithObjCTypes:desc.types];
        [_methodSignatureCache setObject:methodSignature forKey:(__bridge id) key];
    }
    
    return methodSignature;
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    SEL sel = anInvocation.selector;
    
    NSArray *delegates = _delegates.allObjects.copy;
    for (id delegate in delegates) {
        if ([delegate respondsToSelector:sel]) {
            __VEDelegateMultiplexer_IS_CALLING_OUT_TO_A_DELEGATE__(anInvocation, delegate);
        }
    }
}

- (void)doesNotRecognizeSelector:(SEL)aSelector {
    NSAssert(NO, @"Unknown selector: %@", NSStringFromSelector(aSelector));
}

@end
