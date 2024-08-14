//
//  UIDevice+BTDAdditions.m
//  Article
//

#import "UIDevice+BTDAdditions.h"
#import "UIWindow+BTDAdditions.h"
#import <sys/utsname.h>
#import <sys/sysctl.h>
#import <sys/socket.h>
#import <net/if.h>
#import <net/if_dl.h>
#import <mach/mach.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import "BTDMacros.h"
#import "NSArray+BTDAdditions.h"

@interface UIDevice (BTDCarrier)

+ (CTCarrier *)btd_firstAvailableCellularProvider;

@end


@implementation UIDevice (BTDAdditions)

+ (NSArray *)btd_runningProcesses
{
    static int maxArgumentSize = 0;
    if (maxArgumentSize == 0) {
        size_t size = sizeof(maxArgumentSize);
        if (sysctl((int[]){ CTL_KERN, KERN_ARGMAX }, 2, &maxArgumentSize, &size, NULL, 0) == -1) {
            perror("sysctl argument size");
            maxArgumentSize = 4096; // Default
        }
    }
    NSMutableArray *processes = [NSMutableArray array];
    int mib[3] = { CTL_KERN, KERN_PROC, KERN_PROC_ALL};
    struct kinfo_proc *info;
    size_t length;
    int count;
    
    if (sysctl(mib, 3, NULL, &length, NULL, 0) < 0)
        return nil;
    if (!(info = malloc(length)))
        return nil;
    if (sysctl(mib, 3, info, &length, NULL, 0) < 0) {
        free(info);
        return nil;
    }
    count = (int)length / sizeof(struct kinfo_proc);
    for (int i = 0; i < count; i++) {
        pid_t pid = info[i].kp_proc.p_pid;
        if (pid == 0) {
            continue;
        }
        size_t size = maxArgumentSize;
        char* buffer = (char *)malloc(length);
        if (sysctl((int[]){ CTL_KERN, KERN_PROCARGS2, pid }, 3, buffer, &size, NULL, 0) == 0) {
            NSString* executable = [NSString stringWithCString:(buffer+sizeof(int)) encoding:NSUTF8StringEncoding];
            NSURL * executableURL = [NSURL fileURLWithPath:executable isDirectory:NO];
            NSString * processName = [executableURL lastPathComponent];
            if (!BTD_isEmptyString(processName))
            {
                [processes addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                      [NSNumber numberWithInt:pid], kUIDeviceProcessID,
                                      processName, kUIDeviceProcessName,
                                      nil]];
            }
        }
        free(buffer);
    }
    
    free(info);
    
    return processes;
}

#pragma mark - basic info

+ (NSString *)getSysInfoByName:(char *)typeSpecifier
{
    size_t size;
    sysctlbyname(typeSpecifier, NULL, &size, NULL, 0);
    
    char *answer = malloc(size);
    sysctlbyname(typeSpecifier, answer, &size, NULL, 0);
    
    NSString *results = [NSString stringWithCString:answer encoding: NSUTF8StringEncoding];
    
    free(answer);
    return results;
}

+ (NSString *)btd_platform
{
    return [self getSysInfoByName:"hw.machine"];
}

+ (NSString *)btd_hwmodel
{
    return [self getSysInfoByName:"hw.model"];
}

+ (UIDevicePlatform)btd_platformType
{
    NSString *platform = [self btd_platform];
    
    return [self _btd_platformTypeForPlatform:platform];
}

