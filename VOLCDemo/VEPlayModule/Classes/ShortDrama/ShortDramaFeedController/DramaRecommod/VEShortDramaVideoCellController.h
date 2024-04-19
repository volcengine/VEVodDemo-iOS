//
//  VEShortDramaVideoCellController.h
//  VOLCDemo
//

#import "VEPageViewController.h"

@import UIKit;

@class VEDramaVideoInfoModel;

@protocol VEShortDramaVideoCellControllerDelegate <NSObject>

- (void)dramaVideoPlayFinish:(VEDramaVideoInfoModel *)dramaVideoInfo;

@end

@interface VEShortDramaVideoCellController : UIViewController <VEPageItem>

@property (nonatomic, weak) id<VEShortDramaVideoCellControllerDelegate> delegate;

@property (nonatomic, strong) VEDramaVideoInfoModel *dramaVideoInfo;

@end
