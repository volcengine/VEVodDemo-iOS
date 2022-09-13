
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


FOUNDATION_EXTERN NSString * const TTLicenseNotificationLicenseDidAdd;
FOUNDATION_EXTERN NSString * const TTLicenseNotificationLicenseInfoDidUpdate;;
FOUNDATION_EXTERN NSString * const TTLicenseNotificationLicenseResultKey;


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
    if (self.screenDirection == UIInterfaceOrientationLandscapeRight) {
        return UIInterfaceOrientationMaskLandscapeRight;
    } else {
        return UIInterfaceOrientationMaskPortrait;
    }
}

- (void)forceRotate {
    // 只考虑landscape right 和 portrait
    UIInterfaceOrientation currentOrientation = [UIApplication sharedApplication].statusBarOrientation;
    UIInterfaceOrientation destinationOrientation = UIInterfaceOrientationUnknown;
    if (currentOrientation == UIInterfaceOrientationPortrait) {
        destinationOrientation = UIInterfaceOrientationLandscapeRight;
    } else {
        destinationOrientation = UIInterfaceOrientationPortrait;
    }
    self.screenDirection = destinationOrientation;
    [[UIDevice currentDevice] setValue:@(destinationOrientation) forKey:@"orientation"];
    [UIViewController attemptRotationToDeviceOrientation];
}


#pragma mark - TTSDK

- (void)initTTSDK {
#ifdef DEBUG
    /// 建议Debug期间打开Log开关
    [TTVideoEngine setLogFlag:TTVideoEngineLogFlagAll];
    /// 建议Debug期间打开，监听 license 是否加载成功，
    [self addLicenseObserver];
#endif
    NSString *appId = @"229234";
    /// initialize ttsdk, configure Liscene ，this step cannot be skipped !!!!!
    TTSDKConfiguration *configuration = [TTSDKConfiguration defaultConfigurationWithAppID:appId licenseName:@"VOLC-PlayerDemo"];
    /// 播放器CacheSize，默认100M，建议设置 300M
    TTSDKVodConfiguration *vodConfig = [[TTSDKVodConfiguration alloc] init];
    vodConfig.cacheMaxSize = 300 * 1024 * 1024; // 300M
    configuration.vodConfiguration = vodConfig;
    [TTSDKManager startWithConfiguration:configuration];
}

- (void)addLicenseObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(licenseDidAdd:) name:TTLicenseNotificationLicenseDidAdd object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(licenseInfoDidUpdate:) name:TTLicenseNotificationLicenseInfoDidUpdate object:nil];
}

- (void)licenseDidAdd:(NSNotification *)noti {
    NSNumber *success = [noti userInfo][TTLicenseNotificationLicenseResultKey];
    BOOL isSuccess = [success boolValue];
    if (isSuccess) {
        NSLog(@"add license successfully");
    } else {
        NSLog(@"failed to add license");
    }
}

- (void)licenseInfoDidUpdate:(NSNotification *)noti {
    NSNumber *success = [noti userInfo][TTLicenseNotificationLicenseResultKey];
    BOOL isSuccess = [success boolValue];
    if (isSuccess) {
        NSLog(@"update license successfully");
    } else {
        NSLog(@"failed to update license");
    }
}


@end
