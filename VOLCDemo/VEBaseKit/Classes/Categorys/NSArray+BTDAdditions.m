//
//  NSArray+BTDAdditions.m
//

#import "NSArray+BTDAdditions.h"
#import "NSObject+BTDAdditions.h"
#import "BTDMacros.h"

@implementation NSArray (BTDAdditions)

- (NSString *)btd_jsonStringEncoded
{
    NSError *error = nil;
    return [self btd_jsonStringEncoded:&error];
}

- (NSString *)btd_jsonStringEncoded:(NSError *__autoreleasing *)error
{
    if ([NSJSONSerialization isValidJSONObject:self]) {
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self options:kNilOptions error:error];
        NSString *json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        return json;
    }
    return nil;
}

- (NSString *)btd_jsonStringPrettyEncoded {
    if ([NSJSONSerialization isValidJSONObject:self]) {
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:&error];
        if (error == nil) {
            NSString *json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            return json;
        }
    }
    return nil;
}

- (id)btd_safeJsonObject
{
    NSMutableArray *safeEncodingArray = [NSMutableArray array];
    for (id arrayValue in (NSArray *)self) {
        [safeEncodingArray addObject:[arrayValue btd_safeJsonObject]];
    }
    return safeEncodingArray.copy;
}

- (NSString *)btd_safeJsonStringEncoded
{
    id object = [self btd_safeJsonObject];
    if ([object isKindOfClass:[NSArray class]]) {
        return [object btd_jsonStringEncoded];
    }
    return nil;
}

- (NSString *)btd_safeJsonStringEncoded:(NSError *__autoreleasing *)error
{
    id object = [self btd_safeJsonObject];
    if ([object isKindOfClass:[NSArray class]]) {
        return [object btd_jsonStringEncoded:error];
    }
    return nil;
}

- (id)btd_objectAtIndex:(NSUInteger)index {
    if (index < self.count) {
        return [self objectAtIndex:index];
    }
    return nil;
}

- (id)btd_objectAtIndex:(NSUInteger)index class:(Class)cls {
    id obj = [self btd_objectAtIndex:index];
    if ([obj isKindOfClass:cls]) {
        return obj;
    }
    return nil;
}

- (void)btd_forEach:(void (^)(id _Nonnull))block {
    NSParameterAssert(block != nil);
    [self enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        block(obj);
    }];
}

- (BOOL)btd_contains:(BOOL (^)(id _Nonnull))block {
    NSParameterAssert(block != nil);
    __block BOOL result = NO;
    [self enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
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
    [self enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (!block(obj)) {
            result = NO;
            *stop = YES;
        }
    }];
    return result;
}

- (NSUInteger)btd_firstIndex:(BOOL (^)(id _Nonnull))block {
    NSParameterAssert(block != nil);
    __block NSUInteger result = NSNotFound;
    [self enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (block(obj)) {
            result = idx;
            *stop = YES;
        }
    }];
    return result;
}

- (id)btd_find:(BOOL (^)(id _Nonnull))block {
    NSParameterAssert(block != nil);
    __block id result = nil;
    [self enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (block(obj)) {
            result = obj;
            *stop = YES;
        }
    }];
    return result;
}

- (NSArray *)btd_filter:(BOOL (^)(id _Nonnull))block {
    NSParameterAssert(block != nil);
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:self.count];
    [self enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (block(obj)) {
            [result addObject:obj];
        }
    }];
    return [result copy];
}

- (NSArray<id> *)btd_map:(id  _Nonnull (^)(id _Nonnull))block {
    NSParameterAssert(block != nil);
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:self.count];
    [self enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        id mapped = block(obj);
        NSAssert(mapped != nil, @"Fatal error: unexpectedly found nil while mapping to a nonnull value.");
        [result addObject:mapped ?: [NSNull null]];
    }];
    return [result copy];
}

- (NSArray<id> *)btd_compactMap:(id  _Nullable (^)(id _Nonnull))block {
    NSParameterAssert(block != nil);
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:self.count];
    [self enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
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
    [self enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        result = block(result, obj);
    }];
    return result;
}

- (NSArray *)btd_arrayByAddingObject:(id)anObject {
    if (anObject == nil) {
        return [NSArray arrayWithArray:self];
    }
    return [self arrayByAddingObject:anObject];
}

- (NSArray *)btd_arrayByAddingObjectsFromArray:(NSArray *)otherArray {
    if (otherArray == nil) {
        return [NSArray arrayWithArray:self];
    }
    return [self arrayByAddingObjectsFromArray:otherArray];
}

- (NSRange)btd_validRange:(NSRange)range {
    if (range.length == 0 || range.location >= self.count) {
        return NSMakeRange(NSNotFound, 0);
    }
    NSUInteger validLength = self.count - range.location;
    if (range.length > validLength || NSMaxRange(range) < range.location ) {
        range.length = validLength;
    }
    return range;
}

