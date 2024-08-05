//
//  NSSet+BTDAdditions.h
//  Pods
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSSet <ObjectType> (BTDAdditions)

#pragma mark - Functional

- (void)btd_forEach:(void(^)(ObjectType obj))block;

- (BOOL)btd_contains:(BOOL(^)(ObjectType obj))block;

- (BOOL)btd_all:(BOOL(^)(ObjectType obj))block;

- (nullable ObjectType)btd_find:(BOOL(^)(ObjectType obj))block;

- (NSSet<ObjectType> *)btd_filter:(BOOL(^)(ObjectType obj))block;

- (NSSet<id> *)btd_map:(id(^)(ObjectType obj))block;

- (NSSet<id> *)btd_compactMap:(_Nullable id(^)(ObjectType obj))block;

- (nullable id)btd_reduce:(nullable id)initialValue reducer:(_Nullable id(^)(_Nullable id preValue, ObjectType obj))block;

@end


@interface NSMutableSet <ObjectType> (BTDAdditions)

#pragma mark - Safe Operation

- (void)btd_addObject:(ObjectType)object;

- (void)btd_removeObject:(ObjectType)object;

@end

@interface NSSet<ObjectType> (BTDThreadSafe)

/**
 @summary
 Create a thread-safe NSMutableSet based on the original set.
 
 @warning  ⚠️⚠️⚠️
 All APIs of the NSMutableSet returned by `btd_threadSafe` are thread-safe. But if you use non-atomic operations such as `for-in` to access the set, these operations are not thread-safe. We recommend using the `-btd_forEach:` to traverse the set.
 */
- (NSMutableSet<ObjectType> *)btd_threadSafe;

@end

@interface NSMutableSet <ObjectType> (BTDThreadSafe)

/**
 @summary
 Create a thread-safe NSMutableSet.
 
 @warning  ⚠️⚠️⚠️
 All APIs of the NSMutableSet returned by `btd_threadSafeSet` are thread-safe. But if you use non-atomic operations such as `for-in` to access the set, these operations are not thread-safe. We recommend using the `-btd_forEach:` to traverse the set.
 */
+ (NSMutableSet<ObjectType> *)btd_threadSafeSet;

@end

NS_ASSUME_NONNULL_END
