//
//  VEShortDramaVideoCellController.h
//  VOLCDemo
//

#import "VEPageViewController.h"

@import UIKit;

@class VEDramaVideoInfoModel;

@interface VEShortDramaVideoCellController : UIViewController <VEPageItem>

@property (nonatomic, strong) VEDramaVideoInfoModel *videoModel;

@end
