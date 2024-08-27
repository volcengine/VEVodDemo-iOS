#import "UIWindow+BTDAdditions.h"
#import "UIDevice+BTDAdditions.h"
#import "NSDictionary+BTDAdditions.h"

static BOOL BTDUseNewBTDKeyWindow = YES;
static BOOL BTDZoomedModeCompatible = NO;
static BOOL BTDStatusBarHeightXcode13Compatible = NO;

@implementation UIWindow (BTDAdditions)

+ (BOOL)btd_useNewBTDKeyWindow {
    return BTDUseNewBTDKeyWindow;
}

+ (void)setBtd_useNewBTDKeyWindow:(BOOL)btd_useNewBTDKeyWindow {
    BTDUseNewBTDKeyWindow = btd_useNewBTDKeyWindow;
}

+ (BOOL)btd_zoomedModeCompatible {
    return BTDZoomedModeCompatible;
}

+ (void)setBtd_zoomedModeCompatible:(BOOL)btd_zoomedModeCompatible {
    BTDZoomedModeCompatible = btd_zoomedModeCompatible;
}

+ (BOOL)btd_statusBarHeightXcode13Compatible {
    return BTDStatusBarHeightXcode13Compatible;
}

+ (void)setBtd_statusBarHeightXcode13Compatible:(BOOL)btd_statusBarHeightXcode13Compatible {
    BTDStatusBarHeightXcode13Compatible = btd_statusBarHeightXcode13Compatible;
}

+ (BOOL)btd_isXcode13CompatiblePlatform {
    static BOOL isCompatiblePlatform = NO;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *platform = [UIDevice btd_platformStringWithSimulatorType];
        if ([platform isEqualToString:IPHONE_14_PRO_NAMESTRING] ||
            [platform isEqualToString:IPHONE_14_PRO_MAX_NAMESTRING]) {
            isCompatiblePlatform = YES;
        }
    });
    return isCompatiblePlatform;
}

+ (nullable UIWindow *)btd_keyWindow
{
    if (@available(iOS 13.0, *)) {
        if (!UIWindow.btd_useNewBTDKeyWindow) {
            return [UIApplication sharedApplication].keyWindow;
        }
        // Find active key window from UIScene
        UIWindow *keyWindow = nil;
        NSInteger activeWindowSceneCount = 0;
        NSSet *connectedScenes = [UIApplication sharedApplication].connectedScenes;
        for (UIScene *scene in connectedScenes) {
            if (scene.activationState == UISceneActivationStateForegroundActive && [scene isKindOfClass:[UIWindowScene class]]) {
                activeWindowSceneCount++;
                UIWindowScene *windowScene = (UIWindowScene *)scene;
                if (!keyWindow) {
                    keyWindow = [self _keyWindowFromWindowScene:windowScene];
                }
            }
        }
        
        // If there're multiple active window scenes, get the key window from the currently focused window scene to keep the behavior consistent with [UIApplication sharedApplication].keyWindow
        if (activeWindowSceneCount > 1) {
            // Although [UIApplication sharedApplication].keyWindow is deprecated for iOS 13+, it can help to find the focused one when multiple scenes in the foreground
            keyWindow = [self _keyWindowFromWindowScene:[UIApplication sharedApplication].keyWindow.windowScene];
        }
        
        // Sometimes there will be no active scene in foreground, loop through the application windows for the key window
        if (!keyWindow) {
            for (UIWindow *window in [UIApplication sharedApplication].windows) {
                if (window.isKeyWindow) {
                    keyWindow = window;
                    break;
                }
            }
        }
        
        // Check to see if the app key window is true and add protection
        if (!keyWindow && [UIApplication sharedApplication].keyWindow.isKeyWindow) {
            keyWindow = [UIApplication sharedApplication].keyWindow;
        }
        
        // Still nil ? Add protection to always fallback to the application delegate's window.
        // There's a chance when delegate doesn't respond to window, so add protection here
        if (!keyWindow && [[UIApplication sharedApplication].delegate respondsToSelector:@selector(window)]) {
            keyWindow = [UIApplication sharedApplication].delegate.window;
        }
        
        return keyWindow;
    } else {
        // Fall back to application's key window below iOS 13
        return [UIApplication sharedApplication].keyWindow;
    }
}

- (CGFloat)btd_statusBarHeight {
    CGFloat statusBarHeight = 0;
    if (@available(iOS 13.0, *)) {
        UIStatusBarManager *statusBarManager = [[self windowScene] statusBarManager] ;
        statusBarHeight = statusBarManager.statusBarFrame.size.height;
    }
    else {
        statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    }
    if (statusBarHeight != 0 && UIWindow.btd_statusBarHeightXcode13Compatible && UIWindow.btd_isXcode13CompatiblePlatform) {
        NSString *platform = [UIDevice btd_platformStringWithSimulatorType];
        return [UIWindow _btd_iPhoneStatusBarHeightForPlatform:platform];
    }
    return statusBarHeight;
}

