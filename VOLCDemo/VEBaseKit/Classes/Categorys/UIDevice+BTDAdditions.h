//
//  UIDevice+BTDAdditions.h
//  Article
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#define kUIDeviceProcessID      @"ProcessID"
#define kUIDeviceProcessName    @"ProcessName"

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

#define IS_OS_6_OR_LATER SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0")
#define IS_OS_7_OR_LATER SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")
#define IS_OS_8_OR_LATER SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")
#define IS_OS_9_OR_LATER SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0")
#define IS_OS_10_OR_LATER SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"10.0")

/**
  These string values are defined for +[UIDevice btd_platformString]'s return value.
 */
#define IFPGA_NAMESTRING                @"iFPGA"

#define IPHONE_1G_NAMESTRING            @"iPhone 1G"
#define IPHONE_3G_NAMESTRING            @"iPhone 3G"
#define IPHONE_3GS_NAMESTRING           @"iPhone 3GS"
#define IPHONE_4_NAMESTRING             @"iPhone 4"
#define IPHONE_4S_NAMESTRING            @"iPhone 4S"
#define IPHONE_5GSM_NAMESTRING          @"iPhone 5 (GSM)"
#define IPHONE_5Global_NAMESTRING       @"iPhone 5 (Global)"
#define IPHONE_5C_NAMESTRING            @"iPhone 5C"
#define IPHONE_5S_NAMESTRING            @"iPhone 5S"
#define IPHONE_6_NAMESTRING             @"iPhone 6"
#define IPHONE_6_PLUS_NAMESTRING        @"iPhone 6 Plus"
#define IPHONE_6S_NAMESTRING            @"iPhone 6S"
#define IPHONE_6S_PLUS_NAMESTRING       @"iPhone 6S Plus"
#define IPHONE_SE                       @"iPhone SE"
#define IPHONE_7_NAMESTRING             @"iPhone 7"
#define IPHONE_7_PLUS_NAMESTRING        @"iPhone 7 Plus"
#define IPHONE_8_NAMESTRING             @"iPhone 8"
#define IPHONE_8_PLUS_NAMESTRING        @"iPhone 8 Plus"
#define IPHONE_X_NAMESTRING             @"iPhone X"
#define IPHONE_XS_NAMESTRING            @"iPhone XS"
#define IPHONE_XS_MAX_NAMESTRING        @"iPhone XS Max"
#define IPHONE_XR_NAMESTRING            @"iPhone XR"
#define IPHONE_11_NAMESTRING            @"iPhone 11"
#define IPHONE_11_PRO_NAMESTRING        @"iPhone 11 Pro"
#define IPHONE_11_PRO_MAX_NAMESTRING    @"iPhone 11 Pro Max"
#define IPHONE_12_MINI_NAMESTRING       @"iPhone 12 mini"
#define IPHONE_12_NAMESTRING            @"iPhone 12"
#define IPHONE_12_PRO_NAMESTRING        @"iPhone 12 Pro"
#define IPHONE_12_PRO_MAX_NAMESTRING    @"iPhone 12 Pro Max"
#define IPHONE_SE_2_NAMESTRING          @"iPhone SE2"
#define IPHONE_13_MINI_NAMESTRING       @"iPhone 13 mini"
#define IPHONE_13_NAMESTRING            @"iPhone 13"
#define IPHONE_13_PRO_NAMESTRING        @"iPhone 13 Pro"
#define IPHONE_13_PRO_MAX_NAMESTRING    @"iPhone 13 Pro Max"
#define IPHONE_SE_3_NAMESTRING          @"iPhone SE3"
#define IPHONE_14_NAMESTRING            @"iPhone 14"
#define IPHONE_14_PLUS_NAMESTRING       @"iPhone 14 Plus"
#define IPHONE_14_PRO_NAMESTRING        @"iPhone 14 Pro"
#define IPHONE_14_PRO_MAX_NAMESTRING    @"iPhone 14 Pro Max"
#define IPHONE_15_NAMESTRING            @"iPhone 15"
#define IPHONE_15_PLUS_NAMESTRING       @"iPhone 15 Plus"
#define IPHONE_15_PRO_NAMESTRING        @"iPhone 15 Pro"
#define IPHONE_15_PRO_MAX_NAMESTRING    @"iPhone 15 Pro Max"


#define IPHONE_UNKNOWN_NAMESTRING       @"Unknown iPhone"


