//
//  VEShortDramaDetailFeedViewController.h
//  VEPlayModule
//

#import <UIKit/UIKit.h>
#import "VEViewController.h"

NS_ASSUME_NONNULL_BEGIN

@class VEDramaVideoInfoModel;
@class VEDramaInfoModel;

@interface VEShortDramaDetailFeedViewController : VEViewController

- (instancetype)initWtihDramaVideoInfo:(VEDramaVideoInfoModel *)dramaVideoInfo;

- (instancetype)initWtihDramaInfo:(VEDramaInfoModel *)dramaInfo;

@end

NS_ASSUME_NONNULL_END
