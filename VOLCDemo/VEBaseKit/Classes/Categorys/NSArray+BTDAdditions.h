//
//  NSArray+BTDAdditions.h
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSArray <__covariant ObjectType> (BTDAdditions)
/**
Convert a NSArray to a NSString. If an error happened, it would return nil.

 @return A NSString instance.
 */
- (nullable NSString *)btd_jsonStringEncoded;
- (nullable NSString *)btd_jsonStringEncoded:(NSError * _Nullable __autoreleasing * _Nullable)error;

/**
 Use NSJSONWritingPrettyPrinted to convert.

 @return A NSString instance.
 */
- (nullable NSString *)btd_jsonStringPrettyEncoded;

/**
 Convert a NSArray to a NSString. It is safer but lower in efficiency.

 @return A NSString instance.
 */
- (nullable NSString *)btd_safeJsonStringEncoded;
- (nullable NSString *)btd_safeJsonStringEncoded:(NSError * _Nullable __autoreleasing * _Nullable)error;

#pragma mark - Safe Access

- (nullable ObjectType)btd_objectAtIndex:(NSUInteger)index;

- (nullable ObjectType)btd_objectAtIndex:(NSUInteger)index class:(Class)cls;

#pragma mark - Functional

- (void)btd_forEach:(void(^)(ObjectType obj))block;

- (BOOL)btd_contains:(BOOL(^)(ObjectType obj))block;

- (BOOL)btd_all:(BOOL(^)(ObjectType obj))block;

- (NSUInteger)btd_firstIndex:(BOOL(^)(ObjectType obj))block;

- (nullable ObjectType)btd_find:(BOOL(^)(ObjectType obj))block;

- (NSArray<ObjectType> *)btd_filter:(BOOL(^)(ObjectType obj))block;

- (NSArray<id> *)btd_map:(id(^)(ObjectType obj))block;

- (NSArray<id> *)btd_compactMap:(id _Nullable (^)(ObjectType obj))block;

- (nullable id)btd_reduce:(nullable id)initialValue reducer:(_Nullable id(^)(_Nullable id preValue, ObjectType obj))block;

/**
 @param anObject If anObject is nil, this method will returns a copy of the receiving array.
 @return Returns a new array that is a copy of the receiving array with a given object added to the end.
 */
- (NSArray<ObjectType> *)btd_arrayByAddingObject:(nullable ObjectType)anObject;

/**
 @param otherArray If otherArray is nil, this method will returns a copy of the receiving array.
 @return Returns a new array that is a copy of the receiving array with the objects contained in another array added to the end
 */
- (NSArray<ObjectType> *)btd_arrayByAddingObjectsFromArray:(nullable NSArray<ObjectType> *)otherArray;

/**
 Returns a new array containing the receiving array’s elements that fall within the limits specified by a given range. If range's location is greater than the range's count or range's length is equal to zero, @[] will be returned. If the right bound of range exceeds the receiver, range will be truncated to the end of the receiver.
 */

- (NSArray<ObjectType> *)btd_subarrayWithRange:(NSRange)range;

@end

@interface NSMutableArray <ObjectType> (BTDAdditions)

#pragma mark - Safe Operation

- (void)btd_addObject:(ObjectType)anObject;

- (void)btd_addArray:(NSArray<ObjectType> *)objects;

- (void)btd_insertObject:(ObjectType)anObject atIndex:(NSUInteger)index;

- (void)btd_insertObjects:(NSArray<ObjectType> *)objects atIndexes:(NSIndexSet *)indexes;

- (void)btd_replaceObjectAtIndex:(NSUInteger)index withObject:(ObjectType)anObject;

- (void)btd_removeObject:(ObjectType)anObject;

- (void)btd_removeObjectAtIndex:(NSUInteger)index;

- (void)btd_removeObjectsInIndexes:(NSIndexSet *)indexes;

/**
 Removes from the array each of the objects within a given range.
 @param range If range's location is greater than the range's count, this method will do nothing. If the right bound of range exceeds the receiver, range will be truncated to the end of the receiver.
 */
- (void)btd_removeObjectsInRange:(NSRange)range;

- (void)btd_exchangeObjectAtIndex:(NSUInteger)idx1 withObjectAtIndex:(NSUInteger)idx2;

@end

@interface NSArray <__covariant ObjectType> (BTDThreadSafe)

/**
 @summary
 Create a thread-safe NSMutableArray based on the original array.
 
 @warning  ⚠️⚠️⚠️
 All APIs of the NSMutableArray returned by `btd_threadSafe` are thread-safe. But if you use non-atomic operations such as `for-in` to access the array, these operations are not thread-safe. We recommend using the `-btd_forEach:` to traverse the array.
 */
- (NSMutableArray<ObjectType> *)btd_threadSafe;

@end

@interface NSMutableArray <ObjectType> (BTDThreadSafe)

/**
 @summary
 Create a thread-safe NSMutableArray.
 
 @warning  ⚠️⚠️⚠️
 All APIs of the NSMutableArray returned by `btd_threadSafeArray` are thread-safe. But if you use non-atomic operations such as `for-in` to access the array, these operations are not thread-safe. We recommend using the `-btd_forEach:` to traverse the array.
 */
+ (NSMutableArray<ObjectType> *)btd_threadSafeArray;

@end

NS_ASSUME_NONNULL_END
