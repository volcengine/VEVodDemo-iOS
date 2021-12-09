//
//  UIButton+MainViewItem.m
//  VOLCDemo
//
//  Created by real on 2021/7/30.
//  Copyright © 2021 ByteDance. All rights reserved.
//

#import "UIButton+MainViewItem.h"

@implementation UIButton (MainViewItem)

+ (instancetype)__newButtonWithTitle:(NSString*)title icon:(NSString*)iconName target:(id)target action:(SEL)selector type:(SenceButtonType)type {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *icon = [UIImage imageNamed:iconName];
    CGSize imgSize = icon.size;
    UIImageView *imageView = [[UIImageView alloc] initWithImage:icon];
    [button addSubview:imageView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(button).with.offset(15);
        make.centerX.equalTo(button);
        make.size.mas_equalTo(CGSizeMake(imgSize.width/2, imgSize.height/2));
    }];
    
    UILabel *label = [[UILabel alloc] init];
    label.text = title;
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:14.f];
    [button addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(imageView.mas_bottom).with.offset(10);
        make.centerX.equalTo(button);
    }];
    
    button.backgroundColor = [UIColor darkGrayColor];
    button.tag = type;
    button.layer.cornerRadius = 10;
    [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}

@end
