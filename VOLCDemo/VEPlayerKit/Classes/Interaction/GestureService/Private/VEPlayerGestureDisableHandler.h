//
//  VEPlayerGestureDisableHandler.h
//  VEPlayerKit
//


#import <Foundation/Foundation.h>
#import "VEPlayerGestureHandlerProtocol.h"

NS_ASSUME_NONNULL_BEGIN

/// 专门用于屏蔽指定手势类型
@interface VEPlayerGestureDisableHandler : NSObject <VEPlayerGestureHandlerProtocol>

@property (nonatomic, assign, readonly) VEGestureType gestureType;
@property (nonatomic, copy, readonly) NSString *scene;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithGestureType:(VEGestureType)gestureType scene:(NSString *)scene NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
