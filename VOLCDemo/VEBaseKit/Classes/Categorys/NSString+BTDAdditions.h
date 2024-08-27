
#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#else
#import <AppKit/AppKit.h>
#endif

#import <Foundation/Foundation.h>

/// @Attentions If btd_fullyEncodeURLParams is true, the global strategy will fail.
typedef NS_ENUM(SInt32, BTDURLParameterEncodeStrategy) {
    /**
     Default.
     Parameters will be added or removed directly from the URL and encoded by NSURLComponents.
     @Attention If the original URL contains a percent sign, it will be encoded again.
     ✅
     NSString *original = @"sslocal://bytedance.com/?param1=value1";
     NSDictionary *appending = @{@"param2":@"2"};
     NSString *result = [original btd_urlStringByAddingParameters:appending];
        result: @"sslocal://bytedance.com/?param1=value1&param2=value2"
     
     NSString *remove = [result btd_urlStringByRemovingParameters:@[param2]];
        remove:@"sslocal://bytedance.com/?param1=value1"
     
     ❌
     NSString *original = @"sslocal://webview?url=https%3A%2F%2Fwww.bytedance.com";
     NSDictionary *appending = @{@"param1":@"1"};
     NSString *result = [original btd_urlStringByAddingParameters:appending];
        result = @"sslocal://webview?url=https%253A%252F%252Fwww.bytedance.com&param1=1";
     
     */
    BTDURLParameterEncodeStrategyDefault,
    
    /**
     Not Recommend.
     The URL's parameters will be decoded first, then use the parameters to modify URL. The URL will be encoded by NSURLComponents.
     @Attention If the original URL's query component contains encoded escape character, the escape character will be decoded. The percent sign in the parameter will be encoded again.
     
     ✅
     If the decode parameter only contain percent sign, it will not encode percent sign again.
     NSString *original = @"sslocal://webview?key=%E5%AD%97%E8%8A%82";
     NSDictionary *appending = @{@"name":@"byte"};
     NSString *result = [original btd_urlStringByAddingParameters:appending];
        result = @"sslocal://webview?key=%E5%AD%97%E8%8A%82&name=byte";
 
     ❌
     NSString *original = @"sslocal://webview?url=https%3A%2F%2Fwww.bytedance.com";
     NSDictionary *appending = @{@"param1":@"1",@"name":@"%E5%AD%97%E8%8A%82"};
     NSString *result = [original btd_urlStringByAddingParameters:appending];
        result = @"sslocal://webview?url=https://www.bytedance.com&param1=1&name=%25E5%25AD%2597%25E8%258A%2582";
     
     */
    BTDURLParameterEncodeStrategyEncodeByNSURLComponents,
    
    /**
     If the parameter is encoded, this strategy is recommended.
     Parameters have encoded and can be added or removed directly from the URL.
     ✅
     NSString *original = @"sslocal://bytedance.com/?param1=value1";
     NSDictionary *appending = @{@"%E5%AD%97%E8%8A%82":@"%E5%AD%97%E8%8A%82:Byte"};
     NSString *result = [original btd_urlStringByAddingParameters:appending];
        result: @"sslocal://bytedance.com/?param1=value1&%E5%AD%97%E8%8A%82=%E5%AD%97%E8%8A%82%3AByte"
     ❌ If parameters are decoded, they will not encode.
     */
    BTDURLParameterEncodeStrategyNoEncode,
    
    /**
     If the parameter is not encoded, this strategy is recommended.
     The appending parameters will be encoded by btd_stringByURLEncode and then append to the original URL string.
     
     ✅
     NSString *original = @"sslocal://bytedance.com/?param1=value1";
     NSDictionary *appending = @{@"字节":@"字节:Byte"};
     NSString *result = [original btd_urlStringByAddingParameters:appending];
        result: @"sslocal://bytedance.com/?param1=value1&%E5%AD%97%E8%8A%82=%E5%AD%97%E8%8A%82%3AByte"
     
     NSString *remove = [result btd_urlStringByRemovingParameters:@[@"字节"]];
        remove:@"sslocal://bytedance.com/?param1=value1"
     
     ❌
     If parameters are encoded, they will encode again.
     NSString *original = @"sslocal://bytedance.com/?param1=value1";
     NSDictionary *appending = @{@"%E5%AD%97%E8%8A%82%3":@"字节"};
     NSString *result = [original btd_urlStringByAddingParameters:appending];
        result: @"sslocal://bytedance.com/?param1=value1&%25E5%25AD%2597%25E8%258A%2582%253=Byte"
     */
    BTDURLParameterEncodeStrategyEncode,
    
    /**
     All parameters will be decoded first and then encoded by btd_stringByURLEncode.
     Different From BTDURLParameterEncodeStrategyEncode, if the original string has URL query that not be URL-encoded completely, the URL‘s query characters which after the first '=' and before the next '&' are removed, and the rest of URL will be encoded.
     ❌
     In appending parameters:
        NSString *original = @"sslocal://webview?url=https://www.bytedance.com?v1=1;
        NSString *result = [urlStr btd_urlStringByAddingParameters:@{@"v2":@"2"}];
        resultStr: @"sslocal://webview?url=https%3A%2F%2Fwww.bytedance.com%3Fv1&v2=2"
     
     In removing parameters:
        NSString *original = @"sslocal://webview?url=https://www.bytedance.com?v1=1&v2=2";
        NSString *result = [urlStr btd_urlStringByRemovingParameters:@[@"v2"]];
        resultStr: @"sslocal://webview?url=https%3A%2F%2Fwww.bytedance.com%3Fv1"
     */
    BTDURLParameterEncodeStrategyFullyEncode,
};