+ (UIDevicePlatform)_btd_platformTypeForPlatform:(NSString *)platform {
    // The ever mysterious iFPGA
    if ([platform isEqualToString:@"iFPGA"])        return UIDeviceIFPGA;
    
    // iPhone
    if ([platform isEqualToString:@"iPhone1,1"])    return UIDevice1GiPhone;
    if ([platform isEqualToString:@"iPhone1,2"])    return UIDevice3GiPhone;
    if ([platform hasPrefix:@"iPhone2"])            return UIDevice3GSiPhone;
    if ([platform hasPrefix:@"iPhone3"])            return UIDevice4iPhone;
    if ([platform hasPrefix:@"iPhone4"])            return UIDevice4siPhone;
    if ([platform isEqualToString:@"iPhone5,1"])    return UIDevice5GSMiPhone;
    if ([platform isEqualToString:@"iPhone5,2"])    return UIDevice5GlobaliPhone;
    if ([platform isEqualToString:@"iPhone5,3"] || [platform isEqualToString:@"iPhone5,4"])    return UIDevice5CiPhone;
    if ([platform isEqualToString:@"iPhone6,1"] || [platform isEqualToString:@"iPhone6,2"])    return UIDevice5SiPhone;
    if ([platform isEqualToString:@"iPhone7,1"])    return UIDevice6PlusiPhone;
    if ([platform isEqualToString:@"iPhone7,2"])    return UIDevice6iPhone;
    if ([platform isEqualToString:@"iPhone8,1"])    return UIDevice6SiPhone;
    if ([platform isEqualToString:@"iPhone8,2"])    return UIDevice6SPlusiPhone;
    if ([platform isEqualToString:@"iPhone8,4"])    return UIDeviceSEiPhone;
    if ([platform isEqualToString:@"iPhone9,1"])    return UIDevice7_1iPhone;
    if ([platform isEqualToString:@"iPhone9,3"])    return UIDevice7_3iPhone;
    if ([platform isEqualToString:@"iPhone9,2"])    return UIDevice7_2PlusiPhone;
    if ([platform isEqualToString:@"iPhone9,4"])    return UIDevice7_4PlusiPhone;
    if ([platform isEqualToString:@"iPhone10,1"])    return UIDevice8iPhone;
    if ([platform isEqualToString:@"iPhone10,4"])    return UIDevice8iPhone;
    if ([platform isEqualToString:@"iPhone10,2"])    return UIDevice8PlusiPhone;
    if ([platform isEqualToString:@"iPhone10,5"])    return UIDevice8PlusiPhone;
    if ([platform isEqualToString:@"iPhone10,3"])    return UIDeviceXiPhone;
    if ([platform isEqualToString:@"iPhone10,6"])    return UIDeviceXiPhone;
    if ([platform isEqualToString:@"iPhone11,2"])    return UIDeviceXSiPhone;
    if ([platform isEqualToString:@"iPhone11,4"] || [platform isEqualToString:@"iPhone11,6"])    return UIDeviceXSMaxiPhone;
    if ([platform isEqualToString:@"iPhone11,8"])    return UIDeviceXRiPhone;
    if ([platform isEqualToString:@"iPhone12,1"])    return UIDevice11iPhone;
    if ([platform isEqualToString:@"iPhone12,3"])    return UIDevice11ProiPhone;
    if ([platform isEqualToString:@"iPhone12,5"])    return UIDevice11ProMaxiPhone;
    if ([platform isEqualToString:@"iPhone13,1"])    return UIDevice12MiniiPhone;
    if ([platform isEqualToString:@"iPhone13,2"])    return UIDevice12iPhone;
    if ([platform isEqualToString:@"iPhone13,3"])    return UIDevice12ProiPhone;
    if ([platform isEqualToString:@"iPhone13,4"])    return UIDevice12ProMaxiPhone;
    if ([platform isEqualToString:@"iPhone12,8"])    return UIDeviceSE2iPhone;
    if ([platform isEqualToString:@"iPhone14,4"])    return UIDevice13MiniiPhone;
    if ([platform isEqualToString:@"iPhone14,5"])    return UIDevice13iPhone;
    if ([platform isEqualToString:@"iPhone14,2"])    return UIDevice13ProiPhone;
    if ([platform isEqualToString:@"iPhone14,3"])    return UIDevice13ProMaxiPhone;
    if ([platform isEqualToString:@"iPhone14,6"])    return UIDeviceSE3iPhone;
    if ([platform isEqualToString:@"iPhone14,7"])    return UIDevice14iPhone;
    if ([platform isEqualToString:@"iPhone14,8"])    return UIDevice14PlusiPhone;
    if ([platform isEqualToString:@"iPhone15,2"])    return UIDevice14ProiPhone;
    if ([platform isEqualToString:@"iPhone15,3"])    return UIDevice14ProMaxiPhone;
    
    if ([platform isEqualToString:@"iPhone15,4"])    return UIDevice15iPhone;
    if ([platform isEqualToString:@"iPhone15,5"])    return UIDevice15PlusiPhone;
    if ([platform isEqualToString:@"iPhone16,1"])    return UIDevice15ProiPhone;
    if ([platform isEqualToString:@"iPhone16,2"])    return UIDevice15ProMaxiPhone;
    
    
    // iPod
    if ([platform hasPrefix:@"iPod1"])              return UIDevice1GiPod;
    if ([platform hasPrefix:@"iPod2"])              return UIDevice2GiPod;
    if ([platform hasPrefix:@"iPod3"])              return UIDevice3GiPod;
    if ([platform hasPrefix:@"iPod4"])              return UIDevice4GiPod;
    if ([platform hasPrefix:@"iPod5"])              return UIDevice5GiPod;
    if ([platform isEqualToString:@"iPod7,1"])      return UIDevice6GiPod;
    if ([platform isEqualToString:@"iPod9,1"])      return UIDevice7GiPod;
    
    // iPad
    if ([platform hasPrefix:@"iPad1,"])              return UIDevice1GiPad;
    if ([platform hasPrefix:@"iPad2,5"] || [platform hasPrefix:@"iPad2,6"] || [platform hasPrefix:@"iPad2,7"])            return UIDeviceiPadMini;
    if ([platform hasPrefix:@"iPad2,1"] || [platform hasPrefix:@"iPad2,2"] || [platform hasPrefix:@"iPad2,3"] || [platform hasPrefix:@"iPad2,4"])              return UIDevice2GiPad;
    if ([platform isEqualToString:@"iPad3,1"] || [platform isEqualToString:@"iPad3,2"] || [platform isEqualToString:@"iPad3,3"])    return UIDevice3GiPad;
    if ([platform isEqualToString:@"iPad3,4"] || [platform isEqualToString:@"iPad3,5"] || [platform isEqualToString:@"iPad3,6"])    return UIDevice4GiPad;
    if ([platform isEqualToString:@"iPad6,11"] || [platform isEqualToString:@"iPad6,12"])    return UIDevice5GiPad;
    if ([platform isEqualToString:@"iPad7,5"] || [platform isEqualToString:@"iPad7,6"])    return UIDevice6GiPad;
    if ([platform isEqualToString:@"iPad7,11"] || [platform isEqualToString:@"iPad7,12"])    return UIDevice7GiPad;
    if ([platform isEqualToString:@"iPad11,6"] || [platform isEqualToString:@"iPad11,7"])    return UIDevice8GiPad;
    if ([platform isEqualToString:@"iPad12,1"] || [platform isEqualToString:@"iPad12,2"])    return UIDevice9GiPad;
    
    // ipad air
    if ([platform isEqualToString:@"iPad4,1"] || [platform isEqualToString:@"iPad4,2"] || [platform isEqualToString:@"iPad4,3"])    return UIDeviceAiriPad;
    if ([platform isEqualToString:@"iPad5,3"] || [platform isEqualToString:@"iPad5,4"])    return UIDeviceAir2iPad;
    if ([platform isEqualToString:@"iPad11,3"] || [platform isEqualToString:@"iPad11,4"])    return UIDeviceAir3iPad;
    if ([platform isEqualToString:@"iPad13,1"] || [platform isEqualToString:@"iPad13,2"])    return UIDeviceAir4iPad;
    
    // ipad mini
    if ([platform isEqualToString:@"iPad4,4"] || [platform isEqualToString:@"iPad4,5"])    return UIDeviceiPadMiniRetina;
    if ([platform isEqualToString:@"iPad4,4"] || [platform isEqualToString:@"iPad4,5"] || [platform isEqualToString:@"iPad4,6"])    return UIDeviceiPadMini2;
    if ([platform isEqualToString:@"iPad4,7"] || [platform isEqualToString:@"iPad4,8"] || [platform isEqualToString:@"iPad4,9"])    return UIDeviceiPadMini3;
    if ([platform isEqualToString:@"iPad5,1"] || [platform isEqualToString:@"iPad5,2"])    return UIDeviceiPadMini4;
    if ([platform isEqualToString:@"iPad11,1"] || [platform isEqualToString:@"iPad11,2"])    return UIDeviceiPadMini5;
    if ([platform isEqualToString:@"iPad14,1"] || [platform isEqualToString:@"iPad14,2"])    return UIDeviceiPadMini6;
    
    // ipad pro
    if ([platform isEqualToString:@"iPad6,7"] || [platform isEqualToString:@"iPad6,8"] || [platform isEqualToString:@"iPad6,3"] || [platform isEqualToString:@"iPad6,4"] || [platform isEqualToString:@"iPad7,3"] || [platform isEqualToString:@"iPad7,4"] || [platform isEqualToString:@"iPad8,1"] || [platform isEqualToString:@"iPad8,2"] || [platform isEqualToString:@"iPad8,3"] || [platform isEqualToString:@"iPad8,4"]) return UIDeviceiPadPro;
    if ([platform isEqualToString:@"iPad7,1"] || [platform isEqualToString:@"iPad7,2"] || [platform isEqualToString:@"iPad8,9"] || [platform isEqualToString:@"iPad8,10"]) return UIDeviceiPadPro2;
    if ([platform isEqualToString:@"iPad8,5"] || [platform isEqualToString:@"iPad8,6"] || [platform isEqualToString:@"iPad8,7"] || [platform isEqualToString:@"iPad8,8"] || [platform isEqualToString:@"iPad13,4"] || [platform isEqualToString:@"iPad13,5"] || [platform isEqualToString:@"iPad13,6"] || [platform isEqualToString:@"iPad13,7"]) return UIDeviceiPadPro3;
    if ([platform isEqualToString:@"iPad8,11"] || [platform isEqualToString:@"iPad8,12"]) return UIDeviceiPadPro4;
    if ([platform isEqualToString:@"iPad13,8"] || [platform isEqualToString:@"iPad13,9"] || [platform isEqualToString:@"iPad13,10"] || [platform isEqualToString:@"iPad13,11"]) return UIDeviceiPadPro5;
    
    
    if ([platform isEqualToString:@"iPad6,7"] || [platform isEqualToString:@"iPad6,8"] ||
        [platform isEqualToString:@"iPad13,8"] || [platform isEqualToString:@"iPad13,9"] || [platform isEqualToString:@"iPad13,10"] || [platform isEqualToString:@"iPad13,11"]){
        return UIDeviceiPadPro;
    }
    
    // apple vision pro
    if ([platform isEqualToString:@"RealityDevice14,1"]){
        return UIDeviceiAppleVisionPro;
    }
    
    // Apple TV
    if ([platform hasPrefix:@"AppleTV2"])           return UIDeviceAppleTV2;
    
    if ([platform hasPrefix:@"iPhone"])             return UIDeviceUnknowniPhone;
    if ([platform hasPrefix:@"iPod"])               return UIDeviceUnknowniPod;
    if ([platform hasPrefix:@"iPad"])               return UIDeviceUnknowniPad;
    
    // Simulator
    if ([platform hasSuffix:@"86"] || [platform isEqual:@"x86_64"] || [platform isEqualToString:@"arm64"])
    {
        NSString *model = [UIDevice currentDevice].model.lowercaseString;
        if ([model containsString:@"iphone"]) {
            return UIDeviceiPhoneSimulatoriPhone;
        } else if ([model containsString:@"ipad"]) {
            return UIDeviceiPhoneSimulatoriPad;
        } else if ([model containsString:@"apple vision pro"]) {
            return UIDeviceiPhoneSimulatoriAppleVisionPro;
        }
    }
    
    return UIDeviceUnknown;
}

