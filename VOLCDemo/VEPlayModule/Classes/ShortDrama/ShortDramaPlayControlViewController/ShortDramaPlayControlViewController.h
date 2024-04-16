//
//  ShortDramaPlayControlViewController.h
//  JSONModel
//

#import <UIKit/UIKit.h>
#import "VideoPlayerControlViewControllerInterface.h"

NS_ASSUME_NONNULL_BEGIN

@class VEVideoPlayerController;

@interface ShortDramaPlayControlViewController : UIViewController <VideoPlayerControlViewControllerInterface>

- (instancetype)initWithVideoPlayerController:(VEVideoPlayerController *)playerController;

@end

NS_ASSUME_NONNULL_END
