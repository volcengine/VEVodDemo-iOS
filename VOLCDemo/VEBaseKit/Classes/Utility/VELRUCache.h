//
//  VELRUCache.h
//  VEBaseKit
//
//  Created by zyw on 2024/10/10.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VELRUCache : NSObject

// default capacity 200
+ (VELRUCache *)shareInstance;

- (instancetype)initWithCapacity:(NSUInteger)capacity;

- (id)getValueForKey:(id)key;

- (void)setValue:(id)value forKey:(id)key;

@end

NS_ASSUME_NONNULL_END
