//
//  VEPlayerGestureServiceInterface.h
//  VEPlayerKit
//

#ifndef VEPlayerGestureServiceInterface_h
#define VEPlayerGestureServiceInterface_h

#import "VEPlayerInteractionDefine.h"
#import "VEPlayerGestureHandlerProtocol.h"

@protocol VEPlayerGestureServiceInterface <NSObject>

@property (nonatomic, strong) UIView *gestureView;

/**
 * @locale zh
 * @type api
 * @brief 添加handler，响应指定手势类型
 * @param handler 手势处理器
 * @param gestureType 手势类型，可选多个手势类型
 */
- (void)addGestureHandler:(id<VEPlayerGestureHandlerProtocol>)handler forType:(VEGestureType)gestureType;

/**
 * @locale zh
 * @type api
 * @brief 删除handler，只针对指定手势类型
 * @param handler 手势处理器
 * @param gestureType 手势类型，可选多个手势类型
 */
- (void)removeGestureHandler:(id<VEPlayerGestureHandlerProtocol>)handler forType:(VEGestureType)gestureType;

/**
 * @locale zh
 * @type api
 * @brief 便利方法：删除handler，gestureType = VEGestureTypeAll
 * @param handler 手势处理器
 */
- (void)removeGestureHandler:(id<VEPlayerGestureHandlerProtocol>)handler;

/**
 * @locale zh
 * @type api
 * @brief 便利方法：屏蔽指定手势类型
 * @param gestureType 手势类型，可选多个手势类型
 * @param scene 场景信息，方便异常调试
 */
- (id<VEPlayerGestureHandlerProtocol>)disableGestureType:(VEGestureType)gestureType scene:(NSString *)scene;

@end

#endif /* VEPlayerGestureServiceInterface_h */