+ (NSString *)btd_platformName {
    return [UIDevice currentDevice].model;
}

+ (NSString *)btd_platformString {
    return [self _btd_platformStringForPlatformType:[self btd_platformType]];
}

+ (NSString *)_btd_platformStringForPlatformType:(UIDevicePlatform)platformType
{
    switch (platformType)
    {
        case UIDevice1GiPhone: return IPHONE_1G_NAMESTRING;
        case UIDevice3GiPhone: return IPHONE_3G_NAMESTRING;
        case UIDevice3GSiPhone: return IPHONE_3GS_NAMESTRING;
        case UIDevice4iPhone: return IPHONE_4_NAMESTRING;
        case UIDevice4siPhone: return IPHONE_4S_NAMESTRING;
        case UIDevice5GSMiPhone: return IPHONE_5GSM_NAMESTRING;
        case UIDevice5GlobaliPhone: return IPHONE_5Global_NAMESTRING;
        case UIDevice5CiPhone:  return IPHONE_5C_NAMESTRING;
        case UIDevice5SiPhone: return IPHONE_5S_NAMESTRING;
        case UIDevice6iPhone: return IPHONE_6_NAMESTRING;
        case UIDevice6PlusiPhone: return IPHONE_6_PLUS_NAMESTRING;
        case UIDevice6SiPhone: return IPHONE_6S_NAMESTRING;
        case UIDevice6SPlusiPhone: return IPHONE_6S_PLUS_NAMESTRING;
        case UIDeviceSEiPhone: return IPHONE_SE;
        case UIDevice7_1iPhone: return IPHONE_7_NAMESTRING;
        case UIDevice7_3iPhone: return IPHONE_7_NAMESTRING;
        case UIDevice7_2PlusiPhone: return IPHONE_7_PLUS_NAMESTRING;
        case UIDevice7_4PlusiPhone: return IPHONE_7_PLUS_NAMESTRING;
        case UIDevice8iPhone: return  IPHONE_8_NAMESTRING;
        case UIDevice8PlusiPhone: return  IPHONE_8_PLUS_NAMESTRING;
        case UIDeviceXiPhone: return  IPHONE_X_NAMESTRING;
        case UIDeviceXSiPhone: return  IPHONE_XS_NAMESTRING;
        case UIDeviceXSMaxiPhone: return  IPHONE_XS_MAX_NAMESTRING;
        case UIDeviceXRiPhone: return  IPHONE_XR_NAMESTRING;
        case UIDevice11iPhone: return  IPHONE_11_NAMESTRING;
        case UIDevice11ProiPhone: return  IPHONE_11_PRO_NAMESTRING;
        case UIDevice11ProMaxiPhone: return  IPHONE_11_PRO_MAX_NAMESTRING;
        case UIDevice12MiniiPhone: return IPHONE_12_MINI_NAMESTRING;
        case UIDevice12iPhone: return IPHONE_12_NAMESTRING;
        case UIDevice12ProiPhone: return IPHONE_12_PRO_NAMESTRING;
        case UIDevice12ProMaxiPhone: return IPHONE_12_PRO_MAX_NAMESTRING;
        case UIDeviceSE2iPhone: return IPHONE_SE_2_NAMESTRING;
        case UIDevice13MiniiPhone: return IPHONE_13_MINI_NAMESTRING;
        case UIDevice13iPhone: return IPHONE_13_NAMESTRING;
        case UIDevice13ProiPhone: return IPHONE_13_PRO_NAMESTRING;
        case UIDevice13ProMaxiPhone: return IPHONE_13_PRO_MAX_NAMESTRING;
        case UIDeviceSE3iPhone: return IPHONE_SE_3_NAMESTRING;
        case UIDevice14iPhone: return IPHONE_14_NAMESTRING;
        case UIDevice14PlusiPhone: return IPHONE_14_PLUS_NAMESTRING;
        case UIDevice14ProiPhone: return IPHONE_14_PRO_NAMESTRING;
        case UIDevice14ProMaxiPhone: return IPHONE_14_PRO_MAX_NAMESTRING;
        case UIDevice15iPhone: return IPHONE_15_NAMESTRING;
        case UIDevice15PlusiPhone: return IPHONE_15_PLUS_NAMESTRING;
        case UIDevice15ProiPhone: return IPHONE_15_PRO_NAMESTRING;
        case UIDevice15ProMaxiPhone: return IPHONE_15_PRO_MAX_NAMESTRING;
            
        case UIDeviceUnknowniPhone: return [self btd_platform];
            
        case UIDevice1GiPod: return IPOD_1G_NAMESTRING;
        case UIDevice2GiPod: return IPOD_2G_NAMESTRING;
        case UIDevice3GiPod: return IPOD_3G_NAMESTRING;
        case UIDevice4GiPod: return IPOD_4G_NAMESTRING;
        case UIDevice5GiPod: return IPOD_5G_NAMESTRING;
        case UIDevice6GiPod: return IPOD_6G_NAMESTRING;
        case UIDevice7GiPod: return IPOD_7G_NAMESTRING;
        case UIDeviceUnknowniPod: return [self btd_platform];
            
        case UIDevice1GiPad : return IPAD_1G_NAMESTRING;
        case UIDevice2GiPad : return IPAD_2G_NAMESTRING;
        case UIDevice3GiPad : return IPAD_3G_NAMESTRING;
        case UIDevice4GiPad : return IPAD_4G_NAMESTRING;
        case UIDevice5GiPad : return IPAD_5G_NAMESTRING;
        case UIDevice6GiPad : return IPAD_6G_NAMESTRING;
        case UIDevice7GiPad : return IPAD_7G_NAMESTRING;
        case UIDevice8GiPad : return IPAD_8G_NAMESTRING;
        case UIDevice9GiPad : return IPAD_9G_NAMESTRING;
            
        case UIDeviceAiriPad : return IPAD_AIR_NAMESTRING;
        case UIDeviceAir2iPad : return IPAD_AIR_2_NAMESTRING;
        case UIDeviceAir3iPad : return IPAD_AIR_3_NAMESTRING;
        case UIDeviceAir4iPad : return IPAD_AIR_4_NAMESTRING;
        
        case UIDeviceiPadMini: return IPAD_MINI_NAMESTRING;
        case UIDeviceiPadMiniRetina: return IPAD_MINI_Retina_NAMESTRING;
        case UIDeviceiPadMini2: return IPAD_MINI_2_NAMESTRING;
        case UIDeviceiPadMini3: return IPAD_MINI_3_NAMESTRING;
        case UIDeviceiPadMini4: return IPAD_MINI_4_NAMESTRING;
        case UIDeviceiPadMini5: return IPAD_MINI_5_NAMESTRING;
        case UIDeviceiPadMini6: return IPAD_MINI_6_NAMESTRING;
            
        case UIDeviceiPadPro: return IPAD_PRO_NAMESTRING;
        case UIDeviceiPadPro2: return IPAD_PRO_2_NAMESTRING;
        case UIDeviceiPadPro3: return IPAD_PRO_3_NAMESTRING;
        case UIDeviceiPadPro4: return IPAD_PRO_4_NAMESTRING;
        case UIDeviceiPadPro5: return IPAD_PRO_5_NAMESTRING;
            
        case UIDeviceUnknowniPad : return [self btd_platform];
            
        case UIDeviceAppleTV2 : return APPLETV_2G_NAMESTRING;
        case UIDeviceUnknownAppleTV: return APPLETV_UNKNOWN_NAMESTRING;
            
        case UIDeviceiAppleVisionPro: return APPLE_VISION_PRO_NAMESTRING;
            
        case UIDeviceiPhoneSimulator: return IPHONE_SIMULATOR_NAMESTRING;
        case UIDeviceiPhoneSimulatoriPhone: return IPHONE_SIMULATOR_IPHONE_NAMESTRING;
        case UIDeviceiPhoneSimulatoriPad: return IPHONE_SIMULATOR_IPAD_NAMESTRING;
        case UIDeviceiPhoneSimulatoriAppleVisionPro: return APPLE_VISION_PRO_SIMULATOR_NAMESTRING;
            
        case UIDeviceIFPGA: return IFPGA_NAMESTRING;
            
        default: return [self btd_platform];
    }
}