NS_ASSUME_NONNULL_BEGIN

@interface NSString (BTDAdditions)

@property(nonatomic, assign, class) BOOL btd_fullyEncodeURLParams DEPRECATED_MSG_ATTRIBUTE("use btd_stringURLParamsEncodeStrategy instead.");
@property(nonatomic, assign, class) BTDURLParameterEncodeStrategy btd_stringURLParamsEncodeStrategy;

/**
 In ordered to accommodate the differences in NSURLComponents on iOS16, this property controls
 whether to use +btd_componentsWithString: or componentsWithString: to create NSURLComponents.
 Please see NSURLComponents+BTDAdditions.h for details.
 Affected API:
     -btd_urlStringByAddingParameters:
     -btd_urlStringByAddingParameters:fullyEncoded:
     -btd_urlStringByAddingParameters:strategy:
     -btd_urlStringByRemovingParameters:
     -btd_urlStringByRemovingParameters:fullyEncoded:
     -btd_urlStringByRemovingParameters:strategy:
     -btd_URLComponents
 */
@property(nonatomic, assign, class) BOOL btd_invalidSchemeCompatible;

@property(nonatomic, assign, class) BOOL btd_fixMatchRegexEnabled;

- (NSString *)btd_trimmed;

/**
 
 @return A md5 NSString.
 */
- (nonnull NSString *)btd_md5String;
/**

 @return A sha1 NSString.
 */
- (nonnull NSString *)btd_sha1String;
/**

 @return A sha256 NSString.
 */
- (nonnull NSString *)btd_sha256String;
/**
 Return an UUID NSString.
 */
+ (nonnull NSString *)btd_stringWithUUID;
+ (nonnull NSString *)btd_HMACMD5WithKey:(nonnull NSString *)key andData:(nullable NSString *)data;
/**
 Return a hex NSString in UTF-16 code unit.
 */
- (nonnull NSString *)btd_hexString;

/**
 Return a NSString encoded according to base64.
 */
- (nullable NSString *)btd_base64EncodedString;

/**
 Return a NSString decoded according to base64.
 */
- (nullable NSString *)btd_base64DecodedString;

/**
 Split a NSString.
 @param characterSet The split rule.
 @return A NSString.
  Sample Code:
 NSString *str =@"A~B^C";
 NSString *resultStr =[str btd_stringByRemoveAllCharactersInSet:
 [NSCharacterSet characterSetWithCharactersInString:@"^~"]];
 resultStr:ABC
 */
- (nullable NSString *)btd_stringByRemoveAllCharactersInSet:(nonnull NSCharacterSet *)characterSet;
/**

 @return Return a NSString after removing all whitespace and newline characters.
 */
- (nullable NSString *)btd_stringByRemoveAllWhitespaceAndNewlineCharacters;

#if TARGET_OS_IPHONE
/**
 Calculate the size of the text.
 */
- (CGFloat)btd_heightWithFont:(nonnull UIFont *)font width:(CGFloat)maxWidth;

- (CGFloat)btd_widthWithFont:(nonnull UIFont *)font height:(CGFloat)maxHeight;

- (CGSize)btd_sizeWithFont:(nonnull UIFont *)font width:(CGFloat)maxWidth;

