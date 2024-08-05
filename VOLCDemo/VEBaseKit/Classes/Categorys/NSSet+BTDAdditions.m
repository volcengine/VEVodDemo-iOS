//
//  NSSet+BTDAdditions.m
//  Pods
//

#import "NSSet+BTDAdditions.h"
#import "BTDMacros.h"

@implementation NSSet (BTDAdditions)

- (void)btd_forEach:(void (^)(id _Nonnull))block {
    NSParameterAssert(block != nil);
    [self enumerateObjectsUsingBlock:^(id  _Nonnull obj, BOOL * _Nonnull stop) {
        block(obj);
    }];
}

- (BOOL)btd_contains:(BOOL (^)(id _Nonnull))block {
    NSParameterAssert(block != nil);
    __block BOOL result = NO;
    [self enumerateObjectsUsingBlock:^(id  _Nonnull obj, BOOL * _Nonnull stop) {
        if (block(obj)) {
            result = YES;
            *stop = YES;
        }
    }];
    return result;
}

- (BOOL)btd_all:(BOOL (^)(id _Nonnull))block {
    NSParameterAssert(block != nil);
    __block BOOL result = YES;
    [self enumerateObjectsUsingBlock:^(id  _Nonnull obj, BOOL * _Nonnull stop) {
        if (!block(obj)) {
            result = NO;
            *stop = YES;
        }
    }];
    return result;
}

- (id)btd_find:(BOOL (^)(id _Nonnull))block {
    NSParameterAssert(block != nil);
    __block id result = nil;
    [self enumerateObjectsUsingBlock:^(id  _Nonnull obj, BOOL * _Nonnull stop) {
        if (block(obj)) {
            result = obj;
            *stop = YES;
        }
    }];
    return result;
}

- (NSSet *)btd_filter:(BOOL (^)(id _Nonnull))block {
    NSParameterAssert(block != nil);
    NSMutableSet *result = [NSMutableSet setWithCapacity:self.count];
    [self enumerateObjectsUsingBlock:^(id  _Nonnull obj, BOOL * _Nonnull stop) {
        if (block(obj)) {
            [result addObject:obj];
        }
    }];
    return [result copy];
}

- (NSSet<id> *)btd_map:(id  _Nullable (^)(id _Nonnull))block {
    NSParameterAssert(block != nil);
    NSMutableSet *result = [NSMutableSet setWithCapacity:self.count];
    [self enumerateObjectsUsingBlock:^(id  _Nonnull obj, BOOL * _Nonnull stop) {
        id mapped = block(obj);
        NSAssert(mapped != nil, @"Fatal error: unexpectedly found nil while mapping to a nonnull value.");
        [result addObject:mapped ?: [NSNull null]];
    }];
    return [result copy];
}

- (NSSet<id> *)btd_compactMap:(id  _Nullable (^)(id _Nonnull))block {
    NSParameterAssert(block != nil);
    NSMutableSet *result = [NSMutableSet setWithCapacity:self.count];
    [self enumerateObjectsUsingBlock:^(id  _Nonnull obj, BOOL * _Nonnull stop) {
        id mapped = block(obj);
        if (mapped) {
            [result addObject:mapped];
        }
    }];
    return [result copy];
}

- (id)btd_reduce:(id)initialValue reducer:(id  _Nullable (^)(id _Nullable, id _Nonnull))block {
    NSParameterAssert(block != nil);
    __block id result = initialValue;
    [self enumerateObjectsUsingBlock:^(id  _Nonnull obj, BOOL * _Nonnull stop) {
        result = block(result, obj);
    }];
    return result;
}

@end

@implementation NSMutableSet (BTDAdditions)

- (void)btd_addObject:(id)object {
    if (object) {
        [self addObject:object];
    }
}

- (void)btd_removeObject:(id)object {
    if (object) {
        [self removeObject:object];
    }
}

@end

@interface BTDThreadSafeSet<ObjectType> : NSMutableSet

@property (nonatomic, strong) NSMutableSet<ObjectType> *btd_mutableSet;

@end

@implementation BTDThreadSafeSet {
    pthread_mutex_t _btd_setMutex;
}

