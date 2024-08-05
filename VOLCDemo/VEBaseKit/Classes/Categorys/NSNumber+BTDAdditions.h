//
//  NSNumber+BTDAdditions.h
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSNumber (BTDAdditions)

/**
 Convert a NSString to a NSNumber.

 @param string A number NSString. For example, @"12", @"12.345", @" -0xFF", @" .23e99 ".
 @return A NSNumber. If an error happened, it would return nil.
 */
+ (nullable NSNumber *)btd_numberWithString:(nonnull NSString *)string;

/**
 Returns whether current NSNumber is `NaN` (Not a Number), which is not compatible in JSON Serialization.
 */
- (BOOL)btd_isNaN;

@end

NS_ASSUME_NONNULL_END
