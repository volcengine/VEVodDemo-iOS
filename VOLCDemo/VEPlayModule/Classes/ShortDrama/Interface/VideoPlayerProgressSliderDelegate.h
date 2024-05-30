//
//  VideoPlayerProgressSliderDelegate.h
//  Pods
//

@protocol VideoPlayerProgressSliderDelegate <NSObject>

@optional
- (void)progressWillChangeStart;

- (void)progressValueChanging:(CGFloat)value;
- (void)progressValueChanging:(NSInteger)curPlayTime duration:(NSInteger)duration;

- (void)progressValueChanged:(CGFloat)value;

@end


