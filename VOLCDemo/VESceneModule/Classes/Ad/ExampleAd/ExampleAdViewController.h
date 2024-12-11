//
//  ExampleAdViewController.h
//  VESceneModule
//
//  Created by litao.he on 2024/11/7.
//

#import <UIKit/UIKit.h>
@class VEVideoModel;
@protocol VEAdActionResponderDelegate;

NS_ASSUME_NONNULL_BEGIN

@interface ExampleAdViewController : UIViewController

@property (nonatomic, strong, readonly) VEVideoModel *adModel;
@property (nonatomic, weak) id<VEAdActionResponderDelegate> delegate;

- (void)reloadData:(VEVideoModel *)adModel forAdId:(NSString*)adId andSceneType:(NSInteger)sceneType;
- (void)play;

@end

NS_ASSUME_NONNULL_END
