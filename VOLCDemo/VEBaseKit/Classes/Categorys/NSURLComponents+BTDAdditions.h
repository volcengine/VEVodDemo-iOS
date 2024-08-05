//
//  NSURLComponents+BTDAdditions.h
//  Pods
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSURLComponents (BTDAdditions)

/**
 Initializes and returns a newly created NSURLComponents with a URL string. If the URLString is malformed, nil is returned.
 If the scheme does not conform to RFC 3986, nil is return in +componentsWithString: on iOS 16，which is different from <=iOS15. On iOS15, if the scheme does not conform to RFC 3986, +componentsWithString: parses everything before query as path, and the scheme, user, password, host, port is nil.
        RFC 3986 scheme = ALPHA *( ALPHA / DIGIT / "+" / "-" / "." )
 +btd_componentsWithString: is used to accommodate the differences described above. If the scheme is standard, return the result of +componentsWithString:. Otherwise, it treats the character before query as path, and try to create a NSURLComponents.
 */

+ (nullable instancetype)btd_componentsWithString:(NSString *)URLString;

/**
 Initializes and returns a newly created NSURLComponents with a URL.absoluteURL. If the absoluteURL is malformed, nil is returned.
 */
+ (nullable instancetype)btd_componentsWithURL:(NSURL *)URL;

@end

NS_ASSUME_NONNULL_END
