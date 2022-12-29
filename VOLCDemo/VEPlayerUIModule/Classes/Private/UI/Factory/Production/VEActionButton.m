//
//  VEActionButton.m
//  VEPlayerUIModule
//
//  Created by real on 2021/11/9.
//

#import "VEActionButton.h"
#import "VEInterfaceElementDescription.h"
#import "UIView+VEElementDescripition.h"
#import "VEEventConst.h"

@implementation VEActionButton

- (void)layoutSubviews {
    [super layoutSubviews];
    [self setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
}


#pragma mark ----- VEInterfaceFactoryProduction

- (void)elementViewAction {
    [self addTarget:self action:@selector(touchUpInsideAction:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)touchUpInsideAction:(UIControl *)sender {
    if (sender.elementDescription.elementAction) {
        NSString *eventKey = sender.elementDescription.elementAction(sender);
        if ([eventKey isKindOfClass:[NSString class]]) {
            [[VEEventMessageBus universalBus] postEvent:eventKey withObject:nil rightNow:YES];
        } else if ([eventKey isKindOfClass:[NSDictionary class]]) {
            NSDictionary *eventDic = (NSDictionary *)eventKey;
            [[VEEventMessageBus universalBus] postEvent:eventDic.allKeys.firstObject withObject:eventDic.allValues.firstObject rightNow:YES];
        }
    }
}

- (void)elementViewEventNotify:(id)param {
    if ([param isKindOfClass:[NSDictionary class]]) {
        NSDictionary *paramDic = (NSDictionary *)param;
        if (self.elementDescription.elementNotify) {
            self.elementDescription.elementNotify(self, [[paramDic allKeys] firstObject], [[paramDic allValues] firstObject]);
        }
    }
}

- (BOOL)isEnableZone:(CGPoint)point {
    if (self.hidden) {
        return NO;
    }
    if (CGRectContainsPoint(self.frame, point)) {
        return YES;
    }
    return NO;
}

@end
