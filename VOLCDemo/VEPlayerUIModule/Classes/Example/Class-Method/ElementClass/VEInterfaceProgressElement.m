//
//  VEInterfaceProgressElement.m
//  VEPlayerUIModule
//
//  Created by real on 2022/1/7.
//

#import "VEInterfaceProgressElement.h"
#import "VEPlayerUIModule.h"
#import "Masonry.h"

NSString *const progressViewId = @"progressViewId";

NSString *const progressGestureId = @"progressGestureId";

@implementation VEInterfaceProgressElement

@synthesize elementID;
@synthesize type;

#pragma mark ----- VEInterfaceElementProtocol

- (id)elementAction:(id)mayElementView {
    if ([mayElementView isKindOfClass:[VEProgressView class]]) {
        VEProgressView *progressView = (VEProgressView *)mayElementView;
        return @{VEPlayEventSeek : @(progressView.currentValue)};
    } else {
        return VEPlayEventProgressValueIncrease;
    }
}

- (void)elementNotify:(id)mayElementView :(NSString *)key :(id)obj {
    if ([mayElementView isKindOfClass:[VEProgressView class]]) {
        VEProgressView *progressView = (VEProgressView *)mayElementView;
        BOOL screenIsClear = [[VEEventPoster currentPoster] screenIsClear];
        BOOL screenIsLocking = [[VEEventPoster currentPoster] screenIsLocking];
        if ([key isEqualToString:VEPlayEventTimeIntervalChanged]) {
            if ([obj isKindOfClass:[NSNumber class]]) {
                NSTimeInterval interval = [((NSNumber *)obj) doubleValue];
                progressView.totalValue = [[VEEventPoster currentPoster] duration];
                progressView.currentValue = interval;
                progressView.bufferValue = [[VEEventPoster currentPoster] playableDuration];
            };
        } else if ([key isEqualToString:VEUIEventScreenClearStateChanged]) {
            progressView.hidden = screenIsLocking ?: screenIsClear;
        } else if ([key isEqualToString:VEUIEventScreenLockStateChanged]) {
            progressView.hidden = screenIsLocking;
        }
    }
}

- (id)elementSubscribe:(id)mayElementView {
    return @[VEPlayEventTimeIntervalChanged, VEUIEventScreenClearStateChanged, VEUIEventScreenLockStateChanged];
}

- (void)elementWillLayout:(UIView *)elementView :(NSSet<UIView *> *)elementGroup :(UIView *)groupContainer {
    VEProgressView *progressView = (VEProgressView *)elementView;
    progressView.currentOrientation = UIInterfaceOrientationPortrait;
    [elementView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(groupContainer).offset(12.0);
        make.bottom.equalTo(groupContainer).offset(-50.0);
        make.trailing.equalTo(groupContainer).offset(-12.0);
        make.height.equalTo(@50.0);
    }];
}


#pragma mark ----- Element output

+ (VEInterfaceElementDescriptionImp *)progressView {
    @autoreleasepool {
        VEInterfaceProgressElement *element = [VEInterfaceProgressElement new];
        element.type = VEInterfaceElementTypeProgressView;
        element.elementID = progressViewId;
        return element.elementDescription;
    }
}

+ (VEInterfaceElementDescriptionImp *)progressGesture {
    @autoreleasepool {
        VEInterfaceProgressElement *element = [VEInterfaceProgressElement new];
        element.type = VEInterfaceElementTypeGestureHorizontalPan;
        element.elementID = progressGestureId;
        return element.elementDescription;
    }
}

@end
