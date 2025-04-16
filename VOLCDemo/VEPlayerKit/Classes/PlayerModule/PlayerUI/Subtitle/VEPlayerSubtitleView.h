//
//  VEPlayerSubtitleView.h
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol VEPlayerSubtitleViewProtocol <NSObject>

@end

@interface VEPlayerSubtitleView : UIView <VEPlayerSubtitleViewProtocol>

@property (nonatomic, assign) CGFloat fontSize;
@property (nonatomic, copy) UIColor *textColor;
@property (nonatomic, copy) UIColor *strokeColor;

- (void)setSubtitle:(NSString *)subtitle;

@end

NS_ASSUME_NONNULL_END