#define IPOD_1G_NAMESTRING              @"iPod touch 1G"
#define IPOD_2G_NAMESTRING              @"iPod touch 2G"
#define IPOD_3G_NAMESTRING              @"iPod touch 3G"
#define IPOD_4G_NAMESTRING              @"iPod touch 4G"
#define IPOD_5G_NAMESTRING              @"iPod touch 5G"
#define IPOD_6G_NAMESTRING              @"iPod touch 6G"
#define IPOD_7G_NAMESTRING              @"iPod touch 7G"
#define IPOD_UNKNOWN_NAMESTRING         @"Unknown iPod"

#define IPAD_1G_NAMESTRING              @"iPad 1G"
#define IPAD_2G_NAMESTRING              @"iPad 2G"
#define IPAD_3G_NAMESTRING              @"iPad 3G"
#define IPAD_4G_NAMESTRING              @"iPad 4G"
#define IPAD_5G_NAMESTRING              @"iPad 5G"
#define IPAD_6G_NAMESTRING              @"iPad 6G"
#define IPAD_7G_NAMESTRING              @"iPad 7G"
#define IPAD_8G_NAMESTRING              @"iPad 8G"
#define IPAD_9G_NAMESTRING              @"iPad 9G"

#define IPAD_AIR_NAMESTRING             @"iPad AIR"
#define IPAD_AIR_2_NAMESTRING           @"iPad AIR 2"
#define IPAD_AIR_3_NAMESTRING           @"iPad AIR 3"
#define IPAD_AIR_4_NAMESTRING           @"iPad AIR 4"

#define IPAD_MINI_Retina_NAMESTRING     @"iPad Mini Retina"
#define IPAD_MINI_NAMESTRING            @"ipad Mini"
#define IPAD_MINI_2_NAMESTRING          @"iPad Mini 2"
#define IPAD_MINI_3_NAMESTRING          @"iPad Mini 3"
#define IPAD_MINI_4_NAMESTRING          @"iPad Mini 4"
#define IPAD_MINI_5_NAMESTRING          @"iPad Mini 5"
#define IPAD_MINI_6_NAMESTRING          @"iPad Mini 6"

#define IPAD_PRO_NAMESTRING             @"ipad Pro"
#define IPAD_PRO_2_NAMESTRING           @"iPad Pro 2"
#define IPAD_PRO_3_NAMESTRING           @"iPad Pro 3"
#define IPAD_PRO_4_NAMESTRING           @"iPad Pro 4"
#define IPAD_PRO_5_NAMESTRING           @"iPad Pro 5"

#define IPAD_UNKNOWN_NAMESTRING         @"Unknown iPad"

#define APPLETV_2G_NAMESTRING           @"Apple TV 2G"
#define APPLETV_UNKNOWN_NAMESTRING      @"Unknown Apple TV"

#define APPLE_VISION_PRO_NAMESTRING     @"Apple Vision Pro"

#define IOS_FAMILY_UNKNOWN_DEVICE       @"Unknown iOS device"

#define IPHONE_SIMULATOR_NAMESTRING         @"iPhone Simulator"
#define IPHONE_SIMULATOR_IPHONE_NAMESTRING  @"iPhone Simulator"
#define IPHONE_SIMULATOR_IPAD_NAMESTRING    @"iPad Simulator"
#define APPLE_VISION_PRO_SIMULATOR_NAMESTRING    @"Apple Vision Pro Simulator"

typedef NS_ENUM(NSUInteger, BTDDeviceWidthMode) {
    // iPad
    BTDDeviceWidthModePad,
    // iPhone 12 Pro Max, iPhone 14 Plus
    BTDDeviceWidthMode428,
    // iPhone 6 plus, iPhone 6S Plus, iPhone 7 plus, iPhone 7S plus, iPhone 8 plus, iPhone XS Max, iPhone XR, iPhone 11, iPhone 11 Pro Max
    BTDDeviceWidthMode414,
    // iPhone 12, iPhone 12 Pro, iPhone 14
    BTDDeviceWidthMode390,
    // iPhone 6, iPhone 6S, iPhone 7, iPhone 7S, iPhone 8, iPhone X, iPhone XS, iPhone 11 Pro, iPhone SE 2, iPhone 12 Mini, iPhone SE 3
    BTDDeviceWidthMode375,
    // iPhone 4, iPhone 4S, iPhone 5, iPhone 5s, iPhone 5C, iPhone 5S, iPhone SE
    BTDDeviceWidthMode320,
    // iPhone 14 Pro, iPhone 15, iPhone 15 Pro
    BTDDeviceWidthMode393,
    // iPhone 14 Pro MAX, iPhone 15 Plus, iPhone 15 Pro Max
    BTDDeviceWidthMode430,
};


