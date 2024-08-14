//
//  VEPlayerContext.m
//  VEPlayerKit
//

#import "VEPlayerContext.h"
#import "VEPlayerContextItem.h"
#import "VEPlayerContextStorage.h"
#import "VEPlayerContextDI.h"
#import "BTDMacros.h"
#import "VEPlayerContextItemHandler.h"
#import <pthread/pthread.h>
#import "VEPlayerExceptionLoggerDefine.h"


id VEPlayerObserveKeyFunction(VEPlayerContext *context, NSString *key, NSObject *observer, VEPlayerContextHandler handler) {
    NSCAssert(nil != context && nil != observer, @"context or observer is nil");
    return [context addKey:key withObserver:observer handler:handler];
}

id VEPlayerObserveKeysFunction(VEPlayerContext *context, NSArray<NSString *> *keys, NSObject *observer, VEPlayerContextHandler handler) {
    NSCAssert(nil != context && nil != observer, @"context or observer is nil");
    return [context addKeys:keys withObserver:observer handler:handler];
}

@interface VEPlayerContext ()

@property (nonatomic, strong) VEPlayerContextStorage *storage;
@property (nonatomic, strong) VEPlayerContextDI *di;
@property (nonatomic, strong) NSMapTable *observerMap;

@end

@implementation VEPlayerContext {
    pthread_mutex_t _mutexLock;
}

#pragma mark - Life Cycle

- (instancetype)init {
    if (self = [super init]) {
        pthread_mutex_init(&_mutexLock, NULL);
    }
    return self;
}

- (void)dealloc {
    pthread_mutex_destroy(&_mutexLock);
}

- (BOOL)enableStorageCache {
    return self.storage.enableCache;
}

- (void)setEnableStorageCache:(BOOL)enableStorageCache {
    self.storage.enableCache = enableStorageCache;
}

#pragma mark - Setter & Getter Method
- (VEPlayerContextStorage *)storage {
    if (!_storage) {
        _storage = [[VEPlayerContextStorage alloc] init];
    }
    return _storage;
}

- (VEPlayerContextDI *)di {
    if (!_di) {
        _di = [[VEPlayerContextDI alloc] init];
    }
    return _di;
}

- (NSMapTable *)observerMap {
    if (!_observerMap) {
        _observerMap = [NSMapTable weakToStrongObjectsMapTable];
    }
    return _observerMap;
}

@end

@implementation VEPlayerContext (Handler)

- (nullable id)addKey:(nonnull NSString *)key withObserver:(id)observer handler:(nullable VEPlayerContextHandler)handler {
    NSAssert(!BTD_isEmptyString(key), @"key is nil");
    if (BTD_isEmptyString(key)) {
        return nil;
    }
    VEPlayerAssertMainThreadException();
    if ([NSThread isMainThread]) {
        VEPlayerContextItemHandler *itemHandler = [[VEPlayerContextItemHandler alloc] initWithObserver:observer keys:@[key] handler:handler];
        VEPlayerContextItem *item = [self.storage contextItemForKey:key];
        [item addHandler:itemHandler];
        [self recordObserver:observer withHandler:itemHandler];
        return itemHandler;
    } else {
        return nil;
    }
}

- (nullable id)addKeys:(nonnull NSArray<NSString *> *)keys withObserver:(id)observer handler:(nullable VEPlayerContextHandler)handler {
    NSAssert(!BTD_isEmptyArray(keys), @"keys is nil");
    if (BTD_isEmptyArray(keys)) {
        return nil;
    }
    VEPlayerAssertMainThreadException();
    if ([NSThread isMainThread]) {
        VEPlayerContextItemHandler *itemHandler = [[VEPlayerContextItemHandler alloc] initWithObserver:observer keys:keys handler:handler];
        for (NSString *key in keys) {
            NSAssert(!BTD_isEmptyString(key), @"key is nil");
            if (!BTD_isEmptyString(key)) {
                VEPlayerContextItem *item = [self.storage contextItemForKey:key];
                [item addHandler:itemHandler];
            }
        }
        [self recordObserver:observer withHandler:itemHandler];
        return itemHandler;
    } else {
        return nil;
    }
}

- (void)removeHandler:(id)handler {
    VEPlayerAssertMainThreadException();
    if (!handler || ![handler isKindOfClass:VEPlayerContextItemHandler.class]) {
        return;
    }
    VEPlayerContextRunOnMainThread(^{
        VEPlayerContextItemHandler *itemHandler = (VEPlayerContextItemHandler *)handler;
        [itemHandler.keys enumerateObjectsUsingBlock:^(NSString  * _Nonnull key, NSUInteger idx, BOOL * _Nonnull stop) {
            VEPlayerContextItem *contextItem = [self.storage contextItemForKey:key];
            [contextItem removeHandler:itemHandler];
        }];
    });
}

- (void)removeHandlersForObserver:(id)observer {
    VEPlayerAssertMainThreadException();
    if (observer) {
        BTD_MUTEX_LOCK(self->_mutexLock);
        NSPointerArray *pointerArray = [_observerMap objectForKey:observer];
        [pointerArray.allObjects enumerateObjectsUsingBlock:^(id  _Nonnull handler, NSUInteger idx, BOOL * _Nonnull stop) {
            [self removeHandler:handler];
        }];
        [_observerMap removeObjectForKey:observer];
    }
}

