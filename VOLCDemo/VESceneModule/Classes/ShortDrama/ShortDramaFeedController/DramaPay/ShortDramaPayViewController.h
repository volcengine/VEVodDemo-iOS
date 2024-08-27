//
//  ShortDramaPayViewController.h
//  Pods
//
//  Created by zyw on 2024/7/23.
//

#import <UIKit/UIKit.h>
#import "VEDramaVideoInfoModel.h"

NS_ASSUME_NONNULL_BEGIN

extern NSString * const VEDramaPaySuccessNotification;

@protocol ShortDramaPayViewControllerDelegate <NSObject>

- (void)onPayingCallback:(VEDramaVideoInfoModel *)dramaVideoInfo;

- (void)onPaySuccessCallback:(VEDramaVideoInfoModel *)dramaVideoInfo;

- (void)onPayCancelCallback:(VEDramaVideoInfoModel *)dramaVideoInfo;

@end

@interface ShortDramaPayViewController : UIViewController

@property (nonatomic, weak) id<ShortDramaPayViewControllerDelegate> delegate;

- (void)reloadData:(VEDramaVideoInfoModel *)dramaVideoInfo;

@end

NS_ASSUME_NONNULL_END
