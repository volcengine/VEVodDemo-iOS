//
//  ShortDramaVideoProgressView.h
//  VEPlayModule
//

#import <UIKit/UIKit.h>
#import "VEShortVideoProgressSlider.h"
#import "VideoPlayerControlViewControllerInterface.h"
#import "VideoPlayerControlItemInterface.h"

NS_ASSUME_NONNULL_BEGIN

#define ShortDramaVideoProgressViewHeight 30

@interface ShortDramaVideoProgressView : UIView <VideoPlayerProgressSliderDelegate, VideoPlayerControlItemInterface>

@property (nonatomic, weak) id<VideoPlayerControlViewControllerInterface> playControlDelegate;

@end

NS_ASSUME_NONNULL_END
