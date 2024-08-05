//
//  VEPlayerContextItemHandler.h
//  VEPlayerKit
//

#import <Foundation/Foundation.h>
#import "VEPlayerContextMacros.h"

NS_ASSUME_NONNULL_BEGIN

@interface VEPlayerContextItemHandler : NSObject

@property(nonatomic, copy, readonly) NSArray<NSString *> *keys;
@property(nonatomic, copy, readonly) VEPlayerContextHandler handler;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

- (instancetype)initWithObserver:(id)observer keys:(NSArray<NSString *> *)keys handler:(VEPlayerContextHandler)handler NS_DESIGNATED_INITIALIZER;

- (void)executeHandlerWithKey:(NSString *)key andValue:(id)value;

@end

NS_ASSUME_NONNULL_END
