//
//  VESettingDisplayCell.m
//  VOLCDemo
//
//  Created by real on 2022/8/22.
//  Copyright © 2022 ByteDance. All rights reserved.
//

#import "VESettingDisplayCell.h"
#import "VESettingModel.h"

const NSString *VESettingDisplayCellReuseID = @"VESettingDisplayCellReuseID";

@interface VESettingDisplayCell ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UIView *topSepLine;

@end

@implementation VESettingDisplayCell

- (void)setSettingModel:(VESettingModel *)settingModel {
    _settingModel = settingModel;
    self.titleLabel.text = [NSString stringWithFormat:@"%@", settingModel.displayText];
}

@end
