//
//  NSDictionary+BTDAdditions.m
//

#import "NSDictionary+BTDAdditions.h"
#import "NSObject+BTDAdditions.h"
#import "NSString+BTDAdditions.h"
#import "BTDMacros.h"

#define RETURN_VALUE(_type_, _key_, _def_)                                                     \
if (!_key_) return _def_;                                                            \
id value = self[_key_];                                                            \
if (!value || value == [NSNull null]) return _def_;                                \
if ([value isKindOfClass:[NSNumber class]]) return ((NSNumber *)value)._type_;   \
if ([value isKindOfClass:[NSString class]]) return NSNumberFromID(value)._type_; \
return _def_;

@implementation NSDictionary (BTDAdditions)

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

- (NSString *)btd_safeJsonStringEncoded
{
    id object = [self btd_safeJsonObject];
    if ([object isKindOfClass:[NSDictionary class]]) {
        return [object btd_jsonStringEncoded];
    }
    return nil;
}

- (NSString *)btd_safeJsonStringEncoded:(NSError *__autoreleasing *)error
{
    id object = [self btd_safeJsonObject];
    if ([object isKindOfClass:[NSDictionary class]]) {
        return [object btd_jsonStringEncoded:error];
    }
    return nil;
}

- (id)btd_safeJsonObject
{
    NSMutableDictionary *safeEncodingDict = [NSMutableDictionary dictionary];
    for (NSString *key in [(NSDictionary *)self allKeys]) {
        id object = [self valueForKey:key];
        safeEncodingDict[key] = [object btd_safeJsonObject];
    }
    return safeEncodingDict.copy;
}

/// Get a number value from 'id'.
static NSNumber *NSNumberFromID(id value) {
    if (!value || value == [NSNull null]) return nil;
    if ([value isKindOfClass:[NSNumber class]]) return value;
    if ([value isKindOfClass:[NSString class]]) {
        NSString *lower = ((NSString *)value).lowercaseString;
        if ([lower isEqualToString:@"true"] || [lower isEqualToString:@"yes"]) return @(YES);
        if ([lower isEqualToString:@"false"] || [lower isEqualToString:@"no"]) return @(NO);
        if ([lower isEqualToString:@"nil"] || [lower isEqualToString:@"null"]) return nil;
        if ([(NSString *)value containsString:@"."]) {
            return @(((NSString *)value).doubleValue);
        } else {
            return @(((NSString *)value).longLongValue);
        }
    }
    return nil;
}

- (BOOL)btd_boolValueForKey:(id<NSCopying>)key {
    return [self btd_boolValueForKey:key default:NO];
}

- (int)btd_intValueForKey:(id<NSCopying>)key {
    return [self btd_intValueForKey:key default:0];
}

- (long)btd_longValueForKey:(id<NSCopying>)key {
    return [self btd_longValueForKey:key default:0];
}

- (long long)btd_longlongValueForKey:(id<NSCopying>)key {
    return [self btd_longLongValueForKey:key default:0];
}

- (NSInteger)btd_integerValueForKey:(id<NSCopying>)key {
    return [self btd_integerValueForKey:key default:0];
}

- (NSUInteger)btd_unsignedIntegerValueForKey:(id<NSCopying>)key {
    return [self btd_unsignedIntegerValueForKey:key default:0];
}

- (short)btd_shortValueForKey:(id<NSCopying>)key {
    return [self btd_shortValueForKey:key default:0];
}

- (unsigned short)btd_unsignedShortValueForKey:(id<NSCopying>)key {
    return [self btd_unsignedShortValueForKey:key default:0];
}

- (float)btd_floatValueForKey:(id<NSCopying>)key {
    return [self btd_floatValueForKey:key default:0.0];
}

- (double)btd_doubleValueForKey:(id<NSCopying>)key {
    return [self btd_doubleValueForKey:key default:0.0];
}

- (NSNumber *)btd_numberValueForKey:(id<NSCopying>)key {
    return [self btd_numberValueForKey:key default:nil];
}

