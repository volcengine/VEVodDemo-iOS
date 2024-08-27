//
//  VEPlayerActionView.m
//  VEPlayerKit
//

#import "VEPlayerActionView.h"
#import "NSArray+BTDAdditions.h"
#import "VEPlayerControlViewDefine.h"

@interface VEPlayerActionView ()

@property (nonatomic, strong) NSMutableArray *orderedSubviews;

@end

@implementation VEPlayerActionView

#pragma mark - Public Mehtod

- (void)addPlayerControlView:(VEPlayerControlView * _Nullable)controlView viewType:(VEPlayerControlViewType)viewType {
    if (!controlView || [self viewWithTag:viewType]) {
        return;
    }

    controlView.tag = viewType;
    if (self.orderedSubviews.count) {
        BOOL flag = NO;
        for (UIView *targetView in self.orderedSubviews) {
            if (viewType < targetView.tag) {
                [self insertSubview:controlView belowSubview:targetView];
                [self.orderedSubviews btd_insertObject:controlView atIndex:0];
                flag = YES;
                break;
            }
        }
        if (!flag) {
            [self addSubview:controlView];
            [self.orderedSubviews btd_addObject:controlView];
        }
    } else {
        [self addSubview:controlView];
        [self.orderedSubviews btd_addObject:controlView];
    }
}

- (void)removePlayerControlView:(VEPlayerControlViewType)viewType {
    VEPlayerControlView *controlView = [self viewWithTag:viewType];
    if (controlView) {
        [controlView removeFromSuperview];
        controlView = nil;
    }
}

- (VEPlayerControlView * _Nullable)getPlayerControlView:(VEPlayerControlViewType)viewType {
    VEPlayerControlView *controlView = [self viewWithTag:viewType];
    return controlView;
}

#pragma mark - Setter & Getter
- (NSMutableArray *)orderedSubviews {
    if (!_orderedSubviews) {
        _orderedSubviews = [NSMutableArray array];
    }
    return _orderedSubviews;
}

@end
