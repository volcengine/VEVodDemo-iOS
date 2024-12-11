//
//  VEAdsCellController.h
//  VESceneModule
//
//  Created by litao.he on 2024/11/6.
//

@import UIKit;
#import "VEPageViewController.h"
#import "Data/Model/VEAdInfoModel.h"

@protocol VEAdManagerDelegate;
@protocol VEAdActionResponderDelegate;

@interface VEAdCellController : UIViewController <VEPageItem>

@property (nonatomic, weak) id<VEAdManagerDelegate> adDelegate;
@property (nonatomic, weak) id<VEAdActionResponderDelegate> responderDelegate;
@property (nonatomic, assign) NSInteger hostSceneType; // 1 短剧剧场，2 短剧推荐
@property (nonatomic, strong, nonnull, readonly) VEAdInfoModel* adInfoModel;

-(void)loadAd:(VEAdInfoModel* _Nonnull)adInfoModel;

@end
