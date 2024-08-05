//
//  VEPlayerContextItem.h
//  VEPlayerKit
//

#import <Foundation/Foundation.h>
#import "VEPlayerContextMacros.h"
#import "VEPlayerContextItemHandler.h"

NS_ASSUME_NONNULL_BEGIN

@interface VEPlayerContextItem : NSObject

@property (nonatomic, copy, readwrite, nonnull) NSString *key;

@property (nonatomic, strong, readwrite, nullable) id object;

- (void)addHandler:(VEPlayerContextItemHandler *)handler;

- (void)removeHandler:(VEPlayerContextItemHandler *)handler;
- (void)removeAllHandler;

- (void)notify:(id)value;

@end

NS_ASSUME_NONNULL_END
