//
//  VELongVideoSliderControlView.h
//  VESceneModule
//
//  Created by zys on 2025/10/15.
//

#import <UIKit/UIKit.h>
#import "VESliderControlView.h"

NS_ASSUME_NONNULL_BEGIN

@interface VELongVideoSliderControlView : UIView

@property (nonatomic, weak) id<VESliderControlViewDelegate> delegate;

- (instancetype)initWithContentMode:(VESliderControlViewContentMode)contentMode;

@property (nonatomic, assign) CGFloat progressValue;
@property (nonatomic, assign) CGFloat bufferValue;
@property (nonatomic, assign) CGFloat totalDutation;

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

- (void)updateCustomViewsWithOri:(UIDeviceOrientation)ori;

@end

NS_ASSUME_NONNULL_END
