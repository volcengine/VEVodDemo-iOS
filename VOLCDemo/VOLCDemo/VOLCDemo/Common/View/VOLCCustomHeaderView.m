//
//  VOLCCustomHeaderView.m
//  VOLCDemo
//
//  Created by wangzhiyong on 2021/5/31.
//  Copyright © 2021 ByteDance. All rights reserved.
//

#import "VOLCCustomHeaderView.h"

@interface VOLCCustomHeaderView ()

@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIButton *settingButton;

@end

@implementation VOLCCustomHeaderView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backButton = [[UIButton alloc] init];
        [self.backButton setImage:[UIImage imageNamed:@"learning_live_back"] forState:UIControlStateNormal];
        [self.backButton sizeToFit];
        [self.backButton addTarget:self action:@selector(backButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.backButton];
        [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).with.offset(5);
            make.bottom.equalTo(self).with.offset(-5);
            make.size.mas_equalTo(CGSizeMake(40, 40));
        }];
        
        self.settingButton = [[UIButton alloc] init];
        [self.settingButton setImage:[UIImage imageNamed:@"learning_live_more"] forState:UIControlStateNormal];
        [self.settingButton addTarget:self action:@selector(settingButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.settingButton];
        [self.settingButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self).with.offset(-5);
            make.bottom.equalTo(self).with.offset(-5);
            make.size.mas_equalTo(CGSizeMake(40, 40));
        }];
    }
    return self;
}

- (void)backButtonClicked {
    if (self.delegate && [self.delegate respondsToSelector:@selector(headerViewBackButtonDidClicked:)]) {
        [self.delegate headerViewBackButtonDidClicked:self];
    }
}

- (void)settingButtonClicked {
    if (self.delegate && [self.delegate respondsToSelector:@selector(headerViewSettingButtonDidClicked:)]) {
        [self.delegate headerViewSettingButtonDidClicked:self];
    }
}

@end
