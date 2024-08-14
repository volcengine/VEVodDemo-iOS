//
//  NSURL+BTDAdditions.m
//  Pods
//

#import "NSURL+BTDAdditions.h"
#import "NSString+BTDAdditions.h"
#import "NSDictionary+BTDAdditions.h"
#import "BTDMacros.h"
#import "NSURLComponents+BTDAdditions.h"

static BOOL _btd_fullyEncodeURLParams = NO;
static BOOL BTDInvalidSchemeCompatible = NO;
static BOOL BTDIsURLWithStringIOS17Compatible = YES;

NSURL* BTDCreateUrl(NSString *urlString) {
    NSURL *url = nil;
    #if __clang_major__ >= 15
    url = [NSURL URLWithString:urlString];
    if (@available(iOS 17.0, *)) {
        if (NSURL.btd_isURLWithStringIOS17Compatible) {
            url = [NSURL URLWithString:urlString encodingInvalidCharacters:NO];
        }
    }
    #else
    url = [NSURL URLWithString:urlString];
    #endif
    return url;
}

@implementation NSURL (BTDAdditions)

+ (nullable instancetype)btd_URLWithString:(NSString *)str {
    return [self btd_URLWithString:str relativeToURL:nil];
}

+ (nullable instancetype)btd_URLWithString:(NSString *)str relativeToURL:(NSURL *)url {
    if (BTD_isEmptyString(str)) {
        return nil;
    }
    NSString *fixStr = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSURL *u = nil;
    if (url) {
#if __clang_major__ >= 15
        if (@available(iOS 17.0, *)) {
            if (NSURL.btd_isURLWithStringIOS17Compatible) {
                u = [NSURL URLWithString:[NSURL URLWithString:fixStr encodingInvalidCharacters:NO].absoluteString relativeToURL:url];
            } else {
                u = [NSURL URLWithString:fixStr relativeToURL:url];
            }
        } else {
            u = [NSURL URLWithString:fixStr relativeToURL:url];
        }
#else
        u = [NSURL URLWithString:fixStr relativeToURL:url];
#endif
    }
    else {
        u = BTDCreateUrl(fixStr);
    }
    if (!u) {
        //
        //Fail to construct a URL directly. Try to construct a URL with a encodedQuery.
        NSString *sourceString = fixStr;
        NSRange fragmentRange = [fixStr rangeOfString:@"#"];
        NSString *fragment = nil;
        if (fragmentRange.location != NSNotFound) {
            sourceString = [fixStr substringToIndex:fragmentRange.location];
            fragment = [fixStr substringFromIndex:fragmentRange.location];
        }
        NSArray *substrings = [sourceString componentsSeparatedByString:@"?"];
        if ([substrings count] > 1) {
            NSString *beforeQuery = [substrings objectAtIndex:0];
            NSString *queryString = [substrings objectAtIndex:1];
            NSArray *paramsList = [queryString componentsSeparatedByString:@"&"];
            NSMutableDictionary *encodedQueryParams = [NSMutableDictionary dictionary];
            [paramsList enumerateObjectsUsingBlock:^(NSString *param, NSUInteger idx, BOOL *stop){
                NSArray *keyAndValue = [param componentsSeparatedByString:@"="];
                if ([keyAndValue count] > 1) {
                    NSString *key = [keyAndValue objectAtIndex:0];
                    NSString *value = [keyAndValue objectAtIndex:1];
//                    value = [TTStringHelper recursiveDecodeForString:value];
                    [self _btd_decodeWithEncodedURLString:&value];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                    CFStringRef cfValue = (__bridge CFStringRef)value;
                    CFStringRef encodedValue = CFURLCreateStringByAddingPercentEscapes(
                                                                                       kCFAllocatorDefault,
                                                                                       cfValue,
                                                                                       NULL,
                                                                                       CFSTR(":/?#@!$&'(){}*+="),
                                                                                       kCFStringEncodingUTF8);
#pragma clang diagnostic pop
                    value = (__bridge_transfer NSString *)encodedValue;
                    [encodedQueryParams setValue:value forKey:key];
                }
            }];
            
            NSString *encodedQuery = [encodedQueryParams btd_URLQueryString];
            NSString *encodedURLString = [[[beforeQuery stringByAppendingString:@"?"] stringByAppendingString:encodedQuery] stringByAppendingString:fragment?:@""];
            
            if (url) {
                u = [NSURL URLWithString:encodedURLString relativeToURL:url];
            }
            else {
                u = BTDCreateUrl(encodedURLString);
            }
        }
        /*
         *   http://p1.meituan.net/adunion/a1c87dd93958f3e7adbeb0ecf1c5c166118613.jpg@228w|0_2_0_150az
         *   The above link does not hit the special string escaping logic. After rollbacking, try to escape again and then convert it to the URL...       --yingjie
         */
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        if (!u) {
            u = BTDCreateUrl([fixStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]);
        }
#pragma clang diagnostic pop
        
        NSAssert(u, @"Fail to construct a URL.Please be sure that url is legal and contact with the professionals.");
    }
    return u;
}