- (CGSize)btd_sizeWithFont:(nonnull UIFont *)font width:(CGFloat)maxWidth maxLine:(NSInteger)maxLine;
#else
- (CGFloat)btd_heightWithFont:(nonnull NSFont *)font width:(CGFloat)maxWidth;

- (CGFloat)btd_widthWithFont:(nonnull NSFont *)font height:(CGFloat)maxHeight;

- (CGSize)btd_sizeWithFont:(nonnull NSFont *)font width:(CGFloat)maxWidth;

- (CGSize)btd_sizeWithFont:(nonnull NSFont *)font width:(CGFloat)maxWidth maxLine:(NSInteger)maxLine;
#endif

/**
 Replace "\n\n" with "\n".

 @return A NSString after replacing.
 */
- (nullable NSString *)btd_stringByMergingContinuousNewLine;
/**

 @return A NSString afrer URLEncoding.
 */
- (nullable NSString *)btd_stringByURLEncode;
/**

 @return A NSString after URLDecoding.
 */
- (nullable NSString *)btd_stringByURLDecode;
/**
 Does a NSString contain numbers only?

 @return Return YES if the NSString contain numbers only.Otherwise, return NO.
 */
- (BOOL)btd_containsNumberOnly;

/**
 Does a NSString match a regex?

 @param regex A regex NSString.
 @return Return YES if the NSString match the regex.Otherwise, return NO.
 */
- (BOOL)btd_matchsRegex:(nonnull NSString *)regex;

/**
 Does a NSString match a regex? If it does, block will be called to send some informations.
 

 @param regex A regex NSString.
 @param options The options.
 @param block A callback block.
 */
- (void)btd_enumerateRegexMatches:(nonnull NSString *)regex options:(NSRegularExpressionOptions)options usingBlock:(nonnull void (^)(NSString *_Nullable match, NSRange matchRange, BOOL * _Nullable stop))block;
/**
 Convert a NSString to a NSDictionary or a NSArray.If an error happened, nil would be returned.
 */
- (nullable id)btd_jsonValueDecoded;
- (nullable id)btd_jsonValueDecoded:(NSError * _Nullable __autoreleasing * _Nullable)error;

- (nullable NSArray *)btd_jsonArray;
- (nullable NSDictionary *)btd_jsonDictionary;

- (nullable NSArray *)btd_jsonArray:(NSError * _Nullable __autoreleasing * _Nullable)error;
- (nullable NSDictionary *)btd_jsonDictionary:(NSError * _Nullable __autoreleasing * _Nullable)error;

/**
 Convert a NSString to a NSNumber.If an error happened, nil would be returned.

 @return Return a NSNumber.If an error happened, the function would return nil.
 */
- (nullable NSNumber *)btd_numberValue;
/**
 Convert two strings to a new string.
 
 @param componentString a component string
 @return A NSString.
 Sample Code:
 NSString *str1 = @"http://www.baidu.com";
 NSSting *str2 = @"a=b&c=d"
 NSString *resultStr = [str1 btd_urlStringByAddingComponentString:str2];
 resultStr: http://www.baidu.com?a=b&c=d
 */
- (nullable NSString *)btd_urlStringByAddingComponentString:(nonnull NSString *)componentString;
/**
 Convert a string array to a new string.
 
 @param componentArray A string array.
 @return A NSString.
 */
- (nullable NSString *)btd_urlStringByAddingComponentArray:(NSArray<NSString *> *)componentArray;

/**
 Add parameters to the query component of the URL. The original URL must already be encoded, otherwise it will be incorrectly encoded.
 
 @param parameters Parameters that need to be added to the URL.
 The method is control by btd_stringURLParamsEncodeStrategy which is defined above. The default global strategy is BTDURLParameterEncodeStrategyDefault. You can set btd_stringURLParamsEncodeStrategy to change the global policy when the application startup.
 
 @Attention If btd_fullyEncodeURLParams is true, the global strategy will fail, and btd_urlStringByAddingParameters will call btd_urlStringByAddingParameters:fullyEncoded where fullyEncoded = YES.
 */
- (nullable NSString *)btd_urlStringByAddingParameters:(NSDictionary<NSString *, NSString *> *)parameters;
- (nullable NSString *)btd_urlStringByAddingParameters:(NSDictionary<NSString *,NSString *> *)parameters strategy:(BTDURLParameterEncodeStrategy)strategy;

