//
//  UIButton+MainViewItem.h
//  VOLCDemo
//
//  Created by real on 2021/7/30.
//  Copyright © 2021 ByteDance. All rights reserved.
//

typedef  NS_ENUM(NSUInteger, SenceButtonType){
    SenceButtonTypeSmallVideo,
    SenceButtonTypeLongVideo,
};

@interface UIButton (MainViewItem)

+ (instancetype)__newButtonWithTitle:(NSString*)title icon:(NSString*)iconName target:(id)target action:(SEL)selector type:(SenceButtonType)type;

@end
