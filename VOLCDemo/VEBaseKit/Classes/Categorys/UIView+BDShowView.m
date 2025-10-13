//
//  UIView+BDShowView.m
//  VESceneModule
//
//  Created by zys on 2025/10/15.
//

#import "UIView+BDShowView.h"

@implementation UIView (BDShowView)

- (void)showView:(BOOL)show {
    [UIView animateWithDuration:.3f animations:^{
        self.alpha = show ? 1 : 0;
    } completion:^(BOOL finished) {
        
    }];
}

@end