+ (NSString *)btd_platformStringWithSimulatorType {
    UIDevicePlatform platformType = [self btd_platformType];
    if (platformType == UIDeviceiPhoneSimulatoriPhone ||
        platformType == UIDeviceiPhoneSimulatoriPad) {
        NSDictionary<NSString *, NSString *> *environment = [[NSProcessInfo processInfo] environment];
        NSString *platform = [environment objectForKey:@"SIMULATOR_MODEL_IDENTIFIER"];
        platformType = [self _btd_platformTypeForPlatform:platform];
    }
    
    return [self _btd_platformStringForPlatformType:platformType];
}


+ (NSString*)btd_OSVersion
{
    return [[UIDevice currentDevice] systemVersion];
}

+ (float)btd_OSVersionNumber {
    return [[self btd_OSVersion] floatValue];
}

+ (NSString *)btd_currentLanguage
{
    return [[NSLocale preferredLanguages] objectAtIndex:0];
}

+ (NSString *)btd_currentRegion
{
    return [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode];
}

+ (BOOL)btd_isJailBroken
{
    NSString *filePath = @"/Applications/Cydia.app";
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        return YES;
    }
    
    filePath = @"/private/var/lib/apt";
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        return YES;
    }
    
    return NO;
}

+ (NSString *)btd_carrierName
{
    CTCarrier *carrier = [UIDevice btd_firstAvailableCellularProvider];
    if (![carrier mobileCountryCode]) {
        return nil;
    }
    NSString *name = [carrier carrierName];
    return name;
}

