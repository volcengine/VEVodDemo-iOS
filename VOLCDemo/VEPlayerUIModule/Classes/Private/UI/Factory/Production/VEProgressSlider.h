//
//  VEProgressSlider.h
//  VEPlayerUIModule
//
//  Created by real on 2021/11/18.
//

@protocol VEProgressSliderDelegate <NSObject>

- (void)progressManualChanged:(CGFloat)value;

@end

@interface VEProgressSlider : UIView

@property (nonatomic, weak) id<VEProgressSliderDelegate> delegate;

@property (nonatomic, assign) CGFloat progressValue;

@property (nonatomic, assign) CGFloat bufferValue;

- (void)setThumbImage:(UIImage *)image;

- (void)setProgressColor:(UIColor *)color;

- (void)setProgressBufferColor:(UIColor *)color;

- (void)setProgressBackgroundColor:(UIColor *)color;

@end