- (NSString *)btd_stringValueForKey:(id<NSCopying>)key {
    return [self btd_stringValueForKey:key default:nil];
}

- (nullable NSArray *)btd_arrayValueForKey:(id<NSCopying>)key {
    return [self btd_arrayValueForKey:key default:nil];
}

- (nullable NSDictionary *)btd_dictionaryValueForKey:(id<NSCopying>)key {
    return [self btd_dictionaryValueForKey:key default:nil];
}

- (BOOL)btd_boolValueForKey:(id<NSCopying>)key default:(BOOL)def {
    RETURN_VALUE(boolValue,key,def);
}

- (char)btd_charValueForKey:(id<NSCopying>)key default:(char)def {
    RETURN_VALUE(charValue,key,def);
}

- (unsigned char)btd_unsignedCharValueForKey:(id<NSCopying>)key default:(unsigned char)def {
    RETURN_VALUE(unsignedCharValue,key,def);
}

- (short)btd_shortValueForKey:(id<NSCopying>)key default:(short)def {
    RETURN_VALUE(shortValue,key,def);
}

- (unsigned short)btd_unsignedShortValueForKey:(id<NSCopying>)key default:(unsigned short)def {
    RETURN_VALUE(unsignedShortValue,key,def);
}

- (int)btd_intValueForKey:(id<NSCopying>)key default:(int)def {
    RETURN_VALUE(intValue,key,def);
}

- (unsigned int)btd_unsignedIntValueForKey:(id<NSCopying>)key default:(unsigned int)def {
    RETURN_VALUE(unsignedIntValue,key,def);
}

- (long)btd_longValueForKey:(id<NSCopying>)key default:(long)def {
    RETURN_VALUE(longValue,key,def);
}

- (unsigned long)btd_unsignedLongValueForKey:(id<NSCopying>)key default:(unsigned long)def {
    RETURN_VALUE(unsignedLongValue,key,def);
}

- (long long)btd_longLongValueForKey:(id<NSCopying>)key default:(long long)def {
    RETURN_VALUE(longLongValue,key,def);
}

- (unsigned long long)btd_unsignedLongLongValueForKey:(id<NSCopying>)key default:(unsigned long long)def {
    RETURN_VALUE(unsignedLongLongValue,key,def);
}

- (float)btd_floatValueForKey:(id<NSCopying>)key default:(float)def {
    RETURN_VALUE(floatValue,key,def);
}

- (double)btd_doubleValueForKey:(id<NSCopying>)key default:(double)def {
    RETURN_VALUE(doubleValue,key,def);
}

- (NSInteger)btd_integerValueForKey:(id<NSCopying>)key default:(NSInteger)def {
    RETURN_VALUE(integerValue,key,def);
}

- (NSUInteger)btd_unsignedIntegerValueForKey:(id<NSCopying>)key default:(NSUInteger)def {
    RETURN_VALUE(unsignedIntegerValue,key,def);
}

- (NSNumber *)btd_numberValueForKey:(id<NSCopying>)key default:(NSNumber *)def {
    if (!key) return def;
    id value = self[key];
    if (!value || value == [NSNull null]) return def;
    if ([value isKindOfClass:[NSNumber class]]) return value;
    if ([value isKindOfClass:[NSString class]]) return NSNumberFromID(value);
    return def;
}

- (NSString *)btd_stringValueForKey:(id<NSCopying>)key default:(NSString *)def {
    if (!key) return def;
    id value = self[key];
    if (!value || value == [NSNull null]) return def;
    if ([value isKindOfClass:[NSString class]]) return value;
    if ([value isKindOfClass:[NSNumber class]]) return ((NSNumber *)value).description;
    return def;
}

- (NSArray *)btd_arrayValueForKey:(id<NSCopying>)key default:(NSArray *)def {
    if (key == nil) {
        return def;
    }
    id value = self[key];
    if ([value isKindOfClass:[NSArray class]]) {
        return value;
    }
    return def;
}

