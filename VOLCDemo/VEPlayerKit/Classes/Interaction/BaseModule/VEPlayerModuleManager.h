//
//  VEPlayerModuleManager.h
//  VEPlayerKit
//

#import <Foundation/Foundation.h>
#import "VEPlayerViewLifeCycleProtocol.h"
#import "VEPlayerModuleManagerInterface.h"

NS_ASSUME_NONNULL_BEGIN

@class VEPlayerContext;

@interface VEPlayerModuleManager : NSObject<
VEPlayerViewLifeCycleProtocol,
VEPlayerModuleManagerInterface
>

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithPlayerContext:(VEPlayerContext *)playerContext NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
