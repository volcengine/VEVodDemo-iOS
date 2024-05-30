//
//  ShortDramaSelectionViewController.h
//  VEPlayModule
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class VEDramaVideoInfoModel;

@protocol ShortDramaSelectionViewControllerDelegate <NSObject>

- (void)onDramaSelectionCallback:(VEDramaVideoInfoModel *)dramaVideoInfo;

@end

@interface ShortDramaSelectionViewController : UIViewController

@property (nonatomic, weak) id<ShortDramaSelectionViewControllerDelegate> delegate;

- (instancetype)initWtihDramaVideoInfo:(VEDramaVideoInfoModel *)dramaVideoInfo;

@end

NS_ASSUME_NONNULL_END
