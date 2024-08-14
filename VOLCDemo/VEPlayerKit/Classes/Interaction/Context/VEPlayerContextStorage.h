//
//  VEPlayerContextStorage.h
//  VEPlayerKit
//

#import <Foundation/Foundation.h>
#import "VEPlayerContextMacros.h"

NS_ASSUME_NONNULL_BEGIN

@class VEPlayerContextItem;

@interface VEPlayerContextStorage : NSObject

/// should cache object in memory, defaults to yes
@property (nonatomic, assign) BOOL enableCache;

- (nullable id)objectForKey:(nonnull NSString *)key;
- (nullable id)objectForKey:(nonnull NSString *)key creator:(nullable VEPlayerContextObjectCreator)creator;
- (nonnull VEPlayerContextItem *)contextItemForKey:(nonnull NSString *)key;
- (nullable VEPlayerContextItem *)contextItemForKey:(nonnull NSString *)key creator:(nullable VEPlayerContextObjectCreator)creator;
- (nullable id)setObject:(id)object forKey:(nonnull NSString *)key;
- (void)removeObjectForKey:(nonnull NSString *)key;
- (void)removeAllObject;

@end
 
NS_ASSUME_NONNULL_END
