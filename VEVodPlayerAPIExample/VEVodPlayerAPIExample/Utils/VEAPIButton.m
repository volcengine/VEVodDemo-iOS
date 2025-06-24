// Copyright (c) 2025 Beijing Volcano Engine Technology Co., Ltd.
// SPDX-License-Identifier: MIT
//
//  VEAPIButton.m
//  VEVodPlayerAPIExample
//
//  Created by ByteDance on 2025/5/27.
//

#import "VEAPIButton.h"

@implementation VEAPIButton

- (instancetype)init {
    self = [super init];
    if (self) {
        self.titleLabel.font = [UIFont systemFontOfSize:16];
        [self setBackgroundImage:[self imageWithColor:[UIColor systemBlueColor]] forState:UIControlStateNormal];
        [self setBackgroundImage:[self imageWithColor:[UIColor colorWithRed:0/255.0 green:122/255.0 blue:255/255.0 alpha:1]] forState:UIControlStateHighlighted];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self setTitleColor:[UIColor colorWithWhite:0.8 alpha:1] forState:UIControlStateHighlighted];
        self.contentEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
        self.layer.cornerRadius = 8.0;
        self.layer.masksToBounds = YES;
    }
    return self;
}

- (instancetype)initWithTitle:(NSString *)title {
    self = [self init];
    [self setTitle:title forState:UIControlStateNormal];
    return self;
}

- (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