+ (NSString *)btd_carrierMCC
{
    CTCarrier *carrier = [UIDevice btd_firstAvailableCellularProvider];
    NSString *mcc = [carrier mobileCountryCode];
    return mcc;
}

+ (NSString *)btd_carrierMNC
{
    CTCarrier *carrier = [UIDevice btd_firstAvailableCellularProvider];
    NSString *mnc = [carrier mobileNetworkCode];
    return mnc;
}

+ (BOOL)btd_poorDevice
{
    NSString *platformStr = [self btd_platform];
    BOOL isPoor = NO;
    if ([platformStr hasPrefix:@"iPhone"]){
        platformStr = [platformStr substringFromIndex:6];
        int version;
        [[NSScanner scannerWithString:platformStr]scanInt:&version];
        if (version <= 5){
            isPoor = YES;
        }
    }
    else if ([platformStr hasPrefix:@"iPod"] || [platformStr hasPrefix:@"iPad"]) {
        isPoor = YES;
    }
    
    return isPoor;
}

#pragma mark - screen

+ (CGFloat)btd_screenScale
{
    return [[UIScreen mainScreen] scale];
}

#define BTD_IS_SCREEN(screen) \
    CGSize size = [UIScreen mainScreen].bounds.size; \
    CGFloat len = MAX(size.height, size.width); \
    return (int)len == screen;

+ (BOOL)btd_is480Screen
{
    BTD_IS_SCREEN(480);
}


+ (BOOL)btd_is568Screen
{
    BTD_IS_SCREEN(568);
}

+ (BOOL)btd_is667Screen
{
    BTD_IS_SCREEN(667);
}

+ (BOOL)btd_is736Screen {
    BTD_IS_SCREEN(736);
}

+ (BOOL)btd_is812Screen {
    BTD_IS_SCREEN(812);
}

+ (BOOL)btd_is844Screen{
    BTD_IS_SCREEN(844);
}

+ (BOOL)btd_is852Screen {
    BTD_IS_SCREEN(852);
}

