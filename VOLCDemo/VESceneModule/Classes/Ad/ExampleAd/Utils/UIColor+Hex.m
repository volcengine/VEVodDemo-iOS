//
//  UIColor+Hex.m
//  VESceneModule
//
//  Created by litao.he on 2024/11/11.
//

#import "UIColor+Hex.h"

@implementation UIColor (Hex)

+ (UIColor *)colorWithHexString:(NSString *)hexString {
    #define COLOR_RGBA(r, g, b, a) [UIColor colorWithRed:r / 255.0 green:g / 255.0 blue:b / 255.0 alpha:a]

    NSString *cleanString = [[hexString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];

    if ([cleanString hasPrefix:@"#"]) {
        cleanString = [cleanString substringFromIndex:1];
    }

    if ([cleanString length] != 6 && [cleanString length] != 8) {
        return [UIColor grayColor];
    }

    if ([cleanString length] == 6) {
        cleanString = [cleanString stringByAppendingString:@"FF"];
    }

    NSRange range = NSMakeRange(0, 2);
    NSString *rString = [cleanString substringWithRange:range];

    range.location = 2;
    NSString *gString = [cleanString substringWithRange:range];

    range.location = 4;
    NSString *bString = [cleanString substringWithRange:range];

    range.location = 6;
    NSString *aString = [cleanString substringWithRange:range];

    unsigned int r, g, b, a;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    [[NSScanner scannerWithString:aString] scanHexInt:&a];

    return COLOR_RGBA(r, g, b, a / 255.0);
}

@end
