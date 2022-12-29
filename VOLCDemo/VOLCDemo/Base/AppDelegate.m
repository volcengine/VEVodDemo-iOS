
//
//  AppDelegate.m
//  VOLCDemo
//
//  Created by real on 2021/5/21.
//

#import "AppDelegate.h"
#import "VEMainViewController.h"
#import <TTSDK/TTSDKManager.h>
#import <TTSDK/TTVideoEngineHeader.h>

#if __has_include(<RangersAppLog/RangersAppLogCore.h>)
#import <RangersAppLog/RangersAppLogCore.h>
#endif


@interface AppDelegate ()

@property (nonatomic, assign) UIInterfaceOrientation screenDirection;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [UIWindow new];
    self.window.frame = UIScreen.mainScreen.bounds;
    self.window.backgroundColor = [UIColor blackColor];
    VEMainViewController *mainController = [VEMainViewController new];
    UINavigationController *mainNav = [[UINavigationController alloc] initWithRootViewController:mainController];
    self.window.rootViewController = mainNav;
    [self.window makeKeyAndVisible];
    /// 初始化SDK
    [self initTTSDK];
    return YES;
}


#pragma mark ----- Rotate
- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    if (self.shouldRotation) {
        return UIInterfaceOrientationMaskLandscapeRight;
    }
    return UIInterfaceOrientationMaskPortrait;
}

- (void)setShouldRotation:(BOOL)shouldRotation {
    _shouldRotation = shouldRotation;
    if (!shouldRotation) {
        if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
            SEL selector = NSSelectorFromString(@"setOrientation:");
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
            [invocation setSelector:selector];
            [invocation setTarget:[UIDevice currentDevice]];
            int val = UIInterfaceOrientationPortrait;
            [invocation setArgument:&val atIndex:2];
            [invocation invoke];
        }
    }
}


#pragma mark - TTSDK

- (void)initTTSDK {
#ifdef DEBUG
    /// 建议Debug期间打开Log开关
    [TTVideoEngine setLogFlag:TTVideoEngineLogFlagAll];
#endif
    NSString *appId = @"229234";
    /// initialize ttsdk, configure Liscene ，this step cannot be skipped !!!!!
    TTSDKConfiguration *configuration = [TTSDKConfiguration defaultConfigurationWithAppID:appId licenseName:@"VEVod"];
    /// 播放器CacheSize，默认100M，建议设置 300M
    TTSDKVodConfiguration *vodConfig = [[TTSDKVodConfiguration alloc] init];
    vodConfig.cacheMaxSize = 300 * 1024 * 1024; // 300M
    configuration.vodConfiguration = vodConfig;
    [TTSDKManager startWithConfiguration:configuration];
}

@end
