//
//  VEPlayerUtility.m
//  Article
//

#import "VEPlayerUtility.h"
#import "BTDResponder.h"
#import <Reachability/Reachability.h>

#include <sys/types.h>
#include <sys/sysctl.h>

@implementation VEPlayerUtility

+ (void)quitCurrentViewController {
    UIViewController * topVC = [BTDResponder topViewController];//[TTUIResponderHelper topViewControllerFor:self];
    if ([topVC presentingViewController]) {
        [topVC dismissViewControllerAnimated:YES completion:^{
            
        }];
        return;
    }
    if ([topVC isKindOfClass:[UINavigationController class]]) {
        [((UINavigationController *)topVC) popViewControllerAnimated:YES];
    } else {
        if (topVC.navigationController) {
            [topVC.navigationController popViewControllerAnimated:YES];
        } else {
            [topVC dismissViewControllerAnimated:YES completion:^{
                
            }];
        }
    }
}

+ (UIViewController *)lm_topmostViewController {
    UIViewController *rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    if (!rootVC) {
        rootVC = [UIApplication sharedApplication].delegate.window.rootViewController;
    }
    return [self lm_topViewControllerRecursivityWithRootViewController:rootVC];
}

+ (UIViewController *)lm_topViewControllerRecursivityWithRootViewController:(UIViewController *)rootViewController{
    if ([rootViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabBarController = (UITabBarController *)rootViewController;
        return [self lm_topViewControllerRecursivityWithRootViewController:tabBarController.selectedViewController];
    }
    else if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController *)rootViewController;
        return [self lm_topViewControllerRecursivityWithRootViewController:navigationController.topViewController];
    }
    else if (rootViewController.presentedViewController) {
        UIViewController *presentedViewController = rootViewController.presentedViewController;
        return [self lm_topViewControllerRecursivityWithRootViewController:presentedViewController];
    }
    else {
        return rootViewController; // TODO deal childViewController
    }
}

+ (CGRect)landscapeFullScreenBounds {
    CGRect bounds = [UIScreen mainScreen].bounds;
    if (bounds.size.width < bounds.size.height) {
        CGFloat height = bounds.size.height;
        bounds.size.height = bounds.size.width;
        bounds.size.width = height;
    }
    return bounds;
}

+ (CGRect)portraitFullScreenBounds {
    CGRect bounds = [UIScreen mainScreen].bounds;
    if (bounds.size.width > bounds.size.height) {
        CGFloat height = bounds.size.height;
        bounds.size.height = bounds.size.width;
        bounds.size.width = height;
    }
    return bounds;
}

+ (UIInterfaceOrientation)currentOrientation
{
    #if __IPHONE_OS_VERSION_MAX_ALLOWED >= 130000
    if (@available(iOS 13.0, *)) {
        UIInterfaceOrientation orientation = [UIApplication sharedApplication].keyWindow.windowScene.interfaceOrientation;
        return orientation;
    }
    #endif
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    return orientation;
}


+ (BOOL)ttv_isNetworkConnected {
    NetworkStatus netStatus = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus];
    if(netStatus != NotReachable) return YES;
    return NO;
}

+ (BOOL)ttv_isNetworkWifi {
    NetworkStatus netStatus = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus];
    if(netStatus == ReachableViaWiFi) return YES;
    return NO;
}

+ (NSString *)ttv_platformString {
    static dispatch_once_t onceToken;
    static NSString *s_platform = nil;
    dispatch_once(&onceToken, ^{
        size_t size;
        sysctlbyname("hw.machine", NULL, &size, NULL, 0);
        char *machine = malloc(size);
        sysctlbyname("hw.machine", machine, &size, NULL, 0);
        s_platform = [NSString stringWithUTF8String:machine];
        free(machine);
    });
    return s_platform;
}

+ (BOOL)ttv_isSimulator {
    static dispatch_once_t onceToken;
    static BOOL s_isSimulator = NO;
    dispatch_once(&onceToken, ^{
        NSString *platformString = [VEPlayerUtility ttv_platformString];
        if ([platformString isEqualToString:@"i386"] || [platformString isEqualToString:@"x86_64"]) {
            s_isSimulator = YES;
        }
    });
    return s_isSimulator;
}

+ (BOOL)ttv_isvalidNumber:(NSTimeInterval)number {
    return !isnan(number) && number != NAN;
}

+ (NSString *)netWorkSpeedStringWithKBPerSeconds:(NSInteger)netWorkSpeed {
    netWorkSpeed = MIN(netWorkSpeed, ULONG_MAX);
    NSString *netSpeedText;
    if (![self ttv_isNetworkConnected]) {
        netSpeedText = @"0 KB/s";
    }
    else if (netWorkSpeed <= 0) {
        netSpeedText = @"0 KB/s";
    }
    else if (netWorkSpeed >= 1024) {
        CGFloat speed = (CGFloat)netWorkSpeed / 1024;
        if (speed < 10) {
            netSpeedText = [NSString stringWithFormat:@"%.1f MB/s", speed];
        }else{
            netSpeedText = [NSString stringWithFormat:@"%lu MB/s", (unsigned long)speed];
        }
    }else{
        netSpeedText = [NSString stringWithFormat:@"%lu KB/s", (unsigned long)netWorkSpeed];
    }
    return netSpeedText;
}

// Base64解码方法，根据长度补全 『=』
+ (NSString *)base64DecodingStringWithInputText:(NSString *)inputText {
    NSInteger remainder = inputText.length % 4;
    NSMutableString *tmpMstring = [[NSMutableString alloc] initWithString:inputText];
    if (remainder > 0) {
        for (; remainder < 4; remainder++) {
            [tmpMstring appendString:@"="];
        }
    }
    NSData *data = [[NSData alloc]initWithBase64EncodedString:tmpMstring options:0];
    
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

@end