typedef NS_ENUM(NSInteger, UIDevicePlatform)
{
    UIDeviceUnknown,
    
    UIDeviceiPhoneSimulator,
    UIDeviceiPhoneSimulatoriPhone, // both regular and iPhone 4 devices
    UIDeviceiPhoneSimulatoriPad,
    UIDeviceiPhoneSimulatoriAppleVisionPro,
    
    UIDevice1GiPhone,
    UIDevice3GiPhone,
    UIDevice3GSiPhone,
    UIDevice4iPhone,
    UIDevice4siPhone,
    UIDevice5GSMiPhone,
    UIDevice5GlobaliPhone,
    UIDevice5CiPhone,
    UIDevice5SiPhone,
    UIDevice6iPhone,
    UIDevice6PlusiPhone,
    UIDevice6SiPhone,
    UIDevice6SPlusiPhone,
    UIDeviceSEiPhone,
    UIDevice7_1iPhone,
    UIDevice7_3iPhone,
    UIDevice7_2PlusiPhone,
    UIDevice7_4PlusiPhone,
    UIDevice8iPhone,
    UIDevice8PlusiPhone,
    UIDeviceXiPhone,
    UIDeviceXSiPhone,
    UIDeviceXSMaxiPhone,
    UIDeviceXRiPhone,
    UIDevice11iPhone,
    UIDevice11ProiPhone,
    UIDevice11ProMaxiPhone,
    UIDevice12MiniiPhone,
    UIDevice12iPhone,
    UIDevice12ProiPhone,
    UIDevice12ProMaxiPhone,
    UIDeviceSE2iPhone,
    UIDevice13MiniiPhone,
    UIDevice13iPhone,
    UIDevice13ProiPhone,
    UIDevice13ProMaxiPhone,
    UIDeviceSE3iPhone,
    UIDevice14iPhone,
    UIDevice14PlusiPhone,
    UIDevice14ProiPhone,
    UIDevice14ProMaxiPhone,
    UIDevice15iPhone,
    UIDevice15PlusiPhone,
    UIDevice15ProiPhone,
    UIDevice15ProMaxiPhone,
    
    UIDevice1GiPod,
    UIDevice2GiPod,
    UIDevice3GiPod,
    UIDevice4GiPod,
    UIDevice5GiPod,
    UIDevice6GiPod,
    UIDevice7GiPod,
    
    UIDevice1GiPad,
    UIDevice2GiPad,
    UIDevice3GiPad,
    UIDevice4GiPad,
    UIDevice5GiPad,
    UIDevice6GiPad,
    UIDevice7GiPad,
    UIDevice8GiPad,
    UIDevice9GiPad,
    
    UIDeviceAiriPad,
    UIDeviceAir2iPad,
    UIDeviceAir3iPad,
    UIDeviceAir4iPad,
    
    UIDeviceiPadMiniRetina,
    UIDeviceiPadMini,
    UIDeviceiPadMini2,
    UIDeviceiPadMini3,
    UIDeviceiPadMini4,
    UIDeviceiPadMini5,
    UIDeviceiPadMini6,
    
    UIDeviceiPadPro,
    UIDeviceiPadPro2,
    UIDeviceiPadPro3,
    UIDeviceiPadPro4,
    UIDeviceiPadPro5,
    
    UIDeviceiAppleVisionPro,
    
    UIDeviceAppleTV2,
    UIDeviceUnknownAppleTV,
    
    UIDeviceUnknowniPhone,
    UIDeviceUnknowniPod,
    UIDeviceUnknowniPad,
    UIDeviceIFPGA
};

@interface UIDevice (BTDAdditions)

+ (nullable NSArray *)btd_runningProcesses;

#pragma mark - device 基础信息

/**
 @return hw.machine info. (e.g. @"iPhone1,1", @"iPhone13,4", @"iPad6,8", ...).
 */
+ (nullable NSString *)btd_platform;
+ (nullable NSString *)btd_hwmodel;
+ (UIDevicePlatform)btd_platformType;

/**
 @return the currentDevice's model (e.g. @"iPhone", @"iPod touch", @"iPad").
 */
+ (nullable NSString *)btd_platformName;


/**
 These two methods return the name of the current device model. The name string has been defined above(e.g. IPHONE_12_PRO_NAMESTRING, ...).
 
 Note that the [UIDevice btd_platformString] method does not resolve the name of the simulator, it returns the simulator identifier directly.(e.g. IPHONE_SIMULATOR_IPHONE_NAMESTRING, ...).
 The [UIDevice btd_platformStringWithSimulatorType] method can resolve the device name of the simulator to a specific device model.
 */
