//
//  VEPlayerBaseModuleProtocol.h
//  VEPlayerKit
//

#import <Foundation/Foundation.h>
#import "VEPlayerViewLifeCycleProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@class VEPlayerContext;

@protocol VEPlayerBaseModuleProtocol <VEPlayerViewLifeCycleProtocol>

@property (nonatomic, weak) VEPlayerContext *context;

@property (nonatomic, strong) id data;

- (void)moduleDidLoad;

- (void)moduleDidUnLoad;

@end


NS_ASSUME_NONNULL_END