/// MARK: init

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupMutex];
        _btd_mutableSet = [NSMutableSet set];
    }
    return self;
}

- (instancetype)initWithSet:(NSSet *)set {
    self = [super init];
    if (self) {
        [self setupMutex];
        _btd_mutableSet = [[NSMutableSet alloc] initWithSet:set];
    }
    return self;
}

- (instancetype)initWithCapacity:(NSUInteger)numItems {
    self = [super init];
    if (self) {
        [self setupMutex];
        _btd_mutableSet = [[NSMutableSet alloc] initWithCapacity:numItems];
    }
    return self;
}

/// MARK: NSCoding

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self setupMutex];
        _btd_mutableSet = [coder decodeObjectForKey:@"btd_mutableSet"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    BTD_MUTEX_LOCK(self->_btd_setMutex);
    [coder encodeObject:_btd_mutableSet forKey:@"btd_mutableSet"];
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (Class)classForCoder {
    return [self class];
}

/// MARK: mutex

- (void)setupMutex {
    /// avoid memory leak
    pthread_mutex_destroy(&_btd_setMutex);
    pthread_mutexattr_t mutexAttribute;
    pthread_mutexattr_init(&mutexAttribute);
    pthread_mutexattr_settype(&mutexAttribute, PTHREAD_MUTEX_RECURSIVE);
    pthread_mutex_init(&_btd_setMutex, &mutexAttribute);
    pthread_mutexattr_destroy(&mutexAttribute);
}

/// MARK: dealloc

- (void)dealloc {
    pthread_mutex_destroy(&_btd_setMutex);
}

/// MARK: Equal && hash

- (BOOL)isEqualToSet:(NSSet *)otherSet {
    if (otherSet == self) return YES;
    NSSet *copyingSet = ({
        BTD_MUTEX_LOCK(self->_btd_setMutex);
        [_btd_mutableSet copy];
    });
    return [copyingSet isEqualToSet:otherSet.copy];
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:NSSet.class]) return NO;
    return [self isEqualToSet:object];
}

- (NSUInteger)hash {
    BTD_MUTEX_LOCK(self->_btd_setMutex);
    return [_btd_mutableSet hash];
}

/// MARK: NSCopying

- (id)copyWithZone:(NSZone *)zone {
    BTD_MUTEX_LOCK(self->_btd_setMutex);
    return [_btd_mutableSet copy];
}

/// MARK: NSMutableCopying

- (id)mutableCopyWithZone:(NSZone *)zone {
    NSSet *copyingSet = ({
        BTD_MUTEX_LOCK(self->_btd_setMutex);
        [_btd_mutableSet copy];
    });
    return [[BTDThreadSafeSet alloc] initWithSet:copyingSet];
}


/// MARK: NSDictionary method

- (NSUInteger)count {
    BTD_MUTEX_LOCK(self->_btd_setMutex);
    return [_btd_mutableSet count];
}

- (id)member:(id)object {
    BTD_MUTEX_LOCK(self->_btd_setMutex);
    return [_btd_mutableSet member:object];
}

- (NSEnumerator *)objectEnumerator {
    NSSet *copyingSet = ({
        BTD_MUTEX_LOCK(self->_btd_setMutex);
        [_btd_mutableSet copy];
    });
    return [copyingSet objectEnumerator];
}

- (NSArray *)allObjects {
    BTD_MUTEX_LOCK(self->_btd_setMutex);
    return [_btd_mutableSet allObjects];
}

- (id)anyObject {
    BTD_MUTEX_LOCK(self->_btd_setMutex);
    return [_btd_mutableSet anyObject];
}

- (BOOL)containsObject:(id)anObject {
    BTD_MUTEX_LOCK(self->_btd_setMutex);
    return [_btd_mutableSet containsObject:anObject];
}

- (NSString *)description {
    BTD_MUTEX_LOCK(self->_btd_setMutex);
    return [_btd_mutableSet description];
}

- (NSString *)descriptionWithLocale:(id)locale {
    BTD_MUTEX_LOCK(self->_btd_setMutex);
    return [_btd_mutableSet descriptionWithLocale:locale];
}

