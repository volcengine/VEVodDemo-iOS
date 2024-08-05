//
//  NSURLComponents+BTDAdditions.m
//  Pods
//

#import "NSURLComponents+BTDAdditions.h"

static NSCharacterSet *BTDURLPathAllowedCharacterSet = nil;

@interface BTDURLComponentsUtils : NSObject

@property (class, nonatomic, readonly) NSCharacterSet* URLPathAllowedCharacterSet;

@end

@implementation BTDURLComponentsUtils

+ (void)initialize {
    if (self == BTDURLComponentsUtils.class) {
        BTDURLPathAllowedCharacterSet = ({
            NSMutableCharacterSet *set = [[NSCharacterSet URLPathAllowedCharacterSet] mutableCopy];
            [set addCharactersInString:@"%"];
            set.copy;
        });
    }
}

+ (NSCharacterSet *)URLPathAllowedCharacterSet {
    return BTDURLPathAllowedCharacterSet;
}

+ (NSString *)getSchemeInURLString:(NSString *)URLString {
    if (URLString.length == 0) {
        return nil;
    }
    const char *url = [URLString UTF8String];
    const char *urlChar = url;
    size_t length = 0;
    while (urlChar && *urlChar != '\0') {
        char c = *urlChar;
        if (c == '/' || c == '?' || c == '#') {
            return nil;
        }
        if (c == ':') {
            break;
        }
        length +=1;
        urlChar++;
    }
    
    if (length == 0) {
        return nil;
    }
    
    char schemeStr[length+1];
    memmove(&schemeStr, url, length);
    schemeStr[length] = '\0';
    
    return [NSString stringWithCString:schemeStr encoding:NSUTF8StringEncoding];
}

+ (BOOL)isValidScheme:(NSString *)scheme {
    if (scheme.length == 0) {
        return YES;
    }
    const char *schemeChars = [scheme UTF8String];
    if (schemeChars && !isalpha(*schemeChars)) {
        return NO;
    }
    while (schemeChars && *schemeChars != '\0') {
        char c = *schemeChars;
        if (isalnum(c) || c == '+' || c == '-' || c =='.') {
            schemeChars++;
        } else {
            return NO;
        }
    }
    return YES;
}

@end

@implementation NSURLComponents (BTDAdditions)

+ (instancetype)btd_componentsWithString:(NSString *)URLString {
    if (URLString.length == 0) {
        return nil;
    }
    NSURLComponents *urlComponents = [NSURLComponents componentsWithString:URLString];
    if (urlComponents) {
        return urlComponents;
    }
    
    NSString *scheme = [BTDURLComponentsUtils getSchemeInURLString:URLString];
    
    /// If URLString don't have scheme or scheme is valid.
    if (scheme.length == 0 || [BTDURLComponentsUtils isValidScheme:scheme]) {
        return nil;
    }
    
    NSString *fixedURLString = [NSString stringWithFormat:@"/%@", URLString];
    NSString *URLPath = URLString;
    NSRange fragmentRange = [URLPath rangeOfString:@"#"];
    if (fragmentRange.location != NSNotFound) {
        URLPath = [URLPath substringToIndex:fragmentRange.location];
    }
    NSRange queryRange = [URLPath rangeOfString:@"?"];
    if (queryRange.location != NSNotFound) {
        URLPath = [URLPath substringToIndex:queryRange.location];
    }
    if ([URLPath stringByTrimmingCharactersInSet:BTDURLComponentsUtils.URLPathAllowedCharacterSet].length != 0) {
        return nil;
    }
    
    urlComponents = [NSURLComponents componentsWithString:fixedURLString];
    if (!urlComponents) {
        return nil;
    }
    NSString *encodedPath = urlComponents.percentEncodedPath;
    urlComponents.percentEncodedPath = encodedPath.length > 1 ? [encodedPath substringFromIndex:1] : @"";
    return urlComponents;
}

+ (instancetype)btd_componentsWithURL:(NSURL *)URL {
    if (!URL) {
        return nil;
    }
    return [self btd_componentsWithString:URL.absoluteString];
}

@end