+ (CGFloat)_btd_iPhoneStatusBarHeightForPlatform:(NSString *)platform {
    static NSDictionary *statusBarHeightDict = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        BOOL isZoomedMode = UIScreen.mainScreen.scale < UIScreen.mainScreen.nativeScale;
        if (UIWindow.btd_zoomedModeCompatible && isZoomedMode) {
            statusBarHeightDict = [self btd_iPhoneStatusBarHeightForZoomedMode];
        } else {
            statusBarHeightDict = [self btd_iPhoneStatusBarHeightForDefaultMode];
        }
        
    });
    /// default value is 44.0f
    return [statusBarHeightDict btd_floatValueForKey:platform default:44.0f];
}

+ (NSMutableDictionary *)btd_iPhoneStatusBarHeightForDefaultMode {
    NSMutableDictionary *statusBarHeightDict = @{
        IPHONE_6S_NAMESTRING: @20.0f,
        IPHONE_6S_PLUS_NAMESTRING: @20.0f,
        IPHONE_SE: @20.0f,
        IPHONE_7_NAMESTRING: @20.0f,
        IPHONE_7_PLUS_NAMESTRING: @20.0f,
        IPHONE_8_NAMESTRING: @20.0f,
        IPHONE_8_PLUS_NAMESTRING: @20.0f,
        IPHONE_X_NAMESTRING: @44.0f,
        IPHONE_XS_NAMESTRING: @44.0f,
        IPHONE_XS_MAX_NAMESTRING: @44.0f,
        IPHONE_XR_NAMESTRING: @48.0f,
        IPHONE_11_NAMESTRING: @48.0f,
        IPHONE_11_PRO_NAMESTRING: @44.0f,
        IPHONE_11_PRO_MAX_NAMESTRING: @44.0f,
        IPHONE_12_MINI_NAMESTRING: @50.0f,
        IPHONE_12_NAMESTRING: @47.0f,
        IPHONE_12_PRO_NAMESTRING: @47.0f,
        IPHONE_12_PRO_MAX_NAMESTRING: @47.0f,
        IPHONE_SE_2_NAMESTRING: @20.0f,
        IPHONE_13_MINI_NAMESTRING: @50.0f,
        IPHONE_13_NAMESTRING: @47.0f,
        IPHONE_13_PRO_NAMESTRING: @47.0f,
        IPHONE_13_PRO_MAX_NAMESTRING: @47.0f,
        IPHONE_SE_3_NAMESTRING: @20.0f,
        IPHONE_14_NAMESTRING: @47.0f,
        IPHONE_14_PLUS_NAMESTRING: @47.0f,
        IPHONE_14_PRO_NAMESTRING: @54.0f,
        IPHONE_14_PRO_MAX_NAMESTRING: @54.0f,
        IPHONE_15_NAMESTRING: @54.0f,
        IPHONE_15_PLUS_NAMESTRING: @54.0f,
        IPHONE_15_PRO_NAMESTRING: @54.0f,
        IPHONE_15_PRO_MAX_NAMESTRING: @54.0f,
    }.mutableCopy;
    
    return statusBarHeightDict;
}