+ (void)_btd_decodeWithEncodedURLString:(NSString **)urlString
{
    if ([*urlString rangeOfString:@"%"].length == 0){
        return;
    }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    *urlString = (__bridge_transfer NSString *)(CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault, (__bridge CFStringRef)*urlString, CFSTR(""), kCFStringEncodingUTF8));
#pragma clang diagnostic pop
}

- (NSDictionary<NSString *,NSString *> *)btd_queryItems {
    NSString *query = self.query;
    if (query == nil || query.length == 0) {
        return nil;
    }
    NSMutableDictionary *result = [NSMutableDictionary new];
    NSArray *paramsList = [query componentsSeparatedByString:@"&"];
    [paramsList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSArray *keyAndValue = [obj componentsSeparatedByString:@"="];
        if ([keyAndValue count] > 1) {
            NSString *paramKey = [keyAndValue objectAtIndex:0];
            NSString *paramValue = [keyAndValue objectAtIndex:1];
            [result setValue:paramValue forKey:paramKey];
        }
    }];
    return result;
}

+ (nullable instancetype)btd_URLWithString:(NSString *)URLString queryItems:(NSDictionary *)queryItems {
    return [self btd_URLWithString:URLString queryItems:queryItems fragment:nil];
}

+ (nullable instancetype)btd_URLWithString:(NSString *)URLString queryItems:(NSDictionary *)queryItems fragment:(NSString *)fragment {
    if (URLString == nil) {
        return nil;
    }
    NSMutableString * querys = [NSMutableString stringWithCapacity:10];
    if ([queryItems count] > 0) {
        [queryItems enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[NSNumber class]]) {
                obj = [((NSNumber *)obj) stringValue];
            }
            NSString *encodedKey = [[NSString stringWithFormat:@"%@", key] btd_stringByURLEncode];
            NSString *encodedValue = [[NSString stringWithFormat:@"%@", obj] btd_stringByURLEncode];
            if (encodedKey && encodedValue) {
                [querys appendFormat:@"%@=%@", encodedKey, encodedValue];
                [querys appendString:@"&"];
            }
        }];
        if ([querys hasSuffix:@"&"]) {
            [querys deleteCharactersInRange:NSMakeRange([querys length] - 1, 1)];
        }
    }
    
    NSMutableString * resultURL = [NSMutableString stringWithString:URLString];
    if ([querys length] > 0) {
        if ([resultURL rangeOfString:@"?"].location == NSNotFound) {
            [resultURL appendString:@"?"];
        }
        else if (![resultURL hasSuffix:@"?"] && ![resultURL hasSuffix:@"&"]) {
            [resultURL appendString:@"&"];
        }
        [resultURL appendString:querys];
    }
    
    if ([fragment isKindOfClass:[NSString class]] && [fragment length] > 0) {
        [resultURL appendFormat:@"#%@", fragment];
    }
    
    NSURL * URL = [self URLWithString:resultURL];
    return URL;
}

+ (NSURL *)btd_fileURLWithPath:(NSString *)URLString {
    if (BTD_isEmptyString(URLString)) {
        return nil;
    }
    
    return [self fileURLWithPath:URLString];
}

+ (NSURL *)btd_fileURLWithPath:(NSString *)path isDirectory:(BOOL)isDir {
    if (BTD_isEmptyString(path)) {
        return nil;
    }
    
    return [self fileURLWithPath:path isDirectory:isDir];
}



- (NSDictionary<NSString *,NSString *> *)btd_queryItemsWithDecoding {
    NSURLComponents *components = [self btd_URLComponents];
    
    if (components.queryItems == nil || components.queryItems.count == 0) {
        return nil;
    }
    NSMutableDictionary *queryDict = [NSMutableDictionary new];
    for (NSURLQueryItem *item in components.queryItems) {
        queryDict[item.name] = item.value;
    }
    return [queryDict copy];
}

- (NSURL *)btd_URLByMergingQueryKey:(NSString *)key value:(NSString *)value {
    if (key && value) {
        if (!NSURL.btd_fullyEncodeURLParams) {
            return [self _btd_URLByMergingQueries:@{key: value}];
        } else {
            return [self btd_URLByMergingQueries:@{key: value} fullyEncoded:YES];
        }
    }
    return self;
}