- (NSArray *)btd_subarrayWithRange:(NSRange)range {
    NSRange fixedRange = [self btd_validRange:range];
    if (fixedRange.location == NSNotFound) {
        return @[];
    }
    return [self subarrayWithRange:fixedRange];
}

@end

@implementation NSMutableArray (BTDAdditions)

- (void)btd_addObject:(id)anObject {
    if (anObject != nil) {
        [self addObject:anObject];
    }
}

- (void)btd_addArray:(NSArray<id> *)objects {
    if (objects && [objects isKindOfClass:NSArray.class] && objects.count) {
        [self addObjectsFromArray:objects];
    }
}

- (void)btd_insertObject:(id)anObject atIndex:(NSUInteger)index {
    if (anObject != nil && index <= self.count) {
        [self insertObject:anObject atIndex:index];
    }
}

- (void)btd_insertObjects:(NSArray *)objects atIndexes:(NSIndexSet *)indexes {
    if (objects != nil && indexes != nil &&
        objects.count == indexes.count &&
        [indexes indexGreaterThanOrEqualToIndex:(self.count + objects.count)] == NSNotFound) {
        [self insertObjects:objects atIndexes:indexes];
    }
}

- (void)btd_replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject {
    if (anObject != nil && index < self.count) {
        [self replaceObjectAtIndex:index withObject:anObject];
    }
}

- (void)btd_removeObject:(id)anObject {
    if (anObject != nil) {
        [self removeObject:anObject];
    }
}

- (void)btd_removeObjectAtIndex:(NSUInteger)index {
    if (index < self.count) {
        [self removeObjectAtIndex:index];
    }
}

- (void)btd_removeObjectsInIndexes:(NSIndexSet *)indexes {
    [indexes enumerateIndexesWithOptions:NSEnumerationReverse usingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
        [self btd_removeObjectAtIndex:idx];
    }];
}

- (void)btd_removeObjectsInRange:(NSRange)range {
    NSRange fixedRange = [self btd_validRange:range];
    if (fixedRange.location == NSNotFound) {
        return;
    }
    [self removeObjectsInRange:fixedRange];
}

- (void)btd_exchangeObjectAtIndex:(NSUInteger)idx1 withObjectAtIndex:(NSUInteger)idx2 {
    if (idx1 >= self.count || idx2 >= self.count) {
        return;
    }
    [self exchangeObjectAtIndex:idx1 withObjectAtIndex:idx2];
}

@end

@interface BTDThreadSafeArray : NSMutableArray

@property (nonatomic, strong) NSMutableArray *btd_mutableArray;

@end

@implementation BTDThreadSafeArray {
    pthread_mutex_t _btd_arrayMutex;
}

/// MARK: init

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupMutex];
        _btd_mutableArray = [NSMutableArray array];
    }
    return self;
}

- (instancetype)initWithArray:(NSArray *)array {
    self = [super init];
    if (self) {
        [self setupMutex];
        _btd_mutableArray = [[NSMutableArray alloc] initWithArray:array];
    }
    return self;
}

- (instancetype)initWithCapacity:(NSUInteger)numItems {
    self = [super init];
    if (self) {
        [self setupMutex];
        _btd_mutableArray = [[NSMutableArray alloc] initWithCapacity:numItems];
    }
    return self;
}

/// MARK: NSCoding

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self setupMutex];
        _btd_mutableArray = [coder decodeObjectForKey:@"btd_mutableArray"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    BTD_MUTEX_LOCK(self->_btd_arrayMutex);
    [coder encodeObject:_btd_mutableArray forKey:@"btd_mutableArray"];
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
    pthread_mutex_destroy(&_btd_arrayMutex);
    pthread_mutexattr_t mutexAttribute;
    pthread_mutexattr_init(&mutexAttribute);
    pthread_mutexattr_settype(&mutexAttribute, PTHREAD_MUTEX_RECURSIVE);
    pthread_mutex_init(&_btd_arrayMutex, &mutexAttribute);
    pthread_mutexattr_destroy(&mutexAttribute);
}

/// MARK: dealloc

- (void)dealloc {
    pthread_mutex_destroy(&_btd_arrayMutex);
}

/// MARK: Equal && hash

- (BOOL)isEqualToArray:(NSArray *)otherArray {
    if (otherArray == self) return YES;
    NSArray *copyingArray = ({
        BTD_MUTEX_LOCK(self->_btd_arrayMutex);
        [_btd_mutableArray copy];
    });
    return [copyingArray isEqualToArray:otherArray.copy];
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:NSArray.class]) return NO;
    return [self isEqualToArray:object];
}

- (NSUInteger)hash {
    BTD_MUTEX_LOCK(self->_btd_arrayMutex);
    return [_btd_mutableArray hash];
}

/// MARK: NSCopying

- (id)copyWithZone:(NSZone *)zone {
    BTD_MUTEX_LOCK(self->_btd_arrayMutex);
    return [_btd_mutableArray copy];
}

