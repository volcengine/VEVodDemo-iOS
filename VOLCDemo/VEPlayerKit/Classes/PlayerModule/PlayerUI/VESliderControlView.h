//
//  VESliderControlView.h
//  VEPlayerUIModule
//

#import "VEVideoPlayback.h"

typedef NS_ENUM(NSInteger, VESliderControlViewContentMode) {
    VESliderControlViewContentModeCenter = 0,
    VESliderControlViewContentModeTop,
    VESliderControlViewContentModeBottom
};

@class VESliderControlView;

@protocol VESliderControlViewDelegate <NSObject>

- (void)progressBeginSlideChange:(VESliderControlView *)sliderControlView;

- (void)progressSliding:(VESliderControlView *)sliderControlView value:(CGFloat)value;

- (void)progressDidEndSlide:(VESliderControlView *)sliderControlView value:(CGFloat)value;

- (void)progressSlideCancel:(VESliderControlView *)sliderControlView;

@end

@interface VESliderControlView : UIView

@property (nonatomic, weak) id<VESliderControlViewDelegate> delegate;

- (instancetype)initWithContentMode:(VESliderControlViewContentMode)contentMode;

@property (nonatomic, assign) CGFloat progressValue;
@property (nonatomic, assign) CGFloat bufferValue;

@property (nonatomic, assign) CGFloat sliderCoefficient; // Default 3，[1-10]
@property (nonatomic, assign) VESliderControlViewContentMode contentMode;

@property (nonatomic, strong) UIColor *progressColor;
@property (nonatomic, strong) UIColor *progressBufferColor;
@property (nonatomic, strong) UIColor *progressBackgroundColor;

@property (nonatomic, assign) NSInteger thumbOffset;
@property (nonatomic, assign) NSInteger thumbHeight;
@property (nonatomic, strong) UIImage *thumbImage;
@property (nonatomic, strong) UIImage *thumbTouchImage;

@property (nonatomic, assign) CGSize extendTouchSize;

@end
