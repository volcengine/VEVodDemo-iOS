//
//  ShortDramaSpeedTipView.h
//  VEPlayModule
//
//  Created by zyw on 2024/7/16.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#define ShortDramaSpeedTipViewViewWidth 120
#define ShortDramaSpeedTipViewViewHeight 40

@interface ShortDramaSpeedTipView : UIView

- (void)showSpeedView:(NSString *)tip;

- (void)hiddenSpeedView;

@end

NS_ASSUME_NONNULL_END