/// MARK: NSMutableCopying

- (id)mutableCopyWithZone:(NSZone *)zone {
    NSArray *copyingArray = ({
        BTD_MUTEX_LOCK(self->_btd_arrayMutex);
        [_btd_mutableArray copy];
    });
    return [[BTDThreadSafeArray alloc] initWithArray:copyingArray];
}


/// MARK: NSArray method

- (NSUInteger)count {
    BTD_MUTEX_LOCK(self->_btd_arrayMutex);
    return _btd_mutableArray.count;
}

- (id)objectAtIndex:(NSUInteger)index {
    BTD_MUTEX_LOCK(self->_btd_arrayMutex);
    return [_btd_mutableArray objectAtIndex:index];
}

/// MARK: NSExtendedArray

- (NSArray *)arrayByAddingObject:(id)anObject {
    BTD_MUTEX_LOCK(self->_btd_arrayMutex);
    return [_btd_mutableArray arrayByAddingObject:anObject];
}

- (NSArray *)arrayByAddingObjectsFromArray:(NSArray *)otherArray {
    BTD_MUTEX_LOCK(self->_btd_arrayMutex);
    return [_btd_mutableArray arrayByAddingObjectsFromArray:otherArray];
}

- (NSString *)componentsJoinedByString:(NSString *)separator {
    BTD_MUTEX_LOCK(self->_btd_arrayMutex);
    return [_btd_mutableArray componentsJoinedByString:separator];
}

- (BOOL)containsObject:(id)anObject {
    BTD_MUTEX_LOCK(self->_btd_arrayMutex);
    return [_btd_mutableArray containsObject:anObject];
}

- (NSString *)description {
    BTD_MUTEX_LOCK(self->_btd_arrayMutex);
    return [_btd_mutableArray description];
}

- (NSString *)descriptionWithLocale:(id)locale {
    BTD_MUTEX_LOCK(self->_btd_arrayMutex);
    return [_btd_mutableArray descriptionWithLocale:locale];
}

- (NSString *)descriptionWithLocale:(id)locale indent:(NSUInteger)level {
    BTD_MUTEX_LOCK(self->_btd_arrayMutex);
    return [_btd_mutableArray descriptionWithLocale:locale indent:level];
}

- (id)firstObjectCommonWithArray:(NSArray *)otherArray {
    BTD_MUTEX_LOCK(self->_btd_arrayMutex);
    return [_btd_mutableArray firstObjectCommonWithArray:otherArray];
}

- (void)getObjects:(__unsafe_unretained id _Nonnull[])objects range:(NSRange)range {
    BTD_MUTEX_LOCK(self->_btd_arrayMutex);
    [_btd_mutableArray getObjects:objects range:range];
}

- (NSUInteger)indexOfObject:(id)anObject {
    BTD_MUTEX_LOCK(self->_btd_arrayMutex);
    return [_btd_mutableArray indexOfObject:anObject];
}

- (NSUInteger)indexOfObject:(id)anObject inRange:(NSRange)range {
    BTD_MUTEX_LOCK(self->_btd_arrayMutex);
    return [_btd_mutableArray indexOfObject:anObject inRange:range];
}

- (NSUInteger)indexOfObjectIdenticalTo:(id)anObject {
    BTD_MUTEX_LOCK(self->_btd_arrayMutex);
    return [_btd_mutableArray indexOfObjectIdenticalTo:anObject];
}

- (NSUInteger)indexOfObjectIdenticalTo:(id)anObject inRange:(NSRange)range {
    BTD_MUTEX_LOCK(self->_btd_arrayMutex);
    return [_btd_mutableArray indexOfObjectIdenticalTo:anObject inRange:range];
}

- (id)firstObject {
    BTD_MUTEX_LOCK(self->_btd_arrayMutex);
    return [_btd_mutableArray firstObject];
}

- (id)lastObject {
    BTD_MUTEX_LOCK(self->_btd_arrayMutex);
    return [_btd_mutableArray lastObject];
}

- (NSEnumerator *)objectEnumerator {
    NSArray *copyingArray = ({
        BTD_MUTEX_LOCK(self->_btd_arrayMutex);
        [_btd_mutableArray copy];
    });
    return [copyingArray objectEnumerator];
}

- (NSEnumerator *)reverseObjectEnumerator {
    NSArray *copyingArray = ({
        BTD_MUTEX_LOCK(self->_btd_arrayMutex);
        [_btd_mutableArray copy];
    });
    return [copyingArray reverseObjectEnumerator];
}

- (NSData *)sortedArrayHint {
    BTD_MUTEX_LOCK(self->_btd_arrayMutex);
    return [_btd_mutableArray sortedArrayHint];
}

- (NSArray *)sortedArrayUsingFunction:(NSInteger (NS_NOESCAPE *)(id  _Nonnull __strong, id  _Nonnull __strong, void * _Nullable))comparator context:(void *)context {
    NSArray *copyingArray = ({
        BTD_MUTEX_LOCK(self->_btd_arrayMutex);
        [_btd_mutableArray copy];
    });
    return [copyingArray sortedArrayUsingFunction:comparator context:context];
}