- (NSDictionary *)btd_dictionaryValueForKey:(id<NSCopying>)key default:(NSDictionary *)def {
    if (key == nil) {
        return def;
    }
    id value = self[key];
    if ([value isKindOfClass:[NSDictionary class]]) {
        return value;
    }
    return def;
}

- (id)btd_objectForKey:(id<NSCopying>)key default:(id)def {
    if (key == nil) {
        return def;
    }
    id value = self[key];
    return value ? : def;
}

- (void)btd_forEach:(void (^)(id _Nonnull, id _Nonnull))block {
    NSParameterAssert(block != nil);
    [self enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        block(key, obj);
    }];
}

- (BOOL)btd_contain:(BOOL (^)(id _Nonnull, id _Nonnull))block {
    NSParameterAssert(block != nil);
    __block BOOL result = NO;
    [self enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if (block(key, obj)) {
            result = YES;
            *stop = YES;
        }
    }];
    return result;
}

- (BOOL)btd_all:(BOOL (^)(id _Nonnull, id _Nonnull))block {
    NSParameterAssert(block != nil);
    __block BOOL result = YES;
    [self enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if (!block(key, obj)) {
            result = NO;
            *stop = YES;
        }
    }];
    return result;
}

- (NSDictionary *)btd_filter:(BOOL (^)(id _Nonnull, id _Nonnull))block {
    NSParameterAssert(block != nil);
    NSMutableDictionary *result = [NSMutableDictionary dictionaryWithCapacity:self.count];
    [self enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if (block(key, obj)) {
            result[key] = obj;
        }
    }];
    return [result copy];
}

- (NSDictionary *)btd_map:(id  _Nullable (^)(id _Nonnull, id _Nonnull))block {
    NSParameterAssert(block != nil);
    NSMutableDictionary *result = [NSMutableDictionary dictionaryWithCapacity:self.count];
    [self enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        id mapped = block(key, obj);
        NSAssert(mapped != nil, @"Fatal error: unexpectedly found nil while mapping to a nonnull value.");
        result[key] = mapped ?: [NSNull null];
    }];
    return [result copy];
}

- (NSDictionary *)btd_compactMap:(id  _Nullable (^)(id _Nonnull, id _Nonnull))block {
    NSParameterAssert(block != nil);
    NSMutableDictionary *result = [NSMutableDictionary dictionaryWithCapacity:self.count];
    [self enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        result[key] = block(key, obj);
    }];
    return [result copy];
}

- (NSString *)btd_URLQueryString {
    NSMutableArray<NSString *> *items = [NSMutableArray arrayWithCapacity:self.count];
    [self btd_forEach:^(id  _Nonnull key, id  _Nonnull value) {
        [items addObject:[NSString stringWithFormat:@"%@=%@", key, value]];
    }];
    return [items componentsJoinedByString:@"&"];
}

- (NSString *)btd_URLQueryStringWithEncoding {
    NSMutableArray<NSString *> *items = [NSMutableArray arrayWithCapacity:self.count];
    [self btd_forEach:^(id  _Nonnull key, id  _Nonnull value) {
        NSString *encodedKey = [[NSString stringWithFormat:@"%@", key] btd_stringByURLEncode];
        NSString *encodedValue = [[NSString stringWithFormat:@"%@", value] btd_stringByURLEncode];
        if (encodedKey && encodedValue) {
            [items addObject:[NSString stringWithFormat:@"%@=%@", encodedKey, encodedValue]];
        }
    }];
    return [items componentsJoinedByString:@"&"];
}

@end


@implementation NSMutableDictionary (BTDAdditions)

- (void)btd_setObject:(id)anObject forKey:(id<NSCopying>)key {
    if (key != nil && anObject != nil) {
        [self setObject:anObject forKey:key];
    }
}

@end

@interface BTDThreadSafeDictionary<KeyType, ObjectType> : NSMutableDictionary

@property (nonatomic, strong) NSMutableDictionary<KeyType, ObjectType> *btd_mutableDict;

