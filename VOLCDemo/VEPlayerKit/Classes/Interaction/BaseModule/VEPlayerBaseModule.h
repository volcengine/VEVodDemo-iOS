//
//  VEPlayerBaseModule.h
//  VEPlayerKit
//

#import <Foundation/Foundation.h>
#import "VEPlayerBaseModuleProtocol.h"
#import "VEPlayerContext.h"

NS_ASSUME_NONNULL_BEGIN

@interface VEPlayerBaseModule : NSObject <VEPlayerBaseModuleProtocol>

@property (nonatomic, weak) VEPlayerContext *context;

@property (nonatomic, strong) id data;

@property (nonatomic, assign, readonly) BOOL isLoaded;

@property (nonatomic, assign, readonly) BOOL isViewLoaded;

@end

NS_ASSUME_NONNULL_END