+ (BOOL)btd_is896Screen {
    BTD_IS_SCREEN(896);
}

+ (BOOL)btd_is926Screen{
    BTD_IS_SCREEN(926);
}

+ (BOOL)btd_is932Screen {
    BTD_IS_SCREEN(932);
}

+ (BOOL)btd_isScreenWidthLarge320 {
    CGSize size = [UIScreen mainScreen].bounds.size;
    CGFloat len = MIN(size.height, size.width);
    return (int)len > 320;
}

// iPhone X Series.
+ (BOOL)btd_isScreenHeightLarge736 {
    CGSize size = [UIScreen mainScreen].bounds.size;
    CGFloat len = MAX(size.height, size.width);
    return (int)len > 736;
}

static BOOL iPhoneXSeries = NO;
static dispatch_semaphore_t iPhoneXSeriesLock;
+ (BOOL)_iPhoneXSeries {
    BOOL result = NO;
    dispatch_semaphore_wait(iPhoneXSeriesLock, DISPATCH_TIME_FOREVER);
    result = iPhoneXSeries;
    dispatch_semaphore_signal(iPhoneXSeriesLock);
    return result;
}
+ (void)_setIPhoneXSeries:(BOOL)_iPhoneXSeries {
    dispatch_semaphore_wait(iPhoneXSeriesLock, DISPATCH_TIME_FOREVER);
    iPhoneXSeries = _iPhoneXSeries;
    dispatch_semaphore_signal(iPhoneXSeriesLock);
}

static BOOL executedToken = NO;
static dispatch_semaphore_t executedTokenLock;
+ (BOOL)_executedToken {
    BOOL result = NO;
    dispatch_semaphore_wait(executedTokenLock, DISPATCH_TIME_FOREVER);
    result = executedToken;
    dispatch_semaphore_signal(executedTokenLock);
    return result;
}
+ (void)_setExecutedToken:(BOOL)_executedToken {
    dispatch_semaphore_wait(executedTokenLock, DISPATCH_TIME_FOREVER);
    executedToken = _executedToken;
    dispatch_semaphore_signal(executedTokenLock);
}

+ (BOOL)btd_isIPhoneXSeries {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        iPhoneXSeriesLock = dispatch_semaphore_create(1);
        executedTokenLock = dispatch_semaphore_create(1);
    });
    if (![self _executedToken]) {
        if ([self _isIPhoneXSeriesForTheRealPhone] || [self _isIPhoneXSeriesForSimulator] ||
            ([[UIDevice currentDevice].model isEqualToString: @"iPhone"] && [self btd_isScreenHeightLarge736])) {
            [self _setIPhoneXSeries:YES];
        }
        [self _setExecutedToken:YES];
    }
    return [self _iPhoneXSeries];
}

+ (BOOL)btd_isNotchScreenSeries {
    static BOOL isNotchScreenSeries = NO;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        NSString *platform = [self btd_platformStringWithSimulatorType];
        if ([platform isEqualToString:IPHONE_X_NAMESTRING] ||
            [platform isEqualToString:IPHONE_XS_NAMESTRING] ||
            [platform isEqualToString:IPHONE_XS_MAX_NAMESTRING] ||
            [platform isEqualToString:IPHONE_XR_NAMESTRING] ||
            [platform isEqualToString:IPHONE_11_NAMESTRING] ||
            [platform isEqualToString:IPHONE_11_PRO_NAMESTRING] ||
            [platform isEqualToString:IPHONE_11_PRO_MAX_NAMESTRING] ||
            [platform isEqualToString:IPHONE_12_MINI_NAMESTRING] ||
            [platform isEqualToString:IPHONE_12_NAMESTRING] ||
            [platform isEqualToString:IPHONE_12_PRO_NAMESTRING] ||
            [platform isEqualToString:IPHONE_12_PRO_MAX_NAMESTRING] ||
            [platform isEqualToString:IPHONE_13_MINI_NAMESTRING] ||
            [platform isEqualToString:IPHONE_13_NAMESTRING] ||
            [platform isEqualToString:IPHONE_13_PRO_NAMESTRING] ||
            [platform isEqualToString:IPHONE_13_PRO_MAX_NAMESTRING] ||
            [platform isEqualToString:IPHONE_14_NAMESTRING] ||
            [platform isEqualToString:IPHONE_14_PLUS_NAMESTRING] ) {
            isNotchScreenSeries = YES;
        }
    });
    return isNotchScreenSeries;
}

+ (BOOL)btd_isDynamicIslandSeries {
    static BOOL isDynamicIslandSeries = NO;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        NSString *platform = [self btd_platformStringWithSimulatorType];
        if ([platform isEqualToString:IPHONE_14_PRO_NAMESTRING] ||
            [platform isEqualToString:IPHONE_14_PRO_MAX_NAMESTRING] ||
            [platform isEqualToString:IPHONE_15_NAMESTRING] ||
            [platform isEqualToString:IPHONE_15_PLUS_NAMESTRING] ||
            [platform isEqualToString:IPHONE_15_PRO_NAMESTRING] ||
            [platform isEqualToString:IPHONE_15_PRO_MAX_NAMESTRING]) {
            isDynamicIslandSeries = YES;
        }
    });
    return isDynamicIslandSeries;
}