- (void)removeAllHandler {
    VEPlayerAssertMainThreadException();
    VEPlayerContextRunOnMainThread(^{
        [self.storage removeAllObject];
        BTD_MUTEX_LOCK(self->_mutexLock);
        [self.observerMap removeAllObjects];
    });
}

- (void)post:(id)object forKey:(NSString *)key {
    if (BTD_isEmptyString(key)) {
        return;
    }
    VEPlayerAssertMainThreadException();
    VEPlayerContextRunOnMainThread(^{
        [self.storage setObject:object forKey:key];
    });
}

- (void)recordObserver:(id)observer withHandler:(VEPlayerContextItemHandler *)handler {
    //允许observe为空，不为空，则把observer和handler建立映射
    if (observer) {
        BTD_MUTEX_LOCK(self->_mutexLock);
        NSPointerArray *handlerArray = [self.observerMap objectForKey:observer];
        if (!handlerArray) {
            handlerArray = [NSPointerArray weakObjectsPointerArray];
            [self.observerMap setObject:handlerArray forKey:observer];
        }
        [handlerArray compact];
        [handlerArray addPointer:(__bridge void * _Nullable)(handler)];
    }
}

@end

@implementation VEPlayerContext (HandlerAdditions)

- (id)objectForHandlerKey:(NSString *)key {
    if (BTD_isEmptyString(key)) {
        return nil;
    }
    VEPlayerAssertMainThreadException();
    if ([NSThread isMainThread]) {
        return [self.storage objectForKey:key];
    } else {
        return nil;
    }
}

- (NSString *)stringForHandlerKey:(nonnull NSString *)key {
    id obj = [self objectForHandlerKey:key];
    if (obj && ![obj isKindOfClass:NSString.class]) {
        NSAssert(NO, @"VEPlayer Context Handler obj is not NSString");
        return nil;
    } else {
        return obj;
    }
}

- (NSDictionary *)dictionaryForHandlerKey:(NSString *)key {
    id obj = [self objectForHandlerKey:key];
    if (obj && ![obj isKindOfClass:NSDictionary.class]) {
        NSAssert(NO, @"VEPlayer Context Handler obj is not NSDictionary");
        return nil;
    } else {
        return obj;
    }
}

- (NSArray *)arrayForHandlerKey:(NSString *)key {
    id obj = [self objectForHandlerKey:key];
    if (obj && ![obj isKindOfClass:NSArray.class]) {
        NSAssert(NO, @"VEPlayer Context Handler obj is not NSArray");
        return nil;
    } else {
        return obj;
    }
}

- (BOOL)boolForHandlerKey:(NSString *)key {
    id obj = [self objectForHandlerKey:key];
    BOOL result = NO;
    if ([obj respondsToSelector:@selector(boolValue)]) {
        result = [obj boolValue];
    }
    return result;
}

- (NSInteger)integerForHandlerKey:(NSString *)key {
    id obj = [self objectForHandlerKey:key];
    NSInteger result = NO;
    if ([obj respondsToSelector:@selector(integerValue)]) {
        result = [obj integerValue];
    }
    return result;
}

- (float)floatForHandlerKey:(NSString *)key {
    id obj = [self objectForHandlerKey:key];
    float result = NO;
    if ([obj respondsToSelector:@selector(floatValue)]) {
        result = [obj floatValue];
    }
    return result;
}

- (double)doubleForHandlerKey:(NSString *)key {
    id obj = [self objectForHandlerKey:key];
    double result = NO;
    if ([obj respondsToSelector:@selector(doubleValue)]) {
        result = [obj doubleValue];
    }
    return result;
}

@end



@implementation VEPlayerContext (DIService)

- (void)bindOwner:(id)owner withProtocol:(Protocol *)protocol {
    [self.di bindOwner:owner withProtocol:protocol];
}

- (id)serviceForKey:(NSString *)key {
    return [self.di serviceForKey:key];
}

- (id)serviceForKey:(NSString *)key creator:(VEPlayerContextObjectCreator)creator {
    return [self.di serviceForKey:key creator:creator];
}

- (void)setService:(id)object forKey:(nonnull NSString *)key {
    [self.di setService:object forKey:key];
}

- (void)removeServiceForKey:(NSString *)key {
    [self.di removeServiceForKey:key];
}

@end


void ve_player_di_bind(NSObject *prop, Protocol *p, VEPlayerContext *context) {
    NSString *protocolName =  NSStringFromProtocol(p);
    [context setService:prop forKey:protocolName];
}

void ve_player_di_unbind(Protocol *p, VEPlayerContext *context) {
    NSString *protocolName =  NSStringFromProtocol(p);
    [context removeServiceForKey:protocolName];
}

id ve_playerLink_get_property(Protocol *p, VEPlayerContext *context) {
    NSString *protocolName =  NSStringFromProtocol(p);
    return [context serviceForKey:protocolName];
}

