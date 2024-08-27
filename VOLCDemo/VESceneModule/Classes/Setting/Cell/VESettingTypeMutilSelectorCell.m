//
//  VESettingTypeMutilSelectorCell.m
//  VOLCDemo
//
//  Created by real on 2022/8/22.
//  Copyright © 2022 ByteDance. All rights reserved.
//

#import "VESettingTypeMutilSelectorCell.h"
#import "VESettingModel.h"

const NSString *VESettingTypeMutilSelectorCellReuseID = @"VESettingTypeMutilSelectorCellReuseID";

@interface VESettingTypeMutilSelectorCell ()

@property (weak, nonatomic) IBOutlet UIView *topSepLine;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UILabel *detailLabel;

@end

@implementation VESettingTypeMutilSelectorCell

- (void)setSettingModel:(VESettingModel *)settingModel {
    _settingModel = settingModel;
    self.titleLabel.text = [NSString stringWithFormat:@"%@", settingModel.displayText ?: @""];
    self.detailLabel.text = [NSString stringWithFormat:@"%@", settingModel.detailText ?: @""];
}

@end
