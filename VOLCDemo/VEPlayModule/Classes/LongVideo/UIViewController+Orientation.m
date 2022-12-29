//
//  UIViewController+Orientation.m
//  quickstart
//
//  Created by bytedance on 2021/3/24.
//  Copyright © 2021 bytedance. All rights reserved.
//

#import "UIViewController+Orientation.h"
#import <YYKit/NSObject+YYAdd.h>
#import <objc/runtime.h>
@implementation UIViewController (Orientation)

static char kAssociatedObjectKey_Orientation;
- (void)setOrientation:(UIInterfaceOrientation)orientation {
	objc_setAssociatedObject(self, &kAssociatedObjectKey_Orientation, @(orientation), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIInterfaceOrientation)orientation {
	NSNumber *value = objc_getAssociatedObject(self, &kAssociatedObjectKey_Orientation);
	if (value == nil) {
		[self setOrientation:(UIInterfaceOrientationPortrait)];
		return UIInterfaceOrientationPortrait;
	}
	return [((NSNumber *)objc_getAssociatedObject(self, &kAssociatedObjectKey_Orientation)) integerValue];
}


- (void)addOrientationNotice {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDeviceOrientationDidChange)
                                                 name:UIApplicationDidChangeStatusBarOrientationNotification
                                                   object:nil];
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
}

- (void)setAllowAutoRotate:(ScreenOrientation)screenOrientation {
//    AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
//    delegate.screenOrientation = screenOrientation;
}

- (void)onDeviceOrientationDidChange {
    BOOL isLandscape = NO;
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    switch (interfaceOrientation) {
        
        case UIInterfaceOrientationUnknown:
            break;
        
        case UIInterfaceOrientationPortrait:
            break;
        
        case UIInterfaceOrientationPortraitUpsideDown:
            break;
        
        case UIInterfaceOrientationLandscapeLeft:
            isLandscape = YES;
            break;
        
        case UIInterfaceOrientationLandscapeRight:
            isLandscape = YES;
            break;
    
        default:
            break;
    }
    [self orientationDidChang:isLandscape];
}

- (void)orientationDidChang:(BOOL)isLandscape {
    //在 UIViewController 重写
    //Rewrite in UIViewController
}

- (void)setDeviceInterfaceOrientation:(UIDeviceOrientation)orientation {
    id<UIApplicationDelegate> delegate = [UIApplication sharedApplication].delegate;
    if ([delegate respondsToSelector:NSSelectorFromString(@"setShouldRotation:")]) {
        [((NSObject *)delegate) performSelectorWithArgs:NSSelectorFromString(@"setShouldRotation:"), UIDeviceOrientationIsLandscape(orientation)];
    }
    self.orientation = (UIInterfaceOrientation)orientation;
#ifdef __IPHONE_16_0
  if (@available(iOS 16.0, *)) {
    __weak __typeof(self)weakSelf = self;
    UIWindowSceneGeometryPreferences *pre = [[UIWindowSceneGeometryPreferencesIOS alloc] initWithInterfaceOrientations:(UIInterfaceOrientationMask)(1 << orientation)];
    [UIApplication.sharedApplication.keyWindow.windowScene requestGeometryUpdateWithPreferences:pre errorHandler:^(NSError * _Nonnull error) {
      __strong __typeof(weakSelf)strongSelf = weakSelf;
      [strongSelf setNeedsUpdateOfSupportedInterfaceOrientations];
    }];
  } else {
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
      NSNumber *orientationUnknown = @(UIInterfaceOrientationUnknown);
      [[UIDevice currentDevice] setValue:orientationUnknown forKey:@"orientation"];
      [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:orientation] forKey:@"orientation"];
    }
    /// 延时一下调用，否则无法横屏
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
      [UIViewController attemptRotationToDeviceOrientation];
    });
  }
#else
  if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
    NSNumber *orientationUnknown = @(UIInterfaceOrientationUnknown);
    [[UIDevice currentDevice] setValue:orientationUnknown forKey:@"orientation"];
    [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:orientation] forKey:@"orientation"];
  }
  /// 延时一下调用，否则无法横屏
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    [UIViewController attemptRotationToDeviceOrientation];
  });
#endif
}

/// MARK: - 横竖屏问题
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
	return self.orientation;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
	return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscape;
}

- (BOOL)shouldAutorotate {
	return self.orientation != UIInterfaceOrientationMaskPortrait;
}
@end
