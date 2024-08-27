
//
//  AppDelegate.m
//  VOLCDemo
//
//  Created by real on 2021/5/21.
//

#import "AppDelegate.h"
#import "VEMainViewController.h"
#import <TTSDKFramework/TTSDKManager.h>
#import <TTSDKFramework/TTVideoEngineHeader.h>

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

- (void)updateShouldRotation:(NSNumber *)shouldRotation {
    _shouldRotation = [shouldRotation boolValue];
    if (!_shouldRotation) {
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
        return;
    }
    
    /// initialize ttsdk, configure Liscene ，this step cannot be skipped !!!!!
    TTSDKConfiguration *configuration = [TTSDKConfiguration defaultConfigurationWithAppID:appId licenseName:licenseName];
    /// 播放器CacheSize，默认100M，建议设置 300M
    TTSDKVodConfiguration *vodConfig = [[TTSDKVodConfiguration alloc] init];
    vodConfig.cacheMaxSize = 300 * 1024 * 1024; // 300M
    configuration.vodConfiguration = vodConfig;
    [TTSDKManager startWithConfiguration:configuration];
}

@end