- (NSArray *)sortedArrayUsingFunction:(NSInteger (NS_NOESCAPE *)(id  _Nonnull __strong, id  _Nonnull __strong, void * _Nullable))comparator context:(void *)context hint:(NSData *)hint {
    NSArray *copyingArray = ({
        BTD_MUTEX_LOCK(self->_btd_arrayMutex);
        [_btd_mutableArray copy];
    });
    return [copyingArray sortedArrayUsingFunction:comparator context:context hint:hint];
}

- (NSArray *)sortedArrayUsingSelector:(SEL)comparator {
    NSArray *copyingArray = ({
        BTD_MUTEX_LOCK(self->_btd_arrayMutex);
        [_btd_mutableArray copy];
    });
    return [copyingArray sortedArrayUsingSelector:comparator];
}

- (NSArray *)subarrayWithRange:(NSRange)range {
    NSArray *copyingArray = ({
        BTD_MUTEX_LOCK(self->_btd_arrayMutex);
        [_btd_mutableArray copy];
    });
    return [copyingArray subarrayWithRange:range];
}

- (BOOL)writeToURL:(NSURL *)url error:(NSError *__autoreleasing  _Nullable *)error {
    BTD_MUTEX_LOCK(self->_btd_arrayMutex);
    return [_btd_mutableArray writeToURL:url error:error];
}

- (void)makeObjectsPerformSelector:(SEL)aSelector {
    NSArray *copyingArray = ({
        BTD_MUTEX_LOCK(self->_btd_arrayMutex);
        [_btd_mutableArray copy];
    });
    [copyingArray makeObjectsPerformSelector:aSelector];
}

- (void)makeObjectsPerformSelector:(SEL)aSelector withObject:(id)argument {
   NSArray *copyingArray = ({
        BTD_MUTEX_LOCK(self->_btd_arrayMutex);
        [_btd_mutableArray copy];
    });
    [copyingArray makeObjectsPerformSelector:aSelector withObject:argument];
}

- (NSArray *)objectsAtIndexes:(NSIndexSet *)indexes {
    BTD_MUTEX_LOCK(self->_btd_arrayMutex);
    return [_btd_mutableArray objectsAtIndexes:indexes];
}

- (id)objectAtIndexedSubscript:(NSUInteger)idx {
    BTD_MUTEX_LOCK(self->_btd_arrayMutex);
    return [_btd_mutableArray objectAtIndexedSubscript:idx];
}

- (void)enumerateObjectsUsingBlock:(void (NS_NOESCAPE ^)(id _Nonnull, NSUInteger, BOOL * _Nonnull))block {
   NSArray *copyingArray = ({
        BTD_MUTEX_LOCK(self->_btd_arrayMutex);
        [_btd_mutableArray copy];
    });
    [copyingArray enumerateObjectsUsingBlock:block];
}

- (void)enumerateObjectsWithOptions:(NSEnumerationOptions)opts usingBlock:(void (NS_NOESCAPE ^)(id _Nonnull, NSUInteger, BOOL * _Nonnull))block {
   NSArray *copyingArray = ({
        BTD_MUTEX_LOCK(self->_btd_arrayMutex);
        [_btd_mutableArray copy];
    });
    [copyingArray enumerateObjectsWithOptions:opts usingBlock:block];
}

- (void)enumerateObjectsAtIndexes:(NSIndexSet *)s options:(NSEnumerationOptions)opts usingBlock:(void (NS_NOESCAPE ^)(id _Nonnull, NSUInteger, BOOL * _Nonnull))block {
   NSArray *copyingArray = ({
        BTD_MUTEX_LOCK(self->_btd_arrayMutex);
        [_btd_mutableArray copy];
    });
    [copyingArray enumerateObjectsAtIndexes:s options:opts usingBlock:block];
}

- (NSUInteger)indexOfObjectPassingTest:(BOOL (NS_NOESCAPE ^)(id _Nonnull, NSUInteger, BOOL * _Nonnull))predicate {
   NSArray *copyingArray = ({
        BTD_MUTEX_LOCK(self->_btd_arrayMutex);
        [_btd_mutableArray copy];
    });
    return [copyingArray indexOfObjectPassingTest:predicate];
}

- (NSUInteger)indexOfObjectWithOptions:(NSEnumerationOptions)opts passingTest:(BOOL (NS_NOESCAPE ^)(id obj, NSUInteger idx, BOOL *stop))predicate {
   NSArray *copyingArray = ({
        BTD_MUTEX_LOCK(self->_btd_arrayMutex);
        [_btd_mutableArray copy];
    });
    return [copyingArray indexOfObjectWithOptions:opts passingTest:predicate];
}

