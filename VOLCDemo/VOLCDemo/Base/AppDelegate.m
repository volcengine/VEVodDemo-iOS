
//
//  AppDelegate.m
//  VOLCDemo
//
//  Created by real on 2021/5/21.
//

#import "AppDelegate.h"
#import "VEMainViewController.h"
#import "VEUserGlobalConfiguration.h"
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
    
    self.window.rootViewController = mainController;
    [self.window makeKeyAndVisible];
    
    /// Deme全局设置，业务不要设置
    [VEUserGlobalConfiguration sharedInstance];
    
    /// 初始化SDK
    [self initTTSDKWithOptions:launchOptions];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    /// TTSDK 1.28.1 以下版本需要设置，否则会出现有声音没画面问题
//    [TTVideoEngine stopOpenGLESActivity];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    /// TTSDK 1.28.1 以下版本需要设置，否则会出现有声音没画面问题
//    [TTVideoEngine startOpenGLESActivity];
}


#pragma mark - TTSDK init

- (void)initTTSDKWithOptions:(NSDictionary *)launchOptions {
#ifdef DEBUG
    /// 建议Debug期间打开Log开关
    [TTVideoEngine setLogFlag:TTVideoEngineLogFlagEngine];
    /// 建议Debug期间打开，监听 license 是否加载成功，
    [self addLicenseObserver];
#endif
    
    NSString *appId = @"229234";
    
    /// initialize ttsdk, configure Lisence ，this step cannot be skipped !!!!!
    TTSDKConfiguration *configuration = [TTSDKConfiguration defaultConfigurationWithAppID:appId licenseName:@"VOLC-PlayerDemo"];
    
    /// 播放器CacheSize，默认100M，建议设置 300M
    TTSDKVodConfiguration *vodConfig = [[TTSDKVodConfiguration alloc] init];
    vodConfig.cacheMaxSize = 300 * 1024 *1024; // 300M
    configuration.vodConfiguration = vodConfig;
    
    [TTSDKManager startWithConfiguration:configuration];
}


#pragma mark - Add license observer

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
