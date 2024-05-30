//
//  ShortDramaPlayControlViewController.h
//  JSONModel
//

#import <UIKit/UIKit.h>
#import "VideoPlayerControlViewControllerInterface.h"

NS_ASSUME_NONNULL_BEGIN

@class VEVideoPlayerController;

@protocol ShortDramaPlayControlViewControllerDelegate <NSObject>

- (void)shortDramaPlayControlViewClickWatchDetail;

@end

@interface ShortDramaPlayControlViewController : UIViewController <VideoPlayerControlViewControllerInterface>

@property (nonatomic, weak) id<ShortDramaPlayControlViewControllerDelegate> delegate;

- (instancetype)initWithVideoPlayerController:(VEVideoPlayerController *)playerController;

@end

NS_ASSUME_NONNULL_END
