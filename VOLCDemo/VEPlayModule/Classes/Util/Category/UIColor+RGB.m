//
//  UIColor+RGB.m
//  VEPlayModule
//
//  Created by real on 2022/9/1.
//

#import "UIColor+RGB.h"

@implementation UIColor (RGB)

+ (instancetype)colorWithRGB:(int)rgbValue alpha:(float)alpha {
    return [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:alpha];
}

@end
