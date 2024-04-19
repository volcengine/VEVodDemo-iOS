//
//  VEShortDramaDetailVideoCellController.h
//  VEPlayModule
//

#import <UIKit/UIKit.h>
#import "VEPageViewController.h"

NS_ASSUME_NONNULL_BEGIN

@class VEDramaVideoInfoModel;

@protocol VEShortDramaDetailVideoCellControllerDelegate <NSObject>

- (void)onClickDramaSelectionCallback:(VEDramaVideoInfoModel *)dramaVideoInfo;

- (void)dramaVideoPlayFinish:(VEDramaVideoInfoModel *)dramaVideoInfo;

@end

@interface VEShortDramaDetailVideoCellController : UIViewController <VEPageItem>

@property (nonatomic, weak) id<VEShortDramaDetailVideoCellControllerDelegate> delegate;
@property (nonatomic, strong) VEDramaVideoInfoModel *dramaVideoInfo;

@end

NS_ASSUME_NONNULL_END
