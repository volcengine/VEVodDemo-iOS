#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIWindow (BTDAdditions)

/**
 The height of the status bar is different in default mode and zoom mode. The property btd_zoomedModeCompatible controls whether the value of btd_defaultStatusBarHeight returned matches the zoomed mode.
 
 @default NO
 */
@property (class, nonatomic, assign) BOOL btd_zoomedModeCompatible;

/**
 In Xcode13, the status bar height obtained for iPhone14 Pro and iPhone14 Pro Max models do not match the actual size. This property controls whether to use the preset status bar height for both models in the Xcode13 environment. If your program is building with Xcode13, it is recommended to set it to YES. If your program is building with Xcode14 or later, you don't have to set it.
 @default NO
 
 For iPhone14 Pro:
    default mode: btd_defaultStatusBarHeight = 54
    zoomed mode: btd_defaultStatusBarHeight = 44
 For iPhone14 Pro Max:
    default mode: btd_defaultStatusBarHeight = 54
    zoomed mode: btd_defaultStatusBarHeight = 47
 
 Affected API:
    - btd_statusBarHeight; + btd_defaultStatusBarHeight;
 */
@property (class, nonatomic, assign) BOOL btd_statusBarHeightXcode13Compatible;

/**
 * For iOS 13- devices, find the key window of the app.
 *
 * For iOS 13+ devices, find the key window from the first active connected scene in foreground.
 * In cases where multiple connected scenes are active in foreground (e.g. two windows side by side on iPad),
 * this method will return the key window from the currently focused window scene. If this is not the desired behavior,
 * please try UIView's window property to get the currently focused window if you have access to the view-related objects.
 *
 * @return the key window of the app
 */
/**
  If btd_useNewBTDKeyWindow is NO, btd_keyWindow will return [UIApplication sharedApplication].keyWindow in iOS 14 and 15.
 */
@property(nonatomic, assign, class) BOOL btd_useNewBTDKeyWindow;

+ (nullable UIWindow *)btd_keyWindow NS_EXTENSION_UNAVAILABLE_IOS("Not available in Extension Target");

/**
 The height of statusBar for window.
 */
- (CGFloat)btd_statusBarHeight;

/**
 The default height of statusBar for key window. If the statusBar is hidden, it will also return default height in device instead of 0. 
 */
+ (CGFloat)btd_defaultStatusBarHeight API_AVAILABLE(ios(3.2));

@end

NS_ASSUME_NONNULL_END
