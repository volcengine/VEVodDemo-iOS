//
//  VEPlayerContextStorage.m
//  VEPlayerKit
//

#import "VEPlayerContextStorage.h"
#import "VEPlayerContextItem.h"

@interface VEPlayerContextStorage ()

@property (nonatomic, strong) NSMutableDictionary *cache;

@end

@implementation VEPlayerContextStorage

#pragma mark - Life Cycle
- (instancetype)init {
    self = [super init];
    if (self) {
        _enableCache = YES;
        [self _openCache];
    }
    return self;
}

- (void)dealloc {
    [self _closeCache];
}

- (id)objectForKey:(NSString *)key {
    if (!key || key.length <= 0) {
        return nil;
    }
    VEPlayerContextItem *item = [self contextItemForKey:key];

    if (![item isKindOfClass:VEPlayerContextItem.class] || ![item.key isEqualToString:key]) {
        return nil;
    }
    return item.object;
}

- (id)objectForKey:(NSString *)key creator:(VEPlayerContextObjectCreator)creator {
    if (!key || key.length <= 0) {
        return nil;
    }
    VEPlayerContextItem *item = [self contextItemForKey:key creator:creator];
    
    if (![item isKindOfClass:VEPlayerContextItem.class] || ![item.key isEqualToString:key]) {
        return nil;
    }

    return item.object;
}

- (VEPlayerContextItem *)contextItemForKey:(NSString *)key {
    if (!key || key.length <= 0) {
        return nil;
    }
    VEPlayerContextItem *item = [self.cache objectForKey:key];
    if (!item) {
        item = [[VEPlayerContextItem alloc] init];
        item.key = key;
        [self.cache setObject:item forKey:key];
    }

    return item;
}

- (VEPlayerContextItem *)contextItemForKey:(NSString *)key creator:(VEPlayerContextObjectCreator)creator {
    if (!key || key.length <= 0) {
        return nil;
    }
    VEPlayerContextItem *item = [self contextItemForKey:key];
    if (creator) {
        item.object = creator();
    }
    
    return item;
}

- (id)setObject:(id)object forKey:(NSString *)key {
    if (!key || key.length <= 0) {
        return nil;
    }
    VEPlayerContextItem *item = [self.cache objectForKey:key];
    if (!item) {
        item = [[VEPlayerContextItem alloc] init];
    }
    item.key = key;
    if (self.enableCache) {
        item.object = object;
    }
    [self.cache setObject:item forKey:key];
    
    [self _notify:item object:object];
    
    return item;
}

- (void)removeObjectForKey:(NSString *)key {
    if (!key || key.length <= 0) {
        return;
    }
    [self.cache removeObjectForKey:key];
}

- (void)removeAllObject {
    [self.cache removeAllObjects];
}

#pragma mark - Cache Private Method
- (void)_openCache {
    if (!_cache) {
        _cache = [NSMutableDictionary dictionary];
    }
}

- (void)_closeCache {
    if (_cache) {
        _cache = nil;
    }
}

#pragma mark - Notify Private Method
- (void)_notify:(VEPlayerContextItem *)item object:(id)object {
    [item notify:object];
}

@end
