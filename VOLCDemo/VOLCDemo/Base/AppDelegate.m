
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
    
    /// global config
    [VEUserGlobalConfiguration sharedInstance];
    
    /// init ttsdk
    [self initTTSDKWithOptions:launchOptions];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    /// Don’t forget, this code must be added ！！！
    [TTVideoEngine stopOpenGLESActivity];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    /// Don’t forget, this code must be added ！！！
    [TTVideoEngine startOpenGLESActivity];
}


#pragma mark - TTSDK init

- (void)initTTSDKWithOptions:(NSDictionary *)launchOptions {
    NSString *appId = @"229234";
    
    /// Initialize TTSDK, configure Lisence ，this step cannot be skipped !!!!!
    TTSDKConfiguration *configuration = [TTSDKConfiguration defaultConfigurationWithAppID:appId licenseName:@"VOLC-PlayerDemo"];
#if DEBUG
    /// add lisence observer，suggest debug open
    [self addLicenseObserver];
#endif
    [TTSDKManager startWithConfiguration:configuration];
    
#ifdef DEBUG
    // print debug log，suggest debug open
    [TTVideoEngine setLogFlag:TTVideoEngineLogFlagEngine];
#endif
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