+ (NSMutableDictionary *)btd_iPhoneStatusBarHeightForZoomedMode {
    NSMutableDictionary *statusBarHeightDict = @{
        IPHONE_6S_NAMESTRING: @20.0f,
        IPHONE_6S_PLUS_NAMESTRING: @20.0f,
        IPHONE_SE: @20.0f,
        IPHONE_7_NAMESTRING: @20.0f,
        IPHONE_7_PLUS_NAMESTRING: @20.0f,
        IPHONE_8_NAMESTRING: @20.0f,
        IPHONE_8_PLUS_NAMESTRING: @20.0f,
        IPHONE_X_NAMESTRING: @38.0f,
        IPHONE_XS_NAMESTRING: @38.0f,
        IPHONE_XS_MAX_NAMESTRING: @43.0f,
        IPHONE_XR_NAMESTRING: @43.0f,
        IPHONE_11_NAMESTRING: @43.0f,
        IPHONE_11_PRO_NAMESTRING: @38.0f,
        IPHONE_11_PRO_MAX_NAMESTRING: @43.0f,
        IPHONE_12_MINI_NAMESTRING: @43.0f,
        IPHONE_12_NAMESTRING: @39.0f,
        IPHONE_12_PRO_NAMESTRING: @39.0f,
        IPHONE_12_PRO_MAX_NAMESTRING: @41.0f,
        IPHONE_SE_2_NAMESTRING: @20.0f,
        IPHONE_13_MINI_NAMESTRING: @43.0f,
        IPHONE_13_NAMESTRING: @39.0f,
        IPHONE_13_PRO_NAMESTRING: @39.0f,
        IPHONE_13_PRO_MAX_NAMESTRING: @41.0f,
        IPHONE_SE_3_NAMESTRING: @20.0f,
        IPHONE_14_NAMESTRING: @39.0f,
        IPHONE_14_PLUS_NAMESTRING: @41.0f,
        IPHONE_14_PRO_NAMESTRING: @44.0f,
        IPHONE_14_PRO_MAX_NAMESTRING: @47.0f,
        IPHONE_15_NAMESTRING: @44.0f,
        IPHONE_15_PLUS_NAMESTRING: @47.0f,
        IPHONE_15_PRO_NAMESTRING: @44.0f,
        IPHONE_15_PRO_MAX_NAMESTRING: @47.0f,
    }.mutableCopy;
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"16.0")) {
        [statusBarHeightDict btd_setObject:@40.0f forKey:IPHONE_XS_MAX_NAMESTRING];
        [statusBarHeightDict btd_setObject:@40.0f forKey:IPHONE_11_PRO_MAX_NAMESTRING];
    }
    
    return statusBarHeightDict;
}

+ (CGFloat)_btd_iPadStatusBarHeightForPlatform:(NSString *)platform {

    NSDictionary *statusBarHeightDict = @{
        IPAD_1G_NAMESTRING: @20.0f,
        IPAD_2G_NAMESTRING: @20.0f,
        IPAD_3G_NAMESTRING: @20.0f,
        IPAD_4G_NAMESTRING: @20.0f,
        IPAD_5G_NAMESTRING: @20.0f,
        IPAD_6G_NAMESTRING: @20.0f,
        IPAD_7G_NAMESTRING: @20.0f,
        IPAD_8G_NAMESTRING: @20.0f,
        IPAD_9G_NAMESTRING: @20.0f,
        IPAD_MINI_4_NAMESTRING: @20.0f,
        IPAD_MINI_5_NAMESTRING: @20.0f,
        IPAD_MINI_6_NAMESTRING: @24.0f,
        IPAD_AIR_2_NAMESTRING: @20.0f,
        IPAD_AIR_3_NAMESTRING: @20.0f,
        IPAD_AIR_4_NAMESTRING: @24.0f,
        IPAD_PRO_NAMESTRING: @20.0f,
        IPAD_PRO_2_NAMESTRING: @24.0f,
        IPAD_PRO_3_NAMESTRING: @24.0f,
        IPAD_PRO_4_NAMESTRING: @24.0f,
        IPAD_PRO_5_NAMESTRING: @24.0f,
    };

    return [statusBarHeightDict btd_floatValueForKey:platform default:20.0f];
}


+ (CGFloat)btd_defaultStatusBarHeight {
    CGFloat statusBarHeight = [[UIWindow btd_keyWindow] btd_statusBarHeight];
    if (statusBarHeight != 0.0f) {
        return statusBarHeight;
    }
    static CGFloat defaultHeight = 0.0f;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        BOOL isPadDevice = [UIDevice btd_isPadDevice];
        if (isPadDevice) {
            /// iPad device
            NSString *platform = [UIDevice btd_platformStringWithSimulatorType];
            defaultHeight = [self _btd_iPadStatusBarHeightForPlatform:platform];
        } else {
            NSString *platform = [UIDevice btd_platformStringWithSimulatorType];
            if ([platform hasPrefix:@"iPod"]) {
                /// iPod touch device
                defaultHeight = 20.0f;
            } else {
                /// iPhone device
                if (SYSTEM_VERSION_LESS_THAN(@"14.0")) {
                    defaultHeight = [UIDevice btd_isNotchScreenSeries] ? 44.0f : 20.0f;
                } else if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"14.0")) {
                    defaultHeight = [self _btd_iPhoneStatusBarHeightForPlatform:platform];
                }
            }
        }
    });
    return defaultHeight;
}

+ (UIWindow *)_keyWindowFromWindowScene:(id)windowScene
{
    if (@available(iOS 13.0, *)) {
        if ([windowScene isKindOfClass:[UIWindowScene class]]) {
            for (UIWindow *window in ((UIWindowScene *)windowScene).windows) {
                if (window.isKeyWindow) {
                    return window;
                }
            }
        }
    }
    return nil;
}

@end