/**
 Adding parameters to a url string. The parameters will be URL-encoded completely! Be careful if the original url has url query that not be URL-encoded completely !!!
 (For example, "https://www.bytedance.com/" will be URL-encoded completely to"https%3A%2F%2Fwww.bytedance.com").
 
 Sample Code:
 NSString *str1 = @"sslocal://webview";
 NSDictionary *parameters =@{@"url":@"https://www.bytedance.com"};
 NSString *resultStr = [str1 btd_urlStringByAddingParameters:parameters fullyEncoded:YES];
 resultStr: @"sslocal://webview?url=https%3A%2F%2Fwww.bytedance.com"

 ------- Be careful if the original url has url query that not be URL-encoded completely !!! -------
 If the original url string has url query that not be URL-encoded completely, The original url param may be changed!!!
 For example :
 NSString *urlStr = @"sslocal://webview?url=https://www.bytedance.com?a=1";
 NSString *result = [urlStr btd_urlStringByAddingParameters:@{@"b":@"2"}  fullyEncoded:YES];
 resultStr: @"sslocal://webview?url=https%3A%2F%2Fwww.bytedance.com%3Fa&b=2"
 
 If the appending parameters have encoded, it will encode again.
 
 @param parameters A param NSDictionary.
 @return A NSString.
 */
- (nullable NSString *)btd_urlStringByAddingParameters:(NSDictionary<NSString *, NSString *> *)parameters fullyEncoded:(BOOL)fullyEncoded DEPRECATED_MSG_ATTRIBUTE("Use btd_urlStringByAddingParameters:strategy: instead. If fullyEncoded = YES, use strategy BTDURLParameterEncodeStrategyFullyEncode, otherwise use strategy BTDURLParameterEncodeStrategyDefault.");

/**
 Remove parameters on the query component of the URL. The original URL must already be encoded, otherwise it will be incorrectly encoded.
 @param parameters Parameters that need to be removed.
 
 The method is control by btd_stringURLParamsEncodeStrategy which is defined above. The default global strategy is BTDURLParameterEncodeStrategyDefault. You can set btd_stringURLParamsEncodeStrategy to change the global policy when the application startup.
 
 @Attention If btd_fullyEncodeURLParams is true, the global strategy will fail, and btd_urlStringByAddingParameters will call btd_urlStringByRemovingParameters:fullyEncoded where fullyEncoded = YES.
 */
- (nullable NSString *)btd_urlStringByRemovingParameters:(NSArray<NSString *> *)parameters;
- (nullable NSString *)btd_urlStringByRemovingParameters:(NSArray<NSString *> *)parameters strategy:(BTDURLParameterEncodeStrategy)strategy;

/**
 Remove params from a url string. Be careful if the original url has url query that not be URL-encoded completely !!!
 
 ------- Be careful if the original url has url query that not be URL-encoded completely !!! -------
 If the original url string has url query that not be URL-encoded completely, The original url param may be changed!!!
 For example :
 NSString *urlStr = @"sslocal://webview?url=https://www.bytedance.com?a=1&b=2";
 NSString *result = [urlStr btd_urlStringByRemovingParameters:@[@"b"] fullyEncoded:YES];
 resultStr: @"sslocal://webview?url=https%3A%2F%2Fwww.bytedance.com%3Fa"
 
 The parameters should not be encoded.

 @param parameters A NSArray consists of NSStrings.
 @return A NSString.
 */
- (nullable NSString *)btd_urlStringByRemovingParameters:(NSArray<NSString *> * _Nonnull)parameters fullyEncoded:(BOOL)fullyEncoded DEPRECATED_MSG_ATTRIBUTE("Use btd_urlStringByRemovingParameters:strategy: instead. If fullyEncoded = YES, use strategy BTDURLParameterEncodeStrategyFullyEncode, otherwise use strategy BTDURLParameterEncodeStrategyDefault.");

/**
 Return a NSURLComponents instance. If the string is a malformed URLString, nil is returned.
 This method is for compatibility with iOS16, which is controlled by NSString.btd_invalidSchemeCompatible.
 See NSURLComponents+BTDAdditions.h for details.
 */
- (nullable NSURLComponents *)btd_URLComponents;

/**
 @return Return A NSArray consists of path strings.If there is no path string, return nil.
 */
- (nullable NSArray<NSString *> *)btd_pathComponentArray;
/**
 Return a query param dictionary.Nonstandard parameters will be automatically filtered out. If there is no param, return nil.

 @return A NSDictionary.
 */
- (nullable NSDictionary<NSString *, NSString *> *)btd_queryParamDict;
/**
 Return a decoded query param dictionary.
 
 @return A NSDictionary.
 */
- (nullable NSDictionary<NSString *, NSString *> *)btd_queryParamDictDecoded;

