//
//  VEGlobalConfigDeviceIdViewCell.m
//  VOLCDemo
//
//  Created by wangzhiyong on 2021/5/31.
//  Copyright © 2021 ByteDance. All rights reserved.
//

#import "VEGlobalConfigDeviceIdViewCell.h"

@implementation VEGlobalConfigDeviceIdViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self configuratoinCustomView];
    }
    return self;
}

- (void)configuratoinCustomView {
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.titleLabel.textColor = [UIColor darkGrayColor];
    self.titleLabel.font = [UIFont systemFontOfSize:14];
    [self.contentView addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView);
        make.left.equalTo(self.contentView).with.offset(17);
        make.height.mas_equalTo(44);
    }];
    
    self.deviceIdLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.deviceIdLabel.textColor = [UIColor darkGrayColor];
    self.deviceIdLabel.font = [UIFont systemFontOfSize:12];
    self.deviceIdLabel.numberOfLines = 2;
    [self.contentView addSubview:self.deviceIdLabel];
    [self.deviceIdLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom);
        make.left.equalTo(self.contentView).with.offset(17);
        make.right.equalTo(self.contentView).with.offset(-17);
        make.height.mas_equalTo(44);
    }];
    
    self.bottomLineView = [[UIView alloc] init];
    self.bottomLineView.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.3];
    [self.contentView addSubview:self.bottomLineView];
    [self.bottomLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.contentView);
        make.left.equalTo(self.contentView).with.offset(17);
        make.right.equalTo(self.contentView).with.offset(-17);
        make.height.mas_equalTo(0.5);
    }];
    
    UILabel *copyLabel = [[UILabel alloc] init];
    copyLabel.textAlignment = NSTextAlignmentCenter;
    copyLabel.font = [UIFont systemFontOfSize:10];
    copyLabel.textColor = [UIColor whiteColor];
    copyLabel.backgroundColor = [UIColor blueColor];
    copyLabel.text = NSLocalizedString(@"Setting_Device_Copy", nil);
    [self.contentView addSubview:copyLabel];
    [copyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.titleLabel);
        make.right.equalTo(self.contentView).with.offset(-17);
        make.size.mas_equalTo(CGSizeMake(52, 28));
    }];
}

@end
