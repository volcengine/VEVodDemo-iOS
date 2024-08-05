//
//  VEPlayerViewService.h
//  VEPlayerKit
//


#import <Foundation/Foundation.h>
#import "VEPlayerActionViewInterface.h"

NS_ASSUME_NONNULL_BEGIN

@class VEPlayerModuleManager;

@interface VEPlayerViewService : NSObject <VEPlayerActionViewInterface>

// weak reference module manager 
@property (nonatomic, weak, nullable) VEPlayerModuleManager *moduleManager;

@end

NS_ASSUME_NONNULL_END
