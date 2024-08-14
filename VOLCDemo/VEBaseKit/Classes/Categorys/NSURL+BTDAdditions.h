//
//  NSURL+BTDAdditions.h
//  Pods

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXTERN NSURL* BTDCreateUrl(NSString *urlString);

@interface NSURL (BTDAdditions)

@property(nonatomic, assign, class) BOOL btd_fullyEncodeURLParams;

/**
 In ordered to accommodate the differences in NSURLComponents on iOS16, this property controls
 whether to use +btd_componentsWithString: or componentsWithString: to create NSURLComponents.
 Please see NSURLComponents+BTDAdditions.h for details.
 Affected API:
     -btd_queryItemsWithDecoding
     -btd_URLByMergingQueries:
     -btd_URLByMergingQueries:fullyEncoded
     -btd_URLByMergingQueryKey:value:
     -btd_URLByMergingQueryKey:value:fullyEncoded
     -btd_URLComponents
 */
@property(nonatomic, assign, class) BOOL btd_invalidSchemeCompatible;

/**
 This value was added to address the inconsistent behavior of `[NSURL URLWithString:]` before and
 after iOS17. Default is `YES`, if the value is `YES`, function `BTDCreateUrl(NSString*)` will use
 new API `+[NSURL URLWithString:encodingInvalidCharacters:]` after iOS17, otherwise it will use
 `+[NSURL URLWithString:]`.
 
 The change of `+[NSURL URLWithString:]` after iOS17 will bring unexpected exception, new API
 `+[NSURL URLWithString:encodingInvalidCharacters:]` was created to avoid this risk.
 
 API change in iOS17: when we input strings contain invalid characters, like uncoded string,
 `+[NSURL URLWithString:]` will encode these characters again after iOS17. For example,
 `a=中国&b=%E7%`, you will get `nil` before IOS17, but get `a=%E4%B8%AD%E5%9B%BD&b=%25E7%25` after,
 the `%` will be re-encode into `%25`.
 
 In order to fix this problem, ByteDanceKit provides new API `BTDCreateUrl(NSString*)`, when
 `btd_isURLWithStringIOS17Compatible` set to `YES`, `BTDCreateUrl(NSString*)` will return same
 result before and after iOS17.
 */
@property(nonatomic, assign, class) BOOL btd_isURLWithStringIOS17Compatible;

/// A compatible URL construction method.
/// This method will trim white-space characters, and encode the non-standard characters such as chinese characters.
/// @param URLString The URL string.
+ (nullable instancetype)btd_URLWithString:(NSString *)URLString;

/// A compatible URL construction method.
/// This method will trim white-space characters, and encode the non-standard characters such as chinese characters.
/// @param URLString The URL string.
/// @param baseURL The base URL for the NSURL object.
+ (nullable instancetype)btd_URLWithString:(NSString *)URLString relativeToURL:(nullable NSURL *)baseURL;

/// Construct a URL with URL and query dictionary.
/// @param URLString A URL string.
/// @param queryItems A query dictionary.
+ (nullable instancetype)btd_URLWithString:(NSString *)URLString queryItems:(nullable NSDictionary *)queryItems;

/// Construct a URL with URL and query dictionary.
/// @param URLString A URL string.
/// @param queryItems A query dictionary.
/// @param fragment A URL fragment. For example: #L100
+ (nullable instancetype)btd_URLWithString:(NSString *)URLString queryItems:(nullable NSDictionary *)queryItems fragment:(nullable NSString *)fragment;

/*
 Construct a newly created file NSURL from the local file or directory at URLString.
 If the URLString is nil, this function will return nil.
 */
+ (nullable NSURL *)btd_fileURLWithPath:(nullable NSString *)URLString;
/*
 Construct a newly created file NSURL from the local file or directory at path.
 If the URLString is nil, this function will return nil.
 */
+ (nullable NSURL *)btd_fileURLWithPath:(nullable NSString *)path isDirectory:(BOOL)isDir;

/**
 Return a NSURLComponents instance for [url absoluteString]. If the absoluteString is a malformed URLString, nil is returned.
 This method is for compatibility with iOS16, which is controlled by NSURL.btd_invalidSchemeCompatible.
 See NSURLComponents+BTDAdditions.h for details.
 */
- (nullable NSURLComponents *)btd_URLComponents;

- (nullable NSDictionary<NSString *, NSString *> *)btd_queryItems;

- (nullable NSDictionary<NSString *, NSString *> *)btd_queryItemsWithDecoding;

/**
 Use a query key-value pairs merge the URL's querys. If the key exists in the URL's query, the value in the URL will be updated.
 For example: http://example.com/video/search?type=love&region=china
 @param key key For example: release
 @param value value For example: 2019
 @return A new URL after merging. For example: http://example.com/video/search?type=art&region=china&release=2019
 */
- (NSURL *)btd_URLByMergingQueryKey:(NSString *)key value:(NSString *)value;

- (NSURL *)btd_URLByMergingQueryKey:(NSString *)key value:(NSString *)value fullyEncoded:(BOOL)fullyEncoded;

/**
 Use a query dictionary merge the URL's querys. The queries will be URL-encoded completely! Be careful if the original url has url query that not be URL-encoded completely !!!
 
 Sample Code:
 NSURL *url =[NSURL URLWithString:@"sslocal://webview"];
 NSDictionary *queries =@{@"url":@"https://www.bytedance.com"};
 NSURL *result = [url btd_URLByMergingQueries:queries fullyEncoded:YES];
 result: sslocal://webview?url=https%3A%2F%2Fwww.bytedance.com
 
 ------- Be careful if the original url has url query that not be URL-encoded completely !!! -------
 If the original url has url query that not be URL-encoded completely, The original url param may be changed!!!
 For example :
 NSURL *url = [NSURL URLWithString:@"sslocal://webview?url=https://www.bytedance.com?a=1"];
 NSURL *result = [url btd_URLByMergingQueries:@{@"b":@"2"}  fullyEncoded:YES];
 result: sslocal://webview?url=https%3A%2F%2Fwww.bytedance.com%3Fa%3D1&b=2
 
 @param queries A query dictionary. For example: {"type":"art","release":"2019"}
 @return A new URL after merging. For example:  http://example.com/video/search?type=art&region=china&release=2019
 */
- (NSURL *)btd_URLByMergingQueries:(NSDictionary<NSString *,NSString*> *)queries;

- (NSURL *)btd_URLByMergingQueries:(NSDictionary<NSString *,NSString*> *)queries fullyEncoded:(BOOL)fullyEncoded;

@end

NS_ASSUME_NONNULL_END
