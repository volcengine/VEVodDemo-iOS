//
//  NSDictionary+BTDAdditions.h
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDictionary <KeyType, ObjectType> (BTDAdditions)
/**
 Convert a NSDictionary to a NSString. If an error happened, It would return nil.
 
 @return A NSString.
 */
- (nullable NSString *)btd_jsonStringEncoded;
- (nullable NSString *)btd_jsonStringEncoded:(NSError * _Nullable __autoreleasing * _Nullable)error;

/**
 Use NSJSONWritingPrettyPrinted to convert.

@return A NSString.
*/
- (nullable NSString *)btd_jsonStringPrettyEncoded;

/**
 Convert a NSDictionary to a NSString. It is safer but is lower in efficiency.
 
 @return A NSString.
 */
- (nullable NSString *)btd_safeJsonStringEncoded;
- (nullable NSString *)btd_safeJsonStringEncoded:(NSError * _Nullable __autoreleasing * _Nullable)error;
/*
  Many functions to get a value from a NSDictionary.
 */
- (BOOL)btd_boolValueForKey:(KeyType<NSCopying>)key;

- (int)btd_intValueForKey:(KeyType<NSCopying>)key;

- (long)btd_longValueForKey:(KeyType<NSCopying>)key;

- (long long)btd_longlongValueForKey:(KeyType<NSCopying>)key;

- (NSInteger)btd_integerValueForKey:(KeyType<NSCopying>)key;

- (NSUInteger)btd_unsignedIntegerValueForKey:(KeyType<NSCopying>)key;

- (short)btd_shortValueForKey:(KeyType<NSCopying>)key;

- (unsigned short)btd_unsignedShortValueForKey:(KeyType<NSCopying>)key;

- (float)btd_floatValueForKey:(KeyType<NSCopying>)key;

- (double)btd_doubleValueForKey:(KeyType<NSCopying>)key;

- (nullable NSNumber *)btd_numberValueForKey:(KeyType<NSCopying>)key;

- (nullable NSString *)btd_stringValueForKey:(KeyType<NSCopying>)key;

- (nullable NSArray *)btd_arrayValueForKey:(KeyType<NSCopying>)key;

- (nullable NSDictionary *)btd_dictionaryValueForKey:(KeyType<NSCopying>)key;

- (BOOL)btd_boolValueForKey:(KeyType<NSCopying>)key default:(BOOL)def;
- (char)btd_charValueForKey:(KeyType<NSCopying>)key default:(char)def;
- (unsigned char)btd_unsignedCharValueForKey:(KeyType<NSCopying>)key default:(unsigned char)def;

- (short)btd_shortValueForKey:(KeyType<NSCopying>)key default:(short)def;
- (unsigned short)btd_unsignedShortValueForKey:(KeyType<NSCopying>)key default:(unsigned short)def;

- (int)btd_intValueForKey:(KeyType<NSCopying>)key default:(int)def;
- (unsigned int)btd_unsignedIntValueForKey:(KeyType<NSCopying>)key default:(unsigned int)def;

- (long)btd_longValueForKey:(KeyType<NSCopying>)key default:(long)def;
- (unsigned long)btd_unsignedLongValueForKey:(KeyType<NSCopying>)key default:(unsigned long)def;
- (long long)btd_longLongValueForKey:(KeyType<NSCopying>)key default:(long long)def;
- (unsigned long long)btd_unsignedLongLongValueForKey:(KeyType<NSCopying>)key default:(unsigned long long)def;

- (float)btd_floatValueForKey:(KeyType<NSCopying>)key default:(float)def;
- (double)btd_doubleValueForKey:(KeyType<NSCopying>)key default:(double)def;

- (NSInteger)btd_integerValueForKey:(KeyType<NSCopying>)key default:(NSInteger)def;
- (NSUInteger)btd_unsignedIntegerValueForKey:(KeyType<NSCopying>)key default:(NSUInteger)def;

- (nullable NSNumber *)btd_numberValueForKey:(KeyType<NSCopying>)key default:(nullable NSNumber *)def;
- (nullable NSString *)btd_stringValueForKey:(KeyType<NSCopying>)key default:(nullable NSString *)def;

- (nullable NSArray *)btd_arrayValueForKey:(KeyType<NSCopying>)key default:(nullable NSArray *)def;

- (nullable NSDictionary *)btd_dictionaryValueForKey:(KeyType<NSCopying>)key default:(nullable NSDictionary *)def;

- (nullable ObjectType)btd_objectForKey:(KeyType<NSCopying>)key default:(nullable ObjectType)def;

#pragma mark - Functional

- (void)btd_forEach:(void(^)(KeyType key, ObjectType obj))block;

- (BOOL)btd_contain:(BOOL(^)(KeyType key, ObjectType obj))block;

- (BOOL)btd_all:(BOOL(^)(KeyType key, ObjectType obj))block;

- (NSDictionary<KeyType, ObjectType> *)btd_filter:(BOOL(^)(KeyType key, ObjectType obj))block;

- (NSDictionary<KeyType, id> *)btd_map:(id(^)(KeyType key, ObjectType obj))block;

- (NSDictionary<KeyType, id> *)btd_compactMap:(_Nullable id(^)(KeyType key, ObjectType obj))block;

#pragma mark - URL Query

- (nullable NSString *)btd_URLQueryString;

- (nullable NSString *)btd_URLQueryStringWithEncoding;

@end


@interface NSMutableDictionary <KeyType, ObjectType> (BTDAdditions)

#pragma mark - Safe Access

/**
 Provide safe Access for the method -(void)setObject:(ObjectType) forKey:(KeyType <NSCopying>);
 If the anObject or the key is nil, this function returns directly.
 */
- (void)btd_setObject:(_Nullable ObjectType)anObject forKey:(_Nullable KeyType<NSCopying>)key;

@end

@interface NSDictionary<KeyType, ObjectType> (BTDThreadSafe)

/**
 @summary
 Create a thread-safe NSMutableDictionary based on the original dictionary.
 
 @warning  ⚠️⚠️⚠️
 TAll APIs of the NSMutableDictionary returned by `btd_threadSafe` are thread-safe. But if you use non-atomic operations such as `for-in` to access the dictionary, these operations are not thread-safe. We recommend using the `-btd_forEach:` to traverse the dictionary.
 */
- (NSMutableDictionary<KeyType, ObjectType> *)btd_threadSafe;

@end

@interface NSMutableDictionary <KeyType, ObjectType> (BTDThreadSafe)

/**
 @summary
 Create a thread-safe NSMutableDictionary.
 
 @warning  ⚠️⚠️⚠️
 All APIs of the NSMutableDictionary returned by `btd_threadSafeDictionary` are thread-safe. But if you use non-atomic operations such as `for-in` to access the dictionary, these operations are not thread-safe. We recommend using the `-btd_forEach:` to traverse the dictionary.
 */
+ (NSMutableDictionary<KeyType, ObjectType> *)btd_threadSafeDictionary;

@end

NS_ASSUME_NONNULL_END