- (NSUInteger)indexOfObjectAtIndexes:(NSIndexSet *)s options:(NSEnumerationOptions)opts passingTest:(BOOL (NS_NOESCAPE ^)(id obj, NSUInteger idx, BOOL *stop))predicate {
   NSArray *copyingArray = ({
        BTD_MUTEX_LOCK(self->_btd_arrayMutex);
        [_btd_mutableArray copy];
    });
    return [copyingArray indexOfObjectAtIndexes:s options:opts passingTest:predicate];
}

- (NSIndexSet *)indexesOfObjectsPassingTest:(BOOL (NS_NOESCAPE ^)(id obj, NSUInteger idx, BOOL *stop))predicate {
   NSArray *copyingArray = ({
        BTD_MUTEX_LOCK(self->_btd_arrayMutex);
        [_btd_mutableArray copy];
    });
    return [copyingArray indexesOfObjectsPassingTest:predicate];
}

- (NSIndexSet *)indexesOfObjectsWithOptions:(NSEnumerationOptions)opts passingTest:(BOOL (NS_NOESCAPE ^)(id obj, NSUInteger idx, BOOL *stop))predicate {
   NSArray *copyingArray = ({
        BTD_MUTEX_LOCK(self->_btd_arrayMutex);
        [_btd_mutableArray copy];
    });
    return [copyingArray indexesOfObjectsWithOptions:opts passingTest:predicate];
}

- (NSIndexSet *)indexesOfObjectsAtIndexes:(NSIndexSet *)s options:(NSEnumerationOptions)opts passingTest:(BOOL (NS_NOESCAPE ^)(id obj, NSUInteger idx, BOOL *stop))predicate {
   NSArray *copyingArray = ({
        BTD_MUTEX_LOCK(self->_btd_arrayMutex);
        [_btd_mutableArray copy];
    });
    return [copyingArray indexesOfObjectsAtIndexes:s options:opts passingTest:predicate];
}

- (NSArray *)sortedArrayUsingComparator:(NSComparator NS_NOESCAPE)comparator {
   NSArray *copyingArray = ({
        BTD_MUTEX_LOCK(self->_btd_arrayMutex);
        [_btd_mutableArray copy];
    });
    return [copyingArray sortedArrayUsingComparator:comparator];
}

- (NSArray *)sortedArrayWithOptions:(NSSortOptions)opts usingComparator:(NSComparator NS_NOESCAPE)comparator {
   NSArray *copyingArray = ({
        BTD_MUTEX_LOCK(self->_btd_arrayMutex);
        [_btd_mutableArray copy];
    });
    return [copyingArray sortedArrayWithOptions:opts usingComparator:comparator];
}

- (NSUInteger)indexOfObject:(id)obj inSortedRange:(NSRange)r options:(NSBinarySearchingOptions)opts usingComparator:(NSComparator NS_NOESCAPE)comparator {
   NSArray *copyingArray = ({
        BTD_MUTEX_LOCK(self->_btd_arrayMutex);
        [_btd_mutableArray copy];
    });
    return [copyingArray indexOfObject:obj inSortedRange:r options:opts usingComparator:comparator];
}

/// MARK: NSArrayDiffing

- (NSOrderedCollectionDifference *)differenceFromArray:(NSArray *)other withOptions:(NSOrderedCollectionDifferenceCalculationOptions)options usingEquivalenceTest:(BOOL (NS_NOESCAPE ^)(id _Nonnull, id _Nonnull))block  API_AVAILABLE(ios(13.0)){
   NSArray *copyingArray = ({
        BTD_MUTEX_LOCK(self->_btd_arrayMutex);
        [_btd_mutableArray copy];
    });
    return [copyingArray differenceFromArray:other withOptions:options usingEquivalenceTest:block];
}

- (NSOrderedCollectionDifference *)differenceFromArray:(NSArray *)other withOptions:(NSOrderedCollectionDifferenceCalculationOptions)options  API_AVAILABLE(ios(13.0)){
   NSArray *copyingArray = ({
        BTD_MUTEX_LOCK(self->_btd_arrayMutex);
        [_btd_mutableArray copy];
    });
    return [copyingArray differenceFromArray:other withOptions:options];
}

- (NSOrderedCollectionDifference *)differenceFromArray:(NSArray *)other  API_AVAILABLE(ios(13.0)){
   NSArray *copyingArray = ({
        BTD_MUTEX_LOCK(self->_btd_arrayMutex);
        [_btd_mutableArray copy];
    });
    return [copyingArray differenceFromArray:other];
}

- (NSArray *)arrayByApplyingDifference:(NSOrderedCollectionDifference *)difference  API_AVAILABLE(ios(13.0)){
   NSArray *copyingArray = ({
        BTD_MUTEX_LOCK(self->_btd_arrayMutex);
        [_btd_mutableArray copy];
    });
    return [copyingArray arrayByApplyingDifference:difference];
}

/// MARK: NSMutableArray

