//
//  VEPlayerGestureService.h
//  VEPlayerKit
//

#import <Foundation/Foundation.h>
#import "VEPlayerGestureServiceInterface.h"
#import "VEPlayerInteractionDefine.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * @locale zh
 * @type api
 * @brief 手势管理 service，请参考VEPlayerContext的DI接口获取该服务
 */
@interface VEPlayerGestureService : NSObject <VEPlayerGestureServiceInterface>

@property (nonatomic, strong) UIView *gestureView;

@end

NS_ASSUME_NONNULL_END
