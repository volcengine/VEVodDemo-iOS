//
//  VEInterfaceArea.m
//  VEPlayerUIModule
//
//  Created by real on 2021/9/25.
//

#import "VEInterfaceArea.h"
#import "VEEventConst.h"
#import "VEInterfaceElementDescription.h"

NSString *const VEUIEventScreenRotation = @"VEUIEventScreenRotation";

NSString *const VEUIEventScreenLockStateChanged = @"VEUIEventScreenLockStateChanged";

NSString *const VEUIEventPageBack = @"VEUIEventPageBack";

NSString *const VEUIEventLockScreen = @"VEUIEventLockScreen";

NSString *const VEUIEventClearScreen = @"VEUIEventClearScreen";

@implementation VEInterfaceArea

- (instancetype)initWithElements:(NSArray<id<VEInterfaceElementDescription>> *)elements {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.clipsToBounds = YES;
//        [self _registEvents];
        [self layoutElements:elements];
    }
    return self;
}


#pragma mark ----- Layout

- (void)invalidateLayout {
    
}

- (void)layoutElements:(NSArray<id<VEInterfaceElementDescription>> *)elements {
    
}


#pragma mark ----- Hidden behavior

- (BOOL)isEnableZone:(CGPoint)point {
    if (self.hidden) {
        return NO;
    }
    for (UIView *subview in self.subviews) {
        if (subview.elementDescription) {
            if (CGRectContainsPoint(subview.frame, point)) {
                return YES;
            }
        }
    }
    return NO;
}

- (void)show:(BOOL)show animated:(BOOL)animated {
    if (animated) {
        if (show) {
            if (!self.hidden) return;
            [UIView animateWithDuration:0.3 animations:^{
                self.alpha = 0.0;
            } completion:^(BOOL finished) {
                self.hidden = YES;
                self.alpha = 1.0;
            }];
        } else {
            if (self.hidden) return;
            self.alpha = 0.0;
            self.hidden = NO;
            [UIView animateWithDuration:0.3 animations:^{
                self.alpha = 1.0;
            }];
        }
    } else {
        self.hidden = !show;
    }
}

#pragma mark ----- Message / Action

//- (void)_registEvents {
//    [[VEEventMessageBus universalBus] registEvent:VEUIEventScreenClearStateChanged withAction:@selector(screenAction) ofTarget:self];
//    [[VEEventMessageBus universalBus] registEvent:VEUIEventScreenLockStateChanged withAction:@selector(screenAction) ofTarget:self];
//}
//
//- (void)screenAction {
//    BOOL screenIsClear = [[VEEventPoster currentPoster] screenIsClear];
//    BOOL screenIsLocking = [[VEEventPoster currentPoster] screenIsLocking];
//    if (screenIsLocking) {
//        [self show:NO animated:NO];
//    } else {
//        [self show:!screenIsClear animated:NO];
//    }
//}

@end