@end

@implementation BTDThreadSafeDictionary {
    pthread_mutex_t _btd_dictMutex;
}

/// MARK: init

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupMutex];
        _btd_mutableDict = [NSMutableDictionary dictionary];
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)otherDictionary {
    self = [super init];
    if (self) {
        [self setupMutex];
        _btd_mutableDict = [[NSMutableDictionary alloc] initWithDictionary:otherDictionary];
    }
    return self;
}

- (instancetype)initWithCapacity:(NSUInteger)numItems {
    self = [super init];
    if (self) {
        [self setupMutex];
        _btd_mutableDict = [[NSMutableDictionary alloc] initWithCapacity:numItems];
    }
    return self;
}

/// MARK: NSCoding

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self setupMutex];
        _btd_mutableDict = [coder decodeObjectForKey:@"btd_mutableDict"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    BTD_MUTEX_LOCK(self->_btd_dictMutex);
    [coder encodeObject:_btd_mutableDict forKey:@"btd_mutableDict"];
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
    pthread_mutex_destroy(&_btd_dictMutex);
    pthread_mutexattr_t mutexAttribute;
    pthread_mutexattr_init(&mutexAttribute);
    pthread_mutexattr_settype(&mutexAttribute, PTHREAD_MUTEX_RECURSIVE);
    pthread_mutex_init(&_btd_dictMutex, &mutexAttribute);
    pthread_mutexattr_destroy(&mutexAttribute);
}


/// MARK: dealloc

- (void)dealloc {
    pthread_mutex_destroy(&_btd_dictMutex);
}

/// MARK: Equal && hash

- (BOOL)isEqualToDictionary:(NSDictionary *)otherDictionary {
    if (otherDictionary == self) return YES;
    NSDictionary *copyingDict = ({
        BTD_MUTEX_LOCK(self->_btd_dictMutex);
        [_btd_mutableDict copy];
    });
    return [copyingDict isEqualToDictionary:otherDictionary.copy];
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:NSDictionary.class]) return NO;
    return [self isEqualToDictionary:object];
}

- (NSUInteger)hash {
    BTD_MUTEX_LOCK(self->_btd_dictMutex);
    return [_btd_mutableDict hash];
}

/// MARK: NSCopying

- (id)copyWithZone:(NSZone *)zone {
    BTD_MUTEX_LOCK(self->_btd_dictMutex);
    return [_btd_mutableDict copy];
}

/// MARK: NSMutableCopying

- (id)mutableCopyWithZone:(NSZone *)zone {
    NSDictionary *copyingDict = ({
        BTD_MUTEX_LOCK(self->_btd_dictMutex);
        [_btd_mutableDict copy];
    });
    return [[BTDThreadSafeDictionary alloc] initWithDictionary:copyingDict];
}


/// MARK: NSDictionary method

- (NSUInteger)count {
    BTD_MUTEX_LOCK(self->_btd_dictMutex);
    return [_btd_mutableDict count];
}

- (id)objectForKey:(id)aKey {
    BTD_MUTEX_LOCK(self->_btd_dictMutex);
    return [_btd_mutableDict objectForKey:aKey];
}

- (NSEnumerator *)keyEnumerator {
    NSDictionary *copyingDict = ({
        BTD_MUTEX_LOCK(self->_btd_dictMutex);
        [_btd_mutableDict copy];
    });
    return [copyingDict keyEnumerator];
}

/// MARK: NSExtendedDictionary

- (NSArray *)allKeys {
    BTD_MUTEX_LOCK(self->_btd_dictMutex);
    return [_btd_mutableDict allKeys];
}

- (NSArray *)allKeysForObject:(id)anObject {
    BTD_MUTEX_LOCK(self->_btd_dictMutex);
    return [_btd_mutableDict allKeysForObject:anObject];
}

- (NSArray *)allValues {
    BTD_MUTEX_LOCK(self->_btd_dictMutex);
    return [_btd_mutableDict allValues];
}