+ (BOOL)_isIPhoneXSeriesForTheRealPhone{
    BOOL iPhoneXSeries = NO;
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *platform = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    if ([platform isEqualToString:@"iPhone10,3"] 
        || [platform isEqualToString:@"iPhone10,6"]
        || [platform isEqualToString:@"iPhone11,8"]
        || [platform isEqualToString:@"iPhone11,2"]
        || [platform isEqualToString:@"iPhone11,4"]
        || [platform isEqualToString:@"iPhone11,6"]
        || [platform isEqualToString:@"iPhone12,1"]
        || [platform isEqualToString:@"iPhone12,3"]
        || [platform isEqualToString:@"iPhone12,5"]
        || [platform isEqualToString:@"iPhone13,1"]
        || [platform isEqualToString:@"iPhone13,2"]
        || [platform isEqualToString:@"iPhone13,3"]
        || [platform isEqualToString:@"iPhone13,4"]
        || [platform isEqualToString:@"iPhone14,4"]
        || [platform isEqualToString:@"iPhone14,5"]
        || [platform isEqualToString:@"iPhone14,2"]
        || [platform isEqualToString:@"iPhone14,3"]
        || [platform isEqualToString:@"iPhone14,7"] 
        || [platform isEqualToString:@"iPhone14,8"]
        || [platform isEqualToString:@"iPhone15,2"]
        || [platform isEqualToString:@"iPhone15,3"]
        || [platform isEqualToString:@"iPhone15,4"]
        || [platform isEqualToString:@"iPhone15,5"]
        || [platform isEqualToString:@"iPhone16,1"]
        || [platform isEqualToString:@"iPhone16,2"]) {
        iPhoneXSeries = YES;
    }
    return iPhoneXSeries;
}

+ (BOOL)_isIPhoneXSeriesForSimulator{
    __block BOOL iPhoneXSeries = NO;
    if ([[UIDevice currentDevice].model isEqualToString: @"iPhone"]) {
        if (@available(iOS 11.0, *)) {
            if ([NSThread isMainThread]){
                UIWindow *window = [UIDevice btd_mainWindow];
                if (window.safeAreaInsets.bottom > 0.0) {
                    iPhoneXSeries = YES;
                }
                return iPhoneXSeries;
            }
            else{
                dispatch_semaphore_t sem = dispatch_semaphore_create(0);
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIWindow *window = [UIDevice btd_mainWindow];
                    if (window.safeAreaInsets.bottom > 0.0) {
                        iPhoneXSeries = YES;
                    }
                    dispatch_semaphore_signal(sem);
                });
                dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
                return iPhoneXSeries;
            }
        }
    }
    return iPhoneXSeries;
}

+ (UIWindow *)btd_mainWindow NS_EXTENSION_UNAVAILABLE("Not available in Extension Target")
{
    UIWindow * window = nil;
    if ([[UIApplication sharedApplication].delegate respondsToSelector:@selector(window)]) {
        window = [[UIApplication sharedApplication].delegate window];
    }
    if (![window isKindOfClass:[UIView class]]) {
        window = [UIWindow btd_keyWindow];
    }
    if (!window) {
        window = [[UIApplication sharedApplication].windows firstObject];
    }
    return window;
}

+ (CGSize)btd_screenSize
{
    return [UIScreen mainScreen].bounds.size;
}

+ (CGFloat)btd_screenWidth
{
    return [UIScreen mainScreen].bounds.size.width;
}

+ (CGFloat)btd_screenHeight
{
    return [UIScreen mainScreen].bounds.size.height;
}

+ (BOOL)btd_isPadDevice {
    return [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad;
}

+ (CGSize)btd_resolution
{
    CGSize screenBoundsSize = [UIScreen mainScreen].bounds.size;
    float scale = [[UIScreen mainScreen] scale];
    CGSize resolution = CGSizeMake(screenBoundsSize.width * scale, screenBoundsSize.height * scale);
    
    return resolution;
}

+ (NSString *)btd_resolutionString {
    CGSize resolution = [self btd_resolution];
    return [NSString stringWithFormat:@"%d*%d", (int)resolution.width, (int)resolution.height];
}

+ (CGFloat)btd_onePixel
{
    float scale = [[UIScreen mainScreen] scale];
    if (scale == 1) return 1.f;
    if (scale == 3) return .333f;
    return 0.5f;
}

+ (BTDDeviceWidthMode)btd_deviceWidthType {
      static BTDDeviceWidthMode tt_deviceWithType = BTDDeviceWidthMode375;
      static dispatch_once_t onceToken;
      dispatch_once(&onceToken, ^{
          if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
              tt_deviceWithType = BTDDeviceWidthModePad;
          } else {
              NSInteger portraitWidth = (NSInteger)MIN([UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
              if (portraitWidth == 320) {
                  tt_deviceWithType = BTDDeviceWidthMode320;
              } else if (portraitWidth == 375) {
                  tt_deviceWithType = BTDDeviceWidthMode375;
              } else if (portraitWidth == 390){
                  tt_deviceWithType = BTDDeviceWidthMode390;
              } else if (portraitWidth == 414) {
                  tt_deviceWithType = BTDDeviceWidthMode414;
              } else if (portraitWidth == 428){
                  tt_deviceWithType = BTDDeviceWidthMode428;
              } else if (portraitWidth == 393) {
                  tt_deviceWithType = BTDDeviceWidthMode393;
              } else if (portraitWidth == 430) {
                  tt_deviceWithType = BTDDeviceWidthMode430;
              } else {
                  tt_deviceWithType = BTDDeviceWidthMode375;
                  NSAssert(false, @"Need to fit new screen size!");
              }
          }
      });
      
      return tt_deviceWithType;
    
}

+ (long long)btd_getTotalDiskSpace {
    float totalSpace;
    NSError * error;
    NSDictionary * infoDic = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:&error];
    if (infoDic) {
        NSNumber * fileSystemSizeInBytes = [infoDic objectForKey:NSFileSystemSize];
        totalSpace = [fileSystemSizeInBytes longLongValue];
        return totalSpace;
    } else {
        return 0;
    }
}

+ (long long)btd_getFreeDiskSpace {
    float totalFreeSpace;
    NSError * error;
    NSDictionary * infoDic = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:&error];
    if (infoDic) {
        NSNumber * fileSystemSizeInBytes = [infoDic objectForKey:NSFileSystemFreeSize];
        totalFreeSpace = [fileSystemSizeInBytes longLongValue];
        return totalFreeSpace;
    } else {
        return 0;
    }
}