- (void)addObject:(id)anObject {
    BTD_MUTEX_LOCK(self->_btd_arrayMutex);
    [_btd_mutableArray addObject:anObject];
}

- (void)insertObject:(id)anObject atIndex:(NSUInteger)index {
    BTD_MUTEX_LOCK(self->_btd_arrayMutex);
    [_btd_mutableArray insertObject:anObject atIndex:index];
}

- (void)removeLastObject {
    BTD_MUTEX_LOCK(self->_btd_arrayMutex);
    [_btd_mutableArray removeLastObject];
}

- (void)removeObjectAtIndex:(NSUInteger)index {
    BTD_MUTEX_LOCK(self->_btd_arrayMutex);
    [_btd_mutableArray removeObjectAtIndex:index];
}

- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject {
    BTD_MUTEX_LOCK(self->_btd_arrayMutex);
    [_btd_mutableArray replaceObjectAtIndex:index withObject:anObject];
}

/// MARK: NSExtendedMutableArray

- (void)addObjectsFromArray:(NSArray *)otherArray {
    BTD_MUTEX_LOCK(self->_btd_arrayMutex);
    [_btd_mutableArray addObjectsFromArray:otherArray];
}

- (void)exchangeObjectAtIndex:(NSUInteger)idx1 withObjectAtIndex:(NSUInteger)idx2 {
    BTD_MUTEX_LOCK(self->_btd_arrayMutex);
    [_btd_mutableArray exchangeObjectAtIndex:idx1 withObjectAtIndex:idx2];
}

- (void)removeAllObjects {
    BTD_MUTEX_LOCK(self->_btd_arrayMutex);
    [_btd_mutableArray removeAllObjects];
}

- (void)removeObject:(id)anObject inRange:(NSRange)range {
    BTD_MUTEX_LOCK(self->_btd_arrayMutex);
    [_btd_mutableArray removeObject:anObject inRange:range];
}

- (void)removeObject:(id)anObject {
    BTD_MUTEX_LOCK(self->_btd_arrayMutex);
    [_btd_mutableArray removeObject:anObject];
}

- (void)removeObjectIdenticalTo:(id)anObject inRange:(NSRange)range {
    BTD_MUTEX_LOCK(self->_btd_arrayMutex);
    [_btd_mutableArray removeObjectIdenticalTo:anObject inRange:range];
}

- (void)removeObjectIdenticalTo:(id)anObject {
    BTD_MUTEX_LOCK(self->_btd_arrayMutex);
    [_btd_mutableArray removeObjectIdenticalTo:anObject];
}

- (void)removeObjectsInArray:(NSArray *)otherArray {
    BTD_MUTEX_LOCK(self->_btd_arrayMutex);
    [_btd_mutableArray removeObjectsInArray:otherArray];
}

- (void)removeObjectsInRange:(NSRange)range {
    BTD_MUTEX_LOCK(self->_btd_arrayMutex);
    [_btd_mutableArray removeObjectsInRange:range];
}

- (void)replaceObjectsInRange:(NSRange)range withObjectsFromArray:(NSArray *)otherArray range:(NSRange)otherRange {
    BTD_MUTEX_LOCK(self->_btd_arrayMutex);
    [_btd_mutableArray replaceObjectsInRange:range withObjectsFromArray:otherArray range:otherRange];
}

- (void)replaceObjectsInRange:(NSRange)range withObjectsFromArray:(NSArray *)otherArray {
    BTD_MUTEX_LOCK(self->_btd_arrayMutex);
    [_btd_mutableArray replaceObjectsInRange:range withObjectsFromArray:otherArray];
}

- (void)setArray:(NSArray *)otherArray {
    NSArray *copyingArray = [otherArray copy];
    BTD_MUTEX_LOCK(self->_btd_arrayMutex);
    [_btd_mutableArray setArray:copyingArray];
}

- (void)sortUsingFunction:(NSInteger (NS_NOESCAPE *)(id, id, void *))compare context:(void *)context {
    BTD_MUTEX_LOCK(self->_btd_arrayMutex);
    [_btd_mutableArray sortUsingFunction:compare context:context];
}

- (void)sortUsingSelector:(SEL)comparator {
    BTD_MUTEX_LOCK(self->_btd_arrayMutex);
    [_btd_mutableArray sortUsingSelector:comparator];
}

- (void)insertObjects:(NSArray *)objects atIndexes:(NSIndexSet *)indexes {
    BTD_MUTEX_LOCK(self->_btd_arrayMutex);
    [_btd_mutableArray insertObjects:objects atIndexes:indexes];
}

- (void)removeObjectsAtIndexes:(NSIndexSet *)indexes {
    BTD_MUTEX_LOCK(self->_btd_arrayMutex);
    [_btd_mutableArray removeObjectsAtIndexes:indexes];
}

- (void)replaceObjectsAtIndexes:(NSIndexSet *)indexes withObjects:(NSArray *)objects {
    BTD_MUTEX_LOCK(self->_btd_arrayMutex);
    [_btd_mutableArray replaceObjectsAtIndexes:indexes withObjects:objects];
}