- (NSString *)description {
    BTD_MUTEX_LOCK(self->_btd_dictMutex);
    return [_btd_mutableDict description];
}

- (NSString *)descriptionInStringsFileFormat {
    BTD_MUTEX_LOCK(self->_btd_dictMutex);
    return [_btd_mutableDict descriptionInStringsFileFormat];
}

- (NSString *)descriptionWithLocale:(id)locale {
    BTD_MUTEX_LOCK(self->_btd_dictMutex);
    return [_btd_mutableDict descriptionWithLocale:locale];
}

- (NSString *)descriptionWithLocale:(id)locale indent:(NSUInteger)level {
    BTD_MUTEX_LOCK(self->_btd_dictMutex);
    return [_btd_mutableDict descriptionWithLocale:locale indent:level];
}

- (NSEnumerator *)objectEnumerator {
    NSDictionary *copyingDict = ({
        BTD_MUTEX_LOCK(self->_btd_dictMutex);
        [_btd_mutableDict copy];
    });
    return [copyingDict objectEnumerator];
}

- (NSArray *)objectsForKeys:(NSArray *)keys notFoundMarker:(id)marker {
    NSDictionary *copyingDict = ({
        BTD_MUTEX_LOCK(self->_btd_dictMutex);
        [_btd_mutableDict copy];
    });
    return [copyingDict objectsForKeys:keys notFoundMarker:marker];
}

- (BOOL)writeToURL:(NSURL *)url error:(NSError *__autoreleasing  _Nullable *)error {
    BTD_MUTEX_LOCK(self->_btd_dictMutex);
    return [_btd_mutableDict writeToURL:url error:error];
}

- (NSArray *)keysSortedByValueUsingSelector:(SEL)comparator {
    NSDictionary *copyingDict = ({
        BTD_MUTEX_LOCK(self->_btd_dictMutex);
        [_btd_mutableDict copy];
    });
    return [copyingDict keysSortedByValueUsingSelector:comparator];
}

- (void)getObjects:(__unsafe_unretained id _Nonnull[])objects andKeys:(__unsafe_unretained id _Nonnull[])keys count:(NSUInteger)count {
    BTD_MUTEX_LOCK(self->_btd_dictMutex);
    [_btd_mutableDict getObjects:objects andKeys:keys count:count];
}

- (id)objectForKeyedSubscript:(id)key {
    BTD_MUTEX_LOCK(self->_btd_dictMutex);
    return [_btd_mutableDict objectForKeyedSubscript:key];
}

- (void)enumerateKeysAndObjectsUsingBlock:(void (NS_NOESCAPE ^)(id _Nonnull, id _Nonnull, BOOL * _Nonnull))block {
    NSDictionary *copyingDict = ({
        BTD_MUTEX_LOCK(self->_btd_dictMutex);
        [_btd_mutableDict copy];
    });
    [copyingDict enumerateKeysAndObjectsUsingBlock:block];
}

- (void)enumerateKeysAndObjectsWithOptions:(NSEnumerationOptions)opts usingBlock:(void (NS_NOESCAPE ^)(id _Nonnull, id _Nonnull, BOOL * _Nonnull))block {
    NSDictionary *copyingDict = ({
        BTD_MUTEX_LOCK(self->_btd_dictMutex);
        [_btd_mutableDict copy];
    });
    [copyingDict enumerateKeysAndObjectsWithOptions:opts usingBlock:block];
}

- (NSArray *)keysSortedByValueUsingComparator:(NS_NOESCAPE NSComparator)cmptr {
    NSDictionary *copyingDict = ({
        BTD_MUTEX_LOCK(self->_btd_dictMutex);
        [_btd_mutableDict copy];
    });
    return [copyingDict keysSortedByValueUsingComparator:cmptr];
}

- (NSArray *)keysSortedByValueWithOptions:(NSSortOptions)opts usingComparator:(NS_NOESCAPE NSComparator)cmptr {
    NSDictionary *copyingDict = ({
        BTD_MUTEX_LOCK(self->_btd_dictMutex);
        [_btd_mutableDict copy];
    });
    return [copyingDict keysSortedByValueWithOptions:opts usingComparator:cmptr];
}