+ (BOOL)btd_isMacCatalystApp {
    BOOL isMacCatalystApp = NO;
    if (@available(iOS 13.0, macOS 10.15,  *)) {
        isMacCatalystApp =  [NSProcessInfo.processInfo isMacCatalystApp];
    }
    return isMacCatalystApp;
}

+ (BOOL)btd_isiOSAppOnMac {
    BOOL isiOSAppOnMac = NO;
    if (@available(iOS 14.0, macOS 11.0, *)) {
        isiOSAppOnMac = [NSProcessInfo.processInfo respondsToSelector:@selector(isiOSAppOnMac)] ? [NSProcessInfo.processInfo isiOSAppOnMac] : NO;
    }
    return isiOSAppOnMac;
}

+ (BOOL)btd_isMacCatalystOnMac {
    return [self btd_isMacCatalystApp] && ![self btd_isiOSAppOnMac];
}

+ (BOOL)btd_isSimulatorDevice {
    UIDevicePlatform platformType = [self btd_platformType];
    return platformType == UIDeviceiPhoneSimulator || platformType == UIDeviceiPhoneSimulatoriPhone || platformType == UIDeviceiPhoneSimulatoriPad;
}

@end

@implementation UIDevice (BTDCarrier)

static dispatch_semaphore_t gBTDDeviceNetworkInfoLock;
static CTTelephonyNetworkInfo *gBTDDeviceNetworkInfo;

__attribute__((always_inline)) CTTelephonyNetworkInfo* kGetNetworkInfo(void) {
    CTTelephonyNetworkInfo *networkInfo = nil;
    dispatch_semaphore_wait(gBTDDeviceNetworkInfoLock, DISPATCH_TIME_FOREVER);
    networkInfo = gBTDDeviceNetworkInfo;
    dispatch_semaphore_signal(gBTDDeviceNetworkInfoLock);
    return networkInfo;
}

__attribute__((always_inline)) void kSetNetworkInfo(CTTelephonyNetworkInfo *networkInfo) {
    dispatch_semaphore_wait(gBTDDeviceNetworkInfoLock, DISPATCH_TIME_FOREVER);
    gBTDDeviceNetworkInfo = networkInfo;
    if (@available(iOS 12.1, *)) {
        gBTDDeviceNetworkInfo.serviceSubscriberCellularProvidersDidUpdateNotifier = ^(NSString *serviceID) {
            kSetNetworkInfo([[CTTelephonyNetworkInfo alloc] init]);
        };
    } else {
        gBTDDeviceNetworkInfo.subscriberCellularProviderDidUpdateNotifier = ^(CTCarrier *carrier) {
            kSetNetworkInfo([[CTTelephonyNetworkInfo alloc] init]);
        };
    }
    dispatch_semaphore_signal(gBTDDeviceNetworkInfoLock);
}

+ (CTTelephonyNetworkInfo *)btd_networkInfo {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        gBTDDeviceNetworkInfoLock = dispatch_semaphore_create(1);
        kSetNetworkInfo([[CTTelephonyNetworkInfo alloc] init]);
    });
    return kGetNetworkInfo();
}

+ (NSArray<CTCarrier *> *)btd_currentAvailableCellularServices {
    if (@available(iOS 12.1, *)) {
        NSDictionary<NSString *, CTCarrier *> *subscriberCellularProviders = [[UIDevice btd_networkInfo].serviceSubscriberCellularProviders copy];
        NSMutableArray<CTCarrier *> *cellularProviders = [NSMutableArray arrayWithCapacity:2];
        static NSString *slot1ServiceID = @"0000000100000001";
        static NSString *slot2ServiceID = @"0000000100000002";
        [cellularProviders btd_addObject:subscriberCellularProviders[slot1ServiceID]];
        [cellularProviders btd_addObject:subscriberCellularProviders[slot2ServiceID]];
        if (cellularProviders.count == 0) {
            NSArray<CTCarrier *> *allCarrier = [subscriberCellularProviders allValues];
            return allCarrier ? allCarrier : @[];
        }
        return [cellularProviders copy];
    } else {
        CTCarrier *cellularProvider = [UIDevice btd_networkInfo].subscriberCellularProvider;
        if (cellularProvider) {
            return @[cellularProvider];
        }
    }
    return @[];
}

+ (CTCarrier *)btd_firstAvailableCellularProvider {
    NSArray<CTCarrier *> *availableCellularProviders = [self btd_currentAvailableCellularServices];
    if (availableCellularProviders.count <= 1) {
        return [availableCellularProviders firstObject];
    }
    __block CTCarrier *carrier = nil;
    [availableCellularProviders enumerateObjectsUsingBlock:^(CTCarrier * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.mobileCountryCode.length > 0) {
            carrier = obj;
            *stop = YES;
        }
    }];
    if (!carrier) {
        carrier = [availableCellularProviders firstObject];
    }
    return carrier;
}

@end