- (void)setObject:(id)obj atIndexedSubscript:(NSUInteger)idx {
    BTD_MUTEX_LOCK(self->_btd_arrayMutex);
    [_btd_mutableArray setObject:obj atIndexedSubscript:idx];
}

- (void)sortUsingComparator:(NSComparator NS_NOESCAPE)comparator {
    BTD_MUTEX_LOCK(self->_btd_arrayMutex);
    [_btd_mutableArray sortUsingComparator:comparator];
}

- (void)sortWithOptions:(NSSortOptions)opts usingComparator:(NSComparator NS_NOESCAPE)comparator {
    BTD_MUTEX_LOCK(self->_btd_arrayMutex);
    [_btd_mutableArray sortWithOptions:opts usingComparator:comparator];
}

/// MARK: NSMutableArrayDiffing

- (void)applyDifference:(NSOrderedCollectionDifference *)difference  API_AVAILABLE(ios(13.0)){
    BTD_MUTEX_LOCK(self->_btd_arrayMutex);
    [_btd_mutableArray applyDifference:difference];
}

/// MARK: NSFastEnumeration

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state
                                  objects:(id __unsafe_unretained[])stackbuf
                                    count:(NSUInteger)len {
    BTD_MUTEX_LOCK(self->_btd_arrayMutex);NSUInteger count = [_btd_mutableArray countByEnumeratingWithState:state objects:stackbuf count:len];
    return count;
}

/// MARK: BTDAdditions

- (NSString *)btd_jsonStringEncoded {
   NSArray *copyingArray = ({
        BTD_MUTEX_LOCK(self->_btd_arrayMutex);
        [_btd_mutableArray copy];
    });
    return [copyingArray btd_jsonStringEncoded];
}

- (NSString *)btd_jsonStringEncoded:(NSError *__autoreleasing *)error {
   NSArray *copyingArray = ({
        BTD_MUTEX_LOCK(self->_btd_arrayMutex);
        [_btd_mutableArray copy];
    });
    return [copyingArray btd_jsonStringEncoded:error];
}

- (NSString *)btd_jsonStringPrettyEncoded {
   NSArray *copyingArray = ({
        BTD_MUTEX_LOCK(self->_btd_arrayMutex);
        [_btd_mutableArray copy];
    });
    return [copyingArray btd_jsonStringPrettyEncoded];
}

- (NSString *)btd_safeJsonStringEncoded {
   NSArray *copyingArray = ({
        BTD_MUTEX_LOCK(self->_btd_arrayMutex);
        [_btd_mutableArray copy];
    });
    return [copyingArray btd_safeJsonStringEncoded];
}

- (NSString *)btd_safeJsonStringEncoded:(NSError *__autoreleasing *)error {
   NSArray *copyingArray = ({
        BTD_MUTEX_LOCK(self->_btd_arrayMutex);
        [_btd_mutableArray copy];
    });
    return [copyingArray btd_safeJsonStringEncoded:error];
}

- (id)btd_objectAtIndex:(NSUInteger)index {
    BTD_MUTEX_LOCK(self->_btd_arrayMutex);
    return [_btd_mutableArray btd_objectAtIndex:index];
}

- (id)btd_objectAtIndex:(NSUInteger)index class:(Class)cls {
    BTD_MUTEX_LOCK(self->_btd_arrayMutex);
    return [_btd_mutableArray btd_objectAtIndex:index class:cls];
}

- (void)btd_forEach:(void (^)(id _Nonnull))block {
   NSArray *copyingArray = ({
        BTD_MUTEX_LOCK(self->_btd_arrayMutex);
        [_btd_mutableArray copy];
    });
    [copyingArray btd_forEach:block];
}

- (BOOL)btd_contains:(BOOL (^)(id _Nonnull))block {
   NSArray *copyingArray = ({
        BTD_MUTEX_LOCK(self->_btd_arrayMutex);
        [_btd_mutableArray copy];
    });
    return [copyingArray btd_contains:block];
}

- (BOOL)btd_all:(BOOL (^)(id _Nonnull))block {
   NSArray *copyingArray = ({
        BTD_MUTEX_LOCK(self->_btd_arrayMutex);
        [_btd_mutableArray copy];
    });
    return [copyingArray btd_all:block];
}

- (NSUInteger)btd_firstIndex:(BOOL (^)(id _Nonnull))block {
   NSArray *copyingArray = ({
        BTD_MUTEX_LOCK(self->_btd_arrayMutex);
        [_btd_mutableArray copy];
    });
    return [copyingArray btd_firstIndex:block];
}

- (id)btd_find:(BOOL (^)(id _Nonnull))block {
   NSArray *copyingArray = ({
        BTD_MUTEX_LOCK(self->_btd_arrayMutex);
        [_btd_mutableArray copy];
    });
    return [copyingArray btd_find:block];
}