- (NSSet *)keysOfEntriesPassingTest:(BOOL (NS_NOESCAPE ^)(id _Nonnull, id _Nonnull, BOOL * _Nonnull))predicate {
    NSDictionary *copyingDict = ({
        BTD_MUTEX_LOCK(self->_btd_dictMutex);
        [_btd_mutableDict copy];
    });
    return [copyingDict keysOfEntriesPassingTest:predicate];
}

- (NSSet *)keysOfEntriesWithOptions:(NSEnumerationOptions)opts passingTest:(BOOL (NS_NOESCAPE ^)(id _Nonnull, id _Nonnull, BOOL * _Nonnull))predicate {
    NSDictionary *copyingDict = ({
        BTD_MUTEX_LOCK(self->_btd_dictMutex);
        [_btd_mutableDict copy];
    });
    return [copyingDict keysOfEntriesWithOptions:opts passingTest:predicate];
}

/// MARK: Mutable dictionary

- (void)removeObjectForKey:(id)aKey {
    BTD_MUTEX_LOCK(self->_btd_dictMutex);
    [_btd_mutableDict removeObjectForKey:aKey];
}

- (void)setObject:(id)anObject forKey:(id<NSCopying>)aKey {
    BTD_MUTEX_LOCK(self->_btd_dictMutex);
    [_btd_mutableDict setObject:anObject forKey:aKey];
}

/// MARK: NSExtendedMutableDictionary

- (void)addEntriesFromDictionary:(NSDictionary *)otherDictionary {
    BTD_MUTEX_LOCK(self->_btd_dictMutex);
    [_btd_mutableDict addEntriesFromDictionary:otherDictionary];
}

- (void)removeAllObjects {
    BTD_MUTEX_LOCK(self->_btd_dictMutex);
    [_btd_mutableDict removeAllObjects];
}

- (void)removeObjectsForKeys:(NSArray *)keyArray {
    BTD_MUTEX_LOCK(self->_btd_dictMutex);
    [_btd_mutableDict removeObjectsForKeys:keyArray];
}

- (void)setDictionary:(NSDictionary *)otherDictionary {
    NSDictionary *copyingDict = otherDictionary.copy;
    BTD_MUTEX_LOCK(self->_btd_dictMutex);
    [_btd_mutableDict setDictionary:copyingDict];
}

- (void)setObject:(id)obj forKeyedSubscript:(id<NSCopying>)key {
    BTD_MUTEX_LOCK(self->_btd_dictMutex);
    [_btd_mutableDict setObject:obj forKeyedSubscript:key];
}

/// MARK: NSFastEnumeration

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(__unsafe_unretained id _Nullable[])buffer count:(NSUInteger)len {
    NSDictionary *copyingDict = ({
        BTD_MUTEX_LOCK(self->_btd_dictMutex);
        [_btd_mutableDict copy];
    });
    return [copyingDict countByEnumeratingWithState:state objects:buffer count:len];
}

/// MARK: BTDAdditions

- (NSString *)btd_jsonStringEncoded {
    NSDictionary *copyingDict = ({
        BTD_MUTEX_LOCK(self->_btd_dictMutex);
        [_btd_mutableDict copy];
    });
    return [copyingDict btd_jsonStringEncoded];
}

- (NSString *)btd_jsonStringEncoded:(NSError *__autoreleasing *)error {
    NSDictionary *copyingDict = ({
        BTD_MUTEX_LOCK(self->_btd_dictMutex);
        [_btd_mutableDict copy];
    });
    return [copyingDict btd_jsonStringEncoded:error];
}

- (NSString *)btd_jsonStringPrettyEncoded {
    NSDictionary *copyingDict = ({
        BTD_MUTEX_LOCK(self->_btd_dictMutex);
        [_btd_mutableDict copy];
    });
    return [copyingDict btd_jsonStringPrettyEncoded];
}

