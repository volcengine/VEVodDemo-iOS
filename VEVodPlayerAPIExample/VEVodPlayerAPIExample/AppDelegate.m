// Copyright (c) 2025 Beijing Volcano Engine Technology Co., Ltd.
// SPDX-License-Identifier: MIT
//
//  AppDelegate.m
//  VEVodPlayerAPIExample
//
//  Created by ByteDance on 2025/5/27.
//

#import "AppDelegate.h"
#import "RootViewController.h"
#import "InitSDKExample.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    [self.window makeKeyAndVisible];
    RootViewController *vc = [[RootViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    self.window.rootViewController = nav;
    /// appid 和 license 不能为空, 请联系火山引擎商务获取体验 License 文件和 AppId.
    /// 注意: 申请的 license 文件与 app bundle identifier 是一一对应的.
    NSString *appId = @"";
    NSString *licenseName = @"";
    if (appId.length == 0 || licenseName.length == 0) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedStringFromTable(@"tip_license_required", @"VodLocalizable", nil) preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *vidSource = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            exit(0);
        }];
        [alert addAction:vidSource];
        [self.window.rootViewController presentViewController:alert animated:YES completion:nil];
        return YES;
    }
    [InitSDKExample initSDKWithAppID:appId LicenseName:licenseName];
    NSString *deviceID = [InitSDKExample getDeviceID];
    NSLog(@"VEVodPlayerAPIExample - current deviceID is %@", deviceID);
    return YES;
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [InitSDKExample clearUniqueID];
}

@end
