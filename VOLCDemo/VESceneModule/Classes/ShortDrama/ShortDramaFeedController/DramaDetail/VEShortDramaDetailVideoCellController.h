//
//  VEShortDramaDetailVideoCellController.h
//  VEPlayModule
//

#import <UIKit/UIKit.h>
#import "VEPageViewController.h"
#import "VEVideoPlayerController.h"

NS_ASSUME_NONNULL_BEGIN

@class VEDramaVideoInfoModel;

@protocol VEShortDramaDetailVideoCellControllerDelegate <NSObject>

- (void)onClickDramaSelectionCallback:(VEDramaVideoInfoModel *)dramaVideoInfo;

- (void)onDramaDetailVideoPlayFinish:(VEDramaVideoInfoModel *)dramaVideoInfo;

- (void)onDramaDetailVideoPlayStart:(VEDramaVideoInfoModel *)dramaVideoInfo;

@end

@interface VEShortDramaDetailVideoCellController : UIViewController <VEPageItem>

@property (nonatomic, weak) id<VEShortDramaDetailVideoCellControllerDelegate> delegate;
@property (nonatomic, strong, readonly) VEDramaVideoInfoModel *dramaVideoInfo;
@property (nonatomic, strong) VEVideoPlayerController *playerController;
@property (nonatomic, assign) BOOL continuePlay;

- (void)reloadData:(VEDramaVideoInfoModel *)dramaVideoInfo;

- (void)recordPlaybackTime;

@end

NS_ASSUME_NONNULL_END