- (NSString *)btd_safeJsonStringEncoded {
    NSDictionary *copyingDict = ({
        BTD_MUTEX_LOCK(self->_btd_dictMutex);
        [_btd_mutableDict copy];
    });
    return [copyingDict btd_safeJsonStringEncoded];
}

- (NSString *)btd_safeJsonStringEncoded:(NSError *__autoreleasing *)error {
    NSDictionary *copyingDict = ({
        BTD_MUTEX_LOCK(self->_btd_dictMutex);
        [_btd_mutableDict copy];
    });
    return [copyingDict btd_safeJsonStringEncoded:error];
}

- (void)btd_forEach:(void (^)(id _Nonnull, id _Nonnull))block {
    NSDictionary *copyingDict = ({
        BTD_MUTEX_LOCK(self->_btd_dictMutex);
        [_btd_mutableDict copy];
    });
    [copyingDict btd_forEach:block];
}

- (BOOL)btd_contain:(BOOL (^)(id _Nonnull, id _Nonnull))block {
    NSDictionary *copyingDict = ({
        BTD_MUTEX_LOCK(self->_btd_dictMutex);
        [_btd_mutableDict copy];
    });
    return [copyingDict btd_contain:block];
}

- (BOOL)btd_all:(BOOL (^)(id _Nonnull, id _Nonnull))block {
    NSDictionary *copyingDict = ({
        BTD_MUTEX_LOCK(self->_btd_dictMutex);
        [_btd_mutableDict copy];
    });
    return [copyingDict btd_all:block];
}

- (NSDictionary *)btd_filter:(BOOL (^)(id _Nonnull, id _Nonnull))block {
    NSDictionary *copyingDict = ({
        BTD_MUTEX_LOCK(self->_btd_dictMutex);
        [_btd_mutableDict copy];
    });
    return [copyingDict btd_filter:block];
}

- (NSDictionary *)btd_map:(id  _Nullable (^)(id _Nonnull, id _Nonnull))block {
    NSDictionary *copyingDict = ({
        BTD_MUTEX_LOCK(self->_btd_dictMutex);
        [_btd_mutableDict copy];
    });
    return [copyingDict btd_map:block];
}

- (NSDictionary *)btd_compactMap:(id  _Nullable (^)(id _Nonnull, id _Nonnull))block {
    NSDictionary *copyingDict = ({
        BTD_MUTEX_LOCK(self->_btd_dictMutex);
        [_btd_mutableDict copy];
    });
    return [copyingDict btd_compactMap:block];
}

- (NSString *)btd_URLQueryString {
    NSDictionary *copyingDict = ({
        BTD_MUTEX_LOCK(self->_btd_dictMutex);
        [_btd_mutableDict copy];
    });
    return [copyingDict btd_URLQueryString];
}

- (NSString *)btd_URLQueryStringWithEncoding {
    NSDictionary *copyingDict = ({
        BTD_MUTEX_LOCK(self->_btd_dictMutex);
        [_btd_mutableDict copy];
    });
    return [copyingDict btd_URLQueryStringWithEncoding];
}

- (void)btd_setObject:(id)anObject forKey:(id<NSCopying>)key {
    BTD_MUTEX_LOCK(self->_btd_dictMutex);
    [_btd_mutableDict btd_setObject:anObject forKey:key];
}

@end

@implementation NSDictionary (BTDThreadSafe)

- (NSMutableDictionary *)btd_threadSafe {
    if ([self isKindOfClass:[BTDThreadSafeDictionary class]]) {
        return [[BTDThreadSafeDictionary alloc] initWithDictionary:[self copy]];
    }
    return [[BTDThreadSafeDictionary alloc] initWithDictionary:self];
}

@end

@implementation NSMutableDictionary (BTDThreadSafe)

+ (NSMutableDictionary *)btd_threadSafeDictionary {
    return [[BTDThreadSafeDictionary alloc] init];
}

@end
