//
//  VOLCGlobalConfigSwitchViewCell.h
//  VOLCDemo
//
//  Created by wangzhiyong on 2021/5/31.
//  Copyright © 2021 ByteDance. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface VOLCGlobalConfigSwitchViewCell : UITableViewCell

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UISwitch *switcher;
@property (nonatomic, strong) UIView *bottomLineView;

@end

NS_ASSUME_NONNULL_END