- (BOOL)intersectsSet:(NSSet *)otherSet {
    NSSet *copyingSet = ({
        BTD_MUTEX_LOCK(self->_btd_setMutex);
        [_btd_mutableSet copy];
    });
    return [copyingSet intersectsSet:otherSet];
}

- (BOOL)isSubsetOfSet:(NSSet *)otherSet {
    NSSet *copyingSet = ({
        BTD_MUTEX_LOCK(self->_btd_setMutex);
        [_btd_mutableSet copy];
    });
    return [copyingSet isSubsetOfSet:otherSet];
}

- (void)makeObjectsPerformSelector:(SEL)aSelector {
    NSSet *copyingSet = ({
        BTD_MUTEX_LOCK(self->_btd_setMutex);
        [_btd_mutableSet copy];
    });
    [copyingSet makeObjectsPerformSelector:aSelector];
}

- (void)makeObjectsPerformSelector:(SEL)aSelector withObject:(id)argument {
    NSSet *copyingSet = ({
        BTD_MUTEX_LOCK(self->_btd_setMutex);
        [_btd_mutableSet copy];
    });
    [copyingSet makeObjectsPerformSelector:aSelector withObject:argument];
}

- (NSSet *)setByAddingObject:(id)anObject {
    NSSet *copyingSet = ({
        BTD_MUTEX_LOCK(self->_btd_setMutex);
        [_btd_mutableSet copy];
    });
    return [copyingSet setByAddingObject:anObject];
}

- (NSSet *)setByAddingObjectsFromSet:(NSSet *)other {
    NSSet *copyingSet = ({
        BTD_MUTEX_LOCK(self->_btd_setMutex);
        [_btd_mutableSet copy];
    });
    return [copyingSet setByAddingObjectsFromSet:other];
}

- (NSSet *)setByAddingObjectsFromArray:(NSArray *)other {
    BTD_MUTEX_LOCK(self->_btd_setMutex);
    return [_btd_mutableSet setByAddingObjectsFromArray:other];
}

- (void)enumerateObjectsUsingBlock:(void (NS_NOESCAPE ^)(id _Nonnull, BOOL * _Nonnull))block {
    NSSet *copyingSet = ({
        BTD_MUTEX_LOCK(self->_btd_setMutex);
        [_btd_mutableSet copy];
    });
    [copyingSet enumerateObjectsUsingBlock:block];
}

- (void)enumerateObjectsWithOptions:(NSEnumerationOptions)opts usingBlock:(void (NS_NOESCAPE ^)(id _Nonnull, BOOL * _Nonnull))block {
    NSSet *copyingSet = ({
        BTD_MUTEX_LOCK(self->_btd_setMutex);
        [_btd_mutableSet copy];
    });
    [copyingSet enumerateObjectsWithOptions:opts usingBlock:block];
}

- (NSSet *)objectsPassingTest:(BOOL (NS_NOESCAPE ^)(id _Nonnull, BOOL * _Nonnull))predicate {
    NSSet *copyingSet = ({
        BTD_MUTEX_LOCK(self->_btd_setMutex);
        [_btd_mutableSet copy];
    });
    return [copyingSet objectsPassingTest:predicate];
}

- (NSSet *)objectsWithOptions:(NSEnumerationOptions)opts passingTest:(BOOL (NS_NOESCAPE ^)(id _Nonnull, BOOL * _Nonnull))predicate {
    NSSet *copyingSet = ({
        BTD_MUTEX_LOCK(self->_btd_setMutex);
        [_btd_mutableSet copy];
    });
    return [copyingSet objectsWithOptions:opts passingTest:predicate];
}

/// MARK: Mutable set

- (void)addObject:(id)object {
    BTD_MUTEX_LOCK(self->_btd_setMutex);
    return [_btd_mutableSet addObject:object];
}

- (void)removeObject:(id)object {
    BTD_MUTEX_LOCK(self->_btd_setMutex);
    return [_btd_mutableSet removeObject:object];
}

- (void)addObjectsFromArray:(NSArray *)array {
    BTD_MUTEX_LOCK(self->_btd_setMutex);
    return [_btd_mutableSet addObjectsFromArray:array];
}