/**

 @return Return the scheme. If the string is a empty string, return nil.
 */
- (nullable NSString *)btd_scheme;
/**
 
 @return Return the path.If there's no path, return nil.
 */
- (nullable NSString *)btd_path;

/**
 Prepend the string after the Library path.
 
 @return The string after prepending.
 */
- (NSString *)btd_prependingLibraryPath;

/**
 Prepend the string after the Cache path.

 @return The string after prepending.
 */
- (NSString *)btd_prependingCachePath;

/**
 Prepend the string after the Documents path.
 
 @return The string after prepending.
 */
- (NSString *)btd_prependingDocumentsPath;

/**
 Prepend the string after the tmp path.
 
 @return The string after prepending.
 */
- (NSString *)btd_prependingTemporaryPath;

/**
 Provide safe range for the method -(NSRange)rangeOfString:(NSString *) options:(NSStringCompareOptions)mask range:(NSRange);
 
 @param rangeOfReceiverToSearch The subrange of the receiver to use in the search. 
        If the left boundary is out of bounds, an invalid value NSMakeRange(NSNotFound, 0) is returned.
        If the right boundary is out of bounds, the right boundary is changed to the end position of receiver.
 @return The range of the searchString within the receiver string.
 */
- (NSRange)btd_rangeOfString:(NSString *)searchString options:(NSStringCompareOptions)mask range:(NSRange)rangeOfReceiverToSearch;

/**
 Provide safe range for the method -(NSRange)rangeOfString:(NSString *) options:(NSStringCompareOptions)mask range:(NSRange) locale:(nullable NSLocale *);
 @param rangeOfReceiverToSearch The subrange of the receiver to use in the search. 
        If the left boundary is out of bounds, an invalid value NSMakeRange(NSNotFound, 0) is returned.
        If the right boundary is out of bounds, the right boundary is changed to the end position of receiver.
 @return The range of the searchString within the receiver string.
 */
- (NSRange)btd_rangeOfString:(NSString *)searchString options:(NSStringCompareOptions)mask range:(NSRange)rangeOfReceiverToSearch locale:(nullable NSLocale *)locale API_AVAILABLE(macos(10.5), ios(2.0), watchos(2.0), tvos(9.0));

/**
 Returns a new string containing the characters of the receiver from the one at a given index to the end.
 @param from  An index. If the index is out of bounds, empty string(@"") will be returned.
 */
- (NSString *)btd_substringFromIndex:(NSUInteger)from;

/**
 Returns a new string containing the characters of the receiver up to, but not including, the one at a given index.
 @param to  An index. If the index is out of bounds, a copy of the receiver will be returned.
 */
- (NSString *)btd_substringToIndex:(NSUInteger)to;

/**
 Returns a string object containing the characters of the receiver that lie within a given range.
 @param range A range. If range's location is greater than the string's length or range's length is equal to zero, empty string(@"") will be returned. If the right bound of range exceeds the string, range will be truncated to the end of the string.
 */
- (NSString *)btd_substringWithRange:(NSRange)range;

@end

@interface NSMutableString (BTDAdditions)

/**
 Adds to the end of the receiver the characters of a given string.
 @param aString If the appending string is nil, this method will do nothing.
 */
- (void)btd_appendString:(NSString *)aString;

/**
 Inserts into the receiver the characters of a given string at a given location.
 @param aString If the inserting string is nil, this method will do nothing.
 @param loc If loc is out of bounds, this method will do nothing.
 */
- (void)btd_insertString:(NSString *)aString atIndex:(NSUInteger)loc;

/**
 Replaces the characters in the given range with the characters of the given string.
 @param range If the location of the range is greater than the string's length, this method will do nothing. If the right bound of range exceeds the string, range will be truncated to the end of the string.
 @param aString If the replacing string is nil, this method will do nothing.
 */
- (void)btd_replaceCharactersInRange:(NSRange)range withString:(NSString *)aString;

/**
 Deletes the characters in the given range along with their associated attributes.
 @param range If the location of the range is greater than the string's length, this method will do nothing. If the right bound of range exceeds the string, range will be truncated to the end of the string.
 */
- (void)btd_deleteCharactersInRange:(NSRange)range;

@end


@interface NSAttributedString (BTDToBeDeprecated)

/**
 @return Return the height of the text when the max width of the text is maxWidth.
 */
- (CGFloat)btd_heightWithWidth:(CGFloat)maxWidth;

@end

NS_ASSUME_NONNULL_END
