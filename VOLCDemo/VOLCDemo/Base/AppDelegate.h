//
//  AppDelegate.h
//  VOLCDemo
//
//  Created by real on 2021/5/21.
//

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic, strong) UIWindow *window;

@property (nonatomic, assign) BOOL shouldRotation;//是否允许横屏，默认为NO

- (void)updateShouldRotation:(NSNumber *)shouldRotation;

@end