+ (nullable NSString *)btd_platformString;
+ (nullable NSString *)btd_platformStringWithSimulatorType;

+ (nullable NSString *)btd_OSVersion;
+ (float)btd_OSVersionNumber;
+ (nullable NSString *)btd_currentLanguage;

+ (nullable NSString *)btd_currentRegion;

+ (BOOL)btd_isJailBroken;
+ (nullable NSString *)btd_carrierName API_DEPRECATED("CTCarrier no longer supported", ios(2.0, 16.4));
+ (nullable NSString *)btd_carrierMCC API_DEPRECATED("CTCarrier no longer supported", ios(2.0, 16.4));
+ (nullable NSString *)btd_carrierMNC API_DEPRECATED("CTCarrier no longer supported", ios(2.0, 16.4));
+ (BOOL)btd_poorDevice __attribute__((deprecated("Please use +[BDCatowerUtils isLowDevice] instead!")));
+ (BOOL)btd_isPadDevice;

/**
 Return the informations of the device's screen.
 */
+ (CGFloat)btd_screenScale;

/**
 iPhone4, iPhone4S
 */
+ (BOOL)btd_is480Screen;

/**
 iPhone5, iPhone5C, iPhone5S, iPhoneSE
 */
+ (BOOL)btd_is568Screen;

/**
 iPhone6,iPhone6S, iPhone SE 2, iPhone SE 3
 */
+ (BOOL)btd_is667Screen;

/**
 iPhone6plus, iPhone6Splus
 */
+ (BOOL)btd_is736Screen;

/**
 iPhone X, iPhone XS, iPhone 11 Pro, iPhone 12 Mini
 */
+ (BOOL)btd_is812Screen;

/**
 iPhone 12, iPhone 12 Pro, iPhone 13, iPhone 13 Pro, iPhone 14
 */
+ (BOOL)btd_is844Screen;

/**
 iPhone 14 Pro, iPhone 15, iPhone 15 Pro
 */
+ (BOOL)btd_is852Screen;

/**
 iPhone XS Max, iPhone XR, iPhone 11, iPhone 11 Pro Max
 */
+ (BOOL)btd_is896Screen;

/**
 iPhone 12 Pro Max, iPhone 13 Pro Max, iPhone 14 Plus
 */
+ (BOOL)btd_is926Screen;

/**
 iPhone 14 Pro Max, iPhone 15 Plus, iPhone 15 Pro Max
 */
+ (BOOL)btd_is932Screen;

// iphone6，iphone6 plus
+ (BOOL)btd_isScreenWidthLarge320;

/**
 return YES if the device has a notch screen or dynamic island.(iPhone X, iPhone 11 and more)
  @return bool
 ⚠️ The meaning of this API is not clear, we will deprecate this API, and it is recommended to use btd_isNotchScreenSeries and btd_isDynamicIslandSeries instead.
 */
+ (BOOL)btd_isIPhoneXSeries;

/**
 Returns whether the device is notch screen. (iPhone X, iPhone 11 and more)
 */
+ (BOOL)btd_isNotchScreenSeries;

/**
 Returns whether the device has a dynamic island. (iPhone 14 pro, iPhone 14 Pro Max, iPhone 15 series)
 */
+ (BOOL)btd_isDynamicIslandSeries;

+ (CGSize)btd_screenSize;
+ (CGFloat)btd_screenWidth;
+ (CGFloat)btd_screenHeight;
+ (CGSize)btd_resolution;
+ (NSString *)btd_resolutionString;
+ (CGFloat)btd_onePixel;
+ (BTDDeviceWidthMode)btd_deviceWidthType;

// Return the total disk space (Byte) of the device.
+ (long long)btd_getTotalDiskSpace;

// Return the free disk space (Byte) of the device.
+ (long long)btd_getFreeDiskSpace;

/**
 Return YES when the process is:
    - A Mac app built with Mac Catalyst, or an iOS app running on Apple silicon.
    - Running on a Mac.
 */
+ (BOOL) btd_isMacCatalystApp;

/**
 Return YES only when the process is an iOS app running on a Mac.
 */
+ (BOOL) btd_isiOSAppOnMac;

/**
 Return YES only when the process is a Mac app built with Mac Catalyst running on a Mac.
 */
+ (BOOL) btd_isMacCatalystOnMac;

+ (BOOL) btd_isSimulatorDevice;

@end

NS_ASSUME_NONNULL_END
