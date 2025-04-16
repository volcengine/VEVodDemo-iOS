//
//  VEMediaCellFactory.h
//  VESceneModule
//
//  Created by litao.he on 2024/11/15.
//

#import <Foundation/Foundation.h>
#import "VEPageViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface VEMediaCellFactory : NSObject

+ (UIViewController<VEPageItem> *)createCellViewControllerByMediaModel:(id)mediaModel pageViewController:(VEPageViewController*)pageViewController cellDelegate:(id)cellDelegate adDelegate:(id)adDelegate adRespDelegate:(id)adRespDelegate andSceneType:(NSInteger)sceneType;

@end

NS_ASSUME_NONNULL_END