- (NSArray *)btd_filter:(BOOL (^)(id _Nonnull))block {
   NSArray *copyingArray = ({
        BTD_MUTEX_LOCK(self->_btd_arrayMutex);
        [_btd_mutableArray copy];
    });
    return [copyingArray btd_filter:block];
}

- (NSArray<id> *)btd_map:(id  _Nonnull (^)(id _Nonnull))block {
   NSArray *copyingArray = ({
        BTD_MUTEX_LOCK(self->_btd_arrayMutex);
        [_btd_mutableArray copy];
    });
    return [copyingArray btd_map:block];
}

- (NSArray<id> *)btd_compactMap:(id  _Nullable (^)(id _Nonnull))block {
   NSArray *copyingArray = ({
        BTD_MUTEX_LOCK(self->_btd_arrayMutex);
        [_btd_mutableArray copy];
    });
    return [copyingArray btd_compactMap:block];
}

- (id)btd_reduce:(id)initialValue reducer:(id  _Nullable (^)(id _Nullable, id _Nonnull))block {
   NSArray *copyingArray = ({
        BTD_MUTEX_LOCK(self->_btd_arrayMutex);
        [_btd_mutableArray copy];
    });
    return [copyingArray btd_reduce:initialValue reducer:block];
}

- (NSArray *)btd_arrayByAddingObject:(id)anObject {
    BTD_MUTEX_LOCK(self->_btd_arrayMutex);
    return [_btd_mutableArray btd_arrayByAddingObject:anObject];
}

- (NSArray *)btd_arrayByAddingObjectsFromArray:(NSArray *)otherArray {
    BTD_MUTEX_LOCK(self->_btd_arrayMutex);
    return [_btd_mutableArray btd_arrayByAddingObjectsFromArray:otherArray];
}

- (NSArray *)btd_subarrayWithRange:(NSRange)range {
    BTD_MUTEX_LOCK(self->_btd_arrayMutex);NSArray *subArray = [_btd_mutableArray btd_subarrayWithRange:range];
    return subArray;
}

/// MARK: NSMutableArray BTDAdditions

- (void)btd_addObject:(id)anObject {
    BTD_MUTEX_LOCK(self->_btd_arrayMutex);
    [_btd_mutableArray btd_addObject:anObject];
}

- (void)btd_addArray:(NSArray *)objects {
    BTD_MUTEX_LOCK(self->_btd_arrayMutex);
    [_btd_mutableArray btd_addArray:objects];
}

- (void)btd_insertObject:(id)anObject atIndex:(NSUInteger)index {
    BTD_MUTEX_LOCK(self->_btd_arrayMutex);
    [_btd_mutableArray btd_insertObject:anObject atIndex:index];
}

- (void)btd_insertObjects:(NSArray *)objects atIndexes:(NSIndexSet *)indexes {
    BTD_MUTEX_LOCK(self->_btd_arrayMutex);
    [_btd_mutableArray btd_insertObjects:objects atIndexes:indexes];
}

- (void)btd_replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject {
    BTD_MUTEX_LOCK(self->_btd_arrayMutex);
    [_btd_mutableArray btd_replaceObjectAtIndex:index withObject:anObject];
}

- (void)btd_removeObject:(id)anObject {
    BTD_MUTEX_LOCK(self->_btd_arrayMutex);
    [_btd_mutableArray btd_removeObject:anObject];
}

- (void)btd_removeObjectAtIndex:(NSUInteger)index {
    BTD_MUTEX_LOCK(self->_btd_arrayMutex);
    [_btd_mutableArray btd_removeObjectAtIndex:index];
}

- (void)btd_removeObjectsInIndexes:(NSIndexSet *)indexes {
    BTD_MUTEX_LOCK(self->_btd_arrayMutex);
    [_btd_mutableArray btd_removeObjectsInIndexes:indexes];
}

- (void)btd_removeObjectsInRange:(NSRange)range {
    BTD_MUTEX_LOCK(self->_btd_arrayMutex);
    [_btd_mutableArray btd_removeObjectsInRange:range];
}

- (void)btd_exchangeObjectAtIndex:(NSUInteger)idx1 withObjectAtIndex:(NSUInteger)idx2 {
    BTD_MUTEX_LOCK(self->_btd_arrayMutex);
    [_btd_mutableArray btd_exchangeObjectAtIndex:idx1 withObjectAtIndex:idx2];
}

@end

@implementation NSArray (BTDThreadSafe)

- (NSMutableArray *)btd_threadSafe {
    if ([self isKindOfClass:[BTDThreadSafeArray class]]) {
        return [[BTDThreadSafeArray alloc] initWithArray:[self copy]];
    }
    return [[BTDThreadSafeArray alloc] initWithArray:self];
}

@end

@implementation NSMutableArray (BTDThreadSafe)

+ (NSMutableArray *)btd_threadSafeArray {
    return [[BTDThreadSafeArray alloc] init];
}

@end
