//
//  VEPlayerControlView.m
//  VEPlayerKit
//

#import "VEPlayerControlView.h"

@interface VEPlayerControlView()


@end

@implementation VEPlayerControlView

#pragma mark - Life Cycle
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hitTestView = [super hitTest:point withEvent:event];
    if (hitTestView == self) {
        return nil;
    }
    return hitTestView;
}


@end
