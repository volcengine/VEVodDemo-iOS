//
//  VEPlayerGestureWrapper.h
//  VEPlayerKit
//


#import <Foundation/Foundation.h>
#import "VEPlayerInteractionDefine.h"

NS_ASSUME_NONNULL_BEGIN

@protocol VEPlayerGestureHandlerProtocol;

@interface VEPlayerGestureWrapper : NSObject

@property (nonatomic, strong, readonly) UIGestureRecognizer *gestureRecognizer;

@property (nonatomic, assign, readonly) VEGestureType gestureType;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer gestureType:(VEGestureType)gestureType NS_DESIGNATED_INITIALIZER;

- (void)addGestureHandler:(id<VEPlayerGestureHandlerProtocol>)handler;

- (void)removeGestureHandler:(id<VEPlayerGestureHandlerProtocol>)handler;

@end

NS_ASSUME_NONNULL_END