- (NSURL *)btd_URLByMergingQueryKey:(NSString *)key value:(NSString *)value fullyEncoded:(BOOL)fullyEncoded {
    if (key && value) {
        if (!fullyEncoded) {
            return [self _btd_URLByMergingQueries:@{key: value}];
        } else {
            return [self btd_URLByMergingQueries:@{key: value} fullyEncoded:YES];
        }
    }
    return self;
}

- (NSURL *)btd_URLByMergingQueries:(NSDictionary<NSString *,NSString *> *)queries {
    if (!NSURL.btd_fullyEncodeURLParams) {
        return [self _btd_URLByMergingQueries:queries];
    } else {
        return [self btd_URLByMergingQueries:queries fullyEncoded:YES];
    }
}

- (NSURL *)btd_URLByMergingQueries:(NSDictionary<NSString *,NSString *> *)queries fullyEncoded:(BOOL)fullyEncoded {
    if (!fullyEncoded) {
        return [self _btd_URLByMergingQueries:queries];
    }
    if (queries.count == 0) {
        return self;
    }
    NSDictionary *items = [self btd_queryItemsWithDecoding] ? : @{};
    NSMutableDictionary<NSString*, NSString *> *queryItems = [items mutableCopy];
    [queries btd_forEach:^(NSString * _Nonnull key, NSString * _Nonnull obj) {
        if ([obj isKindOfClass:[NSNumber class]]) {
            queryItems[key] = [(NSNumber *)obj stringValue];
        } else if ([obj isKindOfClass:[NSString class]]) {
            queryItems[key] = obj;
        }
    }];
    NSURLComponents *components = [self btd_URLComponents];
    NSMutableArray *queryArray = [[NSMutableArray alloc] initWithCapacity:queryItems.count];
    [queryItems btd_forEach:^(NSString * _Nonnull key, NSString * _Nonnull obj) {
        [queryArray addObject:[NSString stringWithFormat:@"%@=%@", ([key isKindOfClass:NSString.class]? ([key btd_stringByURLEncode]?: key) : key), ([obj isKindOfClass:NSString.class]? ([obj btd_stringByURLEncode]?: obj) : obj)]];
    }];
    components.percentEncodedQuery = queryArray.count > 0 ? [queryArray componentsJoinedByString:@"&"] : nil;
    return components.URL;
}

- (NSURL *)_btd_URLByMergingQueries:(NSDictionary<NSString *,NSString *> *)queries {
    if (queries.count == 0) {
        return self;
    }
    NSDictionary *items = [self btd_queryItemsWithDecoding] ? : @{};
    NSMutableDictionary<NSString*, NSString *> *queryItems = [items mutableCopy];
    [queries btd_forEach:^(NSString * _Nonnull key, NSString * _Nonnull obj) {
        if ([obj isKindOfClass:[NSNumber class]]) {
            queryItems[key] = [(NSNumber *)obj stringValue];
        } else if ([obj isKindOfClass:[NSString class]]) {
            queryItems[key] = obj;
        }
    }];
    NSURLComponents *components = [self btd_URLComponents];
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:queryItems.count];
    [queryItems btd_forEach:^(NSString * _Nonnull key, NSString * _Nonnull obj) {
        NSURLQueryItem *queryItem = [NSURLQueryItem queryItemWithName:key value:obj];
        [array addObject:queryItem];
    }];
    components.queryItems = array;
    return components.URL;
}

+ (BOOL)btd_fullyEncodeURLParams {
    return _btd_fullyEncodeURLParams;
}

+ (void)setBtd_fullyEncodeURLParams:(BOOL)btd_fullyEncodeURLParams {
    _btd_fullyEncodeURLParams = btd_fullyEncodeURLParams;
}

+ (BOOL)btd_invalidSchemeCompatible {
    return BTDInvalidSchemeCompatible;
}

+ (void)setBtd_invalidSchemeCompatible:(BOOL)btd_invalidSchemeCompatible {
    BTDInvalidSchemeCompatible = btd_invalidSchemeCompatible;
}

+ (BOOL)btd_isURLWithStringIOS17Compatible {
    return BTDIsURLWithStringIOS17Compatible;
}

+ (void)setBtd_isURLWithStringIOS17Compatible:(BOOL)btd_isURLWithStringIOS17Compatible {
    BTDIsURLWithStringIOS17Compatible = btd_isURLWithStringIOS17Compatible;
}

- (NSURLComponents *)btd_URLComponents {
    if (NSURL.btd_invalidSchemeCompatible) {
        return [NSURLComponents btd_componentsWithURL:self];
    }
    return [NSURLComponents componentsWithString:self.absoluteString];
}

@end
