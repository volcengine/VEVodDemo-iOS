//
//  VEShortVideoProgressSlider.h
//  VEPlayerUIModule
//

#import "VEVideoPlayback.h"
#import "VideoPlayerProgressSliderDelegate.h"
#import "VideoPlayerControlItemInterface.h"

typedef NS_ENUM(NSInteger, VEProgressSliderContentMode) {
    VEProgressSliderContentModeCenter = 0,
    VEProgressSliderContentModeTop,
    VEProgressSliderContentModeBottom
};

@interface VEShortVideoProgressSlider : UIView <VideoPlayerControlItemInterface>

@property (nonatomic, weak) id<VideoPlayerProgressSliderDelegate> delegate;
@property (nonatomic, weak) id<VEVideoPlayback> player;

- (instancetype)initWithContentMode:(VEProgressSliderContentMode)contentMode;

@property (nonatomic, assign) CGFloat progressValue;
@property (nonatomic, assign) CGFloat bufferValue;

@property (nonatomic, assign) CGFloat sliderCoefficient; // Default 3，[1-10]
@property (nonatomic, assign) VEProgressSliderContentMode contentMode;

@property (nonatomic, strong) UIColor *progressColor;
@property (nonatomic, strong) UIColor *progressBufferColor;
@property (nonatomic, strong) UIColor *progressBackgroundColor;

@property (nonatomic, assign) NSInteger thumbOffset;
@property (nonatomic, assign) NSInteger thumbHeight;
@property (nonatomic, strong) UIImage *thumbImage;
@property (nonatomic, strong) UIImage *thumbTouchImage;

@end
