//
//  UIViewController+Orientation.h
//  quickstart
//
//  Created by bytedance on 2021/3/24.
//  Copyright © 2021 bytedance. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, ScreenOrientation) {
	ScreenOrientationLandscapeAndPortrait = 1,
	ScreenOrientationLandscape,
	ScreenOrientationPortrait,
};

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (Orientation)
@property(nonatomic, assign) UIInterfaceOrientation orientation;
- (void)setDeviceInterfaceOrientation:(UIDeviceOrientation)orientation;

- (void)addOrientationNotice;

- (void)orientationDidChang:(BOOL)isLandscape;

- (void)setAllowAutoRotate:(ScreenOrientation)screenOrientation;

@end

NS_ASSUME_NONNULL_END
