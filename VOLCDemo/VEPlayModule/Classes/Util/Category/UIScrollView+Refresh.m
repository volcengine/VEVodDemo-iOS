//
//  UIScrollView+Refresh.m
//  VOLCDemo
//
//  Created by real on 2022/8/29.
//  Copyright © 2022 ByteDance. All rights reserved.
//

#import "UIScrollView+Refresh.h"
#import <objc/runtime.h>
#import <Masonry/Masonry.h>

@interface UIScrollView ()

@property (nonatomic, strong) void(^refreshHandler)(void);

@end

@implementation UIScrollView (Refresh)

+ (void)load{
    Method originalMethod = class_getInstanceMethod([self class], NSSelectorFromString(@"handlePan:"));
    Method swizzledMethod = class_getInstanceMethod([self class], @selector(customPanGesture:));
    method_exchangeImplementations(originalMethod, swizzledMethod);
}

- (void (^)(void))refreshHandler{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setRefreshHandler:(void (^)(void))refreshHandler {
    objc_setAssociatedObject(self, @selector(refreshHandler), refreshHandler, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)veLoading {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setVeLoading:(BOOL)veLoading {
    objc_setAssociatedObject(self, @selector(veLoading), @(veLoading), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)systemRefresh:(void (^)(void))handler {
    if (@available(iOS 10.0, *)) {
        self.refreshControl = [UIRefreshControl new];
        self.refreshControl.tintColor = [UIColor lightGrayColor];
        [self.refreshControl mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(@-30);
            make.centerX.equalTo(@(self.frame.size.width / 2.0));
        }];
    }
    self.refreshHandler = handler;
}

- (void)customPanGesture:(UIPanGestureRecognizer *)gestureRecognizer {
    if (@available(iOS 10.0, *)) {
        if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
            if (self.refreshControl.isRefreshing && self.refreshHandler) {
                self.refreshHandler();
            }
        }
        [self customPanGesture:gestureRecognizer];
    }
}

- (void)beginRefresh {
    self.veLoading = YES;
    if (@available(iOS 10.0, *)) {
        [self.refreshControl beginRefreshing];
    }
}

- (void)endRefresh {
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.3 animations:^{
            [self setContentOffset:CGPointMake(0, 0) animated:YES];
        } completion:^(BOOL finished) {
        }];
    });
    if (@available(iOS 10.0, *)) {
        self.veLoading = NO;
        [self.refreshControl endRefreshing];
    }
}

@end
