//
//  BTDResponder.m
//  Essay
//

#import "BTDResponder.h"
#import "UIWindow+BTDAdditions.h"

@implementation BTDResponder

#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wincompatible-pointer-types"
#pragma clang diagnostic pop

+ (UINavigationController *)topNavigationControllerForResponder:(UIResponder *)responder
{
    UIViewController *topViewController = [self topViewControllerForResponder:responder];
    if ([topViewController isKindOfClass:[UINavigationController class]]) {
        return (UINavigationController *)topViewController;
    } else if (topViewController.navigationController) {
        return topViewController.navigationController;
    } else {
        return nil;
    }
}

+ (UIViewController *)topViewController
{
    return [self topViewControllerForController:[UIWindow btd_keyWindow].rootViewController];
}

+ (BOOL)isTopViewController:(UIViewController *)viewController
{
    return [self topViewController] == viewController;
}

+ (UIView *)topView
{
    return [self topViewController].view;
}

+ (UIViewController *)topViewControllerForController:(UIViewController *)rootViewController
{
    if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController *)rootViewController;
        return [self topViewControllerForController:[navigationController.viewControllers lastObject]];
    }
    if ([rootViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabController = (UITabBarController *)rootViewController;
        return [self topViewControllerForController:tabController.selectedViewController];
    }
    if (rootViewController.presentedViewController) {
        return [self topViewControllerForController:rootViewController.presentedViewController];
    }
    return rootViewController;
}

+ (UIViewController *)topViewControllerForView:(UIView *)view
{
    UIResponder *responder = view;
    while(responder && ![responder isKindOfClass:[UIViewController class]]) {
        responder = [responder nextResponder];
    }
    
    if(!responder) {
        responder = [UIWindow btd_keyWindow].rootViewController;
    }
    
    return [self topViewControllerForController:(UIViewController *)responder];
}

+ (UIViewController *)topViewControllerForResponder:(UIResponder *)responder
{
    if ([responder isKindOfClass:[UIView class]]) {
        return [self topViewControllerForView:(UIView *)responder];
    } else if ([responder isKindOfClass:[UIViewController class]]) {
        return [self topViewControllerForController:(UIViewController *)responder];
    } else {
        return [self topViewController];
    }
}

+ (void)closeTopViewControllerWithAnimated:(BOOL)animated
{
    UIViewController *viewController = [self topViewController];
    [viewController closeWithAnimated:animated];
}

@end

///////////////////////////////////////////////////////////////////////////////////

@implementation UIViewController (BTD_Close)

- (void)closeWithAnimated:(BOOL)animated
{
    // Close the NavigationController firstly，then the model ViewController.
    if (self.navigationController && self.navigationController.viewControllers.count > 1) {
        [self.navigationController popViewControllerAnimated:animated];
    } else if (self.presentingViewController) {
        [self.presentingViewController dismissViewControllerAnimated:animated completion:nil];
    } else {
        // do nothing
    }
}

@end
