//
//  VELRUCache.m
//  VEBaseKit
//
//  Created by zyw on 2024/10/10.
//

#import "VELRUCache.h"

@interface LRUItem : NSObject

@property (nonatomic, strong) id key;
@property (nonatomic, strong) id value;
@property (nonatomic, assign) NSTimeInterval accessTime;

- (instancetype)initWithKey:(id)key value:(id)value;

@end

@implementation LRUItem

- (instancetype)initWithKey:(id)key value:(id)value {
    self = [super init];
    if (self) {
        _key = key;
        _value = value;
        _accessTime = [NSDate timeIntervalSinceReferenceDate];
    }
    return self;
}

@end

@interface VELRUCache ()

@property (nonatomic, assign) NSUInteger capacity;
@property (nonatomic, strong) NSMutableDictionary *cacheDict;
@property (nonatomic, strong) NSMutableArray *accessOrderArray;

- (instancetype)initWithCapacity:(NSUInteger)capacity;
- (id)getValueForKey:(id)key;
- (void)setValue:(id)value forKey:(id)key;

@end

@implementation VELRUCache

+ (VELRUCache *)shareInstance {
    static VELRUCache *LRUCacheInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (LRUCacheInstance == nil) {
            LRUCacheInstance = [[VELRUCache alloc] initWithCapacity:200];
        }
    });
    return LRUCacheInstance;
}

- (instancetype)initWithCapacity:(NSUInteger)capacity {
    self = [super init];
    if (self) {
        _capacity = capacity;
        _cacheDict = [NSMutableDictionary dictionary];
        _accessOrderArray = [NSMutableArray array];
    }
    return self;
}

- (id)getValueForKey:(id)key {
    LRUItem *item = [self.cacheDict objectForKey:key];
    if (item) {
        [self updateAccessTimeForItem:item];
        return item.value;
    }
    return nil;
}

- (void)setValue:(id)value forKey:(id)key {
    LRUItem *item = [self.cacheDict objectForKey:key];
    if (item) {
        item.value = value;
        [self updateAccessTimeForItem:item];
    } else {
        item = [[LRUItem alloc] initWithKey:key value:value];
        [self addItem:item];
    }
}

- (void)updateAccessTimeForItem:(LRUItem *)item {
    item.accessTime = [NSDate timeIntervalSinceReferenceDate];
    [self.accessOrderArray removeObject:item];
    [self.accessOrderArray insertObject:item atIndex:0];
}

- (void)addItem:(LRUItem *)item {
    if (self.accessOrderArray.count >= self.capacity) {
        LRUItem *lastItem = [self.accessOrderArray lastObject];
        [self.cacheDict removeObjectForKey:lastItem.key];
        [self.accessOrderArray removeLastObject];
    }
    [self.cacheDict setObject:item forKey:item.key];
    [self.accessOrderArray insertObject:item atIndex:0];
}

@end
