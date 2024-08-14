//
//  VEPlayerInteraction.h
//  VEPlayerKit
//

#import <Foundation/Foundation.h>
#import "VEPlayerViewLifeCycleProtocol.h"
#import "VEPlayerModuleManagerInterface.h"

NS_ASSUME_NONNULL_BEGIN

@protocol VEPlayerViewLifeCycleProtocol;

@protocol VEPlayerInteractionPlayerProtocol <VEPlayerViewLifeCycleProtocol, VEPlayerModuleManagerInterface>

@end

@class VEPlayerContext;

@interface VEPlayerInteraction : NSObject <VEPlayerInteractionPlayerProtocol>

@property (nonatomic, weak) UIView *playerContainerView;
@property (nonatomic, weak) UIView *playerVCView;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithContext:(VEPlayerContext *)context NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