- (void)intersectSet:(NSSet *)otherSet {
    BTD_MUTEX_LOCK(self->_btd_setMutex);
    return [_btd_mutableSet intersectSet:otherSet];
}

- (void)minusSet:(NSSet *)otherSet {
    BTD_MUTEX_LOCK(self->_btd_setMutex);
    return [_btd_mutableSet minusSet:otherSet];
}

- (void)removeAllObjects {
    BTD_MUTEX_LOCK(self->_btd_setMutex);
    return [_btd_mutableSet removeAllObjects];
}

- (void)unionSet:(NSSet *)otherSet {
    BTD_MUTEX_LOCK(self->_btd_setMutex);
    return [_btd_mutableSet unionSet:otherSet];
}

- (void)setSet:(NSSet *)otherSet {
    NSSet *copyingSet = [otherSet copy];
    BTD_MUTEX_LOCK(self->_btd_setMutex);
    [_btd_mutableSet setSet:copyingSet];
}

/// MARK: BTDAdditions

- (void)btd_forEach:(void (^)(id _Nonnull))block {
    NSSet *copyingSet = ({
        BTD_MUTEX_LOCK(self->_btd_setMutex);
        [_btd_mutableSet copy];
    });
    [copyingSet btd_forEach:block];
}

- (BOOL)btd_contains:(BOOL (^)(id _Nonnull))block {
    NSSet *copyingSet = ({
        BTD_MUTEX_LOCK(self->_btd_setMutex);
        [_btd_mutableSet copy];
    });
    return [copyingSet btd_contains:block];
}

- (BOOL)btd_all:(BOOL (^)(id _Nonnull))block {
    NSSet *copyingSet = ({
        BTD_MUTEX_LOCK(self->_btd_setMutex);
        [_btd_mutableSet copy];
    });
    return [copyingSet btd_all:block];
}

- (id)btd_find:(BOOL (^)(id _Nonnull))block {
    NSSet *copyingSet = ({
        BTD_MUTEX_LOCK(self->_btd_setMutex);
        [_btd_mutableSet copy];
    });
    return [copyingSet btd_find:block];
}

- (NSSet *)btd_filter:(BOOL (^)(id _Nonnull))block {
    NSSet *copyingSet = ({
        BTD_MUTEX_LOCK(self->_btd_setMutex);
        [_btd_mutableSet copy];
    });
    return [copyingSet btd_filter:block];
}

- (NSSet<id> *)btd_map:(id  _Nullable (^)(id _Nonnull))block {
    NSSet *copyingSet = ({
        BTD_MUTEX_LOCK(self->_btd_setMutex);
        [_btd_mutableSet copy];
    });
    return [copyingSet btd_map:block];
}

- (NSSet<id> *)btd_compactMap:(id  _Nullable (^)(id _Nonnull))block {
    NSSet *copyingSet = ({
        BTD_MUTEX_LOCK(self->_btd_setMutex);
        [_btd_mutableSet copy];
    });
    return [copyingSet btd_compactMap:block];
}

- (id)btd_reduce:(id)initialValue reducer:(id  _Nullable (^)(id _Nullable, id _Nonnull))block {
    NSSet *copyingSet = ({
        BTD_MUTEX_LOCK(self->_btd_setMutex);
        [_btd_mutableSet copy];
    });
    return [copyingSet btd_reduce:block reducer:block];
}

- (void)btd_addObject:(id)object {
    BTD_MUTEX_LOCK(self->_btd_setMutex);
    [_btd_mutableSet btd_addObject:object];
}

- (void)btd_removeObject:(id)object {
    BTD_MUTEX_LOCK(self->_btd_setMutex);
    [_btd_mutableSet btd_removeObject:object];
}

@end

@implementation NSSet (BTDThreadSafe)

- (NSMutableSet *)btd_threadSafe {
    if ([self isKindOfClass:[BTDThreadSafeSet class]]) {
        return [[BTDThreadSafeSet alloc] initWithSet:[self copy]];
    }
    return [[BTDThreadSafeSet alloc] initWithSet:self.copy];
}

@end

@implementation NSMutableSet (BTDThreadSafe)

+ (NSMutableSet *)btd_threadSafeSet {
    return [BTDThreadSafeSet set];
}

@end
