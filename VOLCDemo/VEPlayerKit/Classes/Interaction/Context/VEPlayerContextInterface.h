//
//  VEPlayerContextInterface.h
//  VEPlayerKit
//

#ifndef VEPlayerContextInterface_h
#define VEPlayerContextInterface_h

#import <Foundation/Foundation.h>
#import "VEPlayerContextMacros.h"

NS_ASSUME_NONNULL_BEGIN

@protocol VEPlayerContextHandler <NSObject>

/**
 * @locale zh
 * @type api
 * @brief 通过key来监听change，返回的id可以使用removeHandler来移除handler
 * @param key key
 * @param observer 监听者（可以通过observer来移除所有相关的handler）
 * @param handler Change回调
 */
- (nullable id)addKey:(nonnull NSString *)key withObserver:(id)observer handler:(nullable VEPlayerContextHandler)handler;

/**
 * @locale zh
 * @type api
 * @brief 增加通过Key数组来监听来监听change，返回的id可以使用removeHandler来移除handler
 * @param keys 监听Keys
 * @param observer 监听者（可以通过observer来移除所有相关的handler）
 * @param handler Change回调
 */
- (nullable id)addKeys:(nonnull NSArray<NSString *> *)keys withObserver:(id)observer handler:(nullable VEPlayerContextHandler)handler;

/**
 * @locale zh
 * @type api
 * @brief 移除handler
 * @param handler 通过添加handler是返回的对象来移除监听
 */
- (void)removeHandler:(id)handler;

/**
 * @locale zh
 * @type api
 * @brief 移除该observer所有相关的handler（正常情况下不用调用该方法，observer销毁时会自动移除）
 * @param observer 监听者
 */
- (void)removeHandlersForObserver:(id)observer;

/**
 * @locale zh
 * @type api
 * @brief 移除所有监听
 */
- (void)removeAllHandler;

/**
 * @locale zh
 * @type api
 * @brief 主动通知对象发生了改变
 * @param object 改变的对象
 * @param key 监听的key
 */
- (void)post:(nullable id)object forKey:(nonnull NSString *)key;

@end

@protocol VEPlayerContextHandlerAdditions <NSObject>

- (nullable id)objectForHandlerKey:(nonnull NSString *)key;
- (nullable NSString *)stringForHandlerKey:(nonnull NSString *)key;
- (nullable NSDictionary *)dictionaryForHandlerKey:(nonnull NSString *)key;
- (nullable NSArray *)arrayForHandlerKey:(nonnull NSString *)key;
- (BOOL)boolForHandlerKey:(nonnull NSString *)key;
- (NSInteger)integerForHandlerKey:(nonnull NSString *)key;
- (float)floatForHandlerKey:(nonnull NSString *)key;
- (double)doubleForHandlerKey:(nonnull NSString *)key;

@end

NS_ASSUME_NONNULL_END

#endif /* VEPlayerContextInterface_h */
