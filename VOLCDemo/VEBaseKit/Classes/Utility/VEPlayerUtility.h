//
//  VEPlayerUtility.h
//  Article
//

#import <Foundation/Foundation.h>

@interface VEPlayerUtility : NSObject

+ (void)quitCurrentViewController;

+ (UIViewController *)lm_topmostViewController;
+ (UIViewController *)lm_topViewControllerRecursivityWithRootViewController:(UIViewController *)rootViewController;

+ (CGRect)landscapeFullScreenBounds;

+ (CGRect)portraitFullScreenBounds;

+ (UIInterfaceOrientation)currentOrientation;

+ (BOOL)ttv_isNetworkConnected;
+ (BOOL)ttv_isNetworkWifi;

+ (NSString *)ttv_platformString;
+ (BOOL)ttv_isSimulator;
+ (BOOL)ttv_isvalidNumber:(NSTimeInterval)number;

+ (NSString *)netWorkSpeedStringWithKBPerSeconds:(NSInteger)netWorkSpeed;

@end


