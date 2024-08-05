//
//  VEShortDramaVideoCellController.h
//  VOLCDemo
//

#import "VEPageViewController.h"

@import UIKit;

@class VEDramaVideoInfoModel;

@protocol VEShortDramaVideoCellControllerDelegate <NSObject>

- (void)onDramaDetailVideoPlayFinish:(VEDramaVideoInfoModel *)dramaVideoInfo;

- (void)dramaVideoWatchDetail:(VEDramaVideoInfoModel *)dramaVideoInfo;

@end

@interface VEShortDramaVideoCellController : UIViewController <VEPageItem>

@property (nonatomic, weak) id<VEShortDramaVideoCellControllerDelegate> delegate;

@property (nonatomic, strong, readonly) VEDramaVideoInfoModel *dramaVideoInfo;

- (void)reloadData:(VEDramaVideoInfoModel *)dramaVideoInfo;

@end
