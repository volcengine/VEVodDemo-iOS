//
//  VESettingSwitcherCell.m
//  VOLCDemo
//
//  Created by real on 2022/8/22.
//  Copyright © 2022 ByteDance. All rights reserved.
//

#import "VESettingSwitcherCell.h"
#import "VESettingModel.h"

const NSString *VESettingSwitcherCellReuseID = @"VESettingSwitcherCellReuseID";

@interface VESettingSwitcherCell ()

@property (weak, nonatomic) IBOutlet UIView *topSepLine;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UISwitch *switcher;

@end

@implementation VESettingSwitcherCell

- (void)setSettingModel:(VESettingModel *)settingModel {
    _settingModel = settingModel;
    self.titleLabel.text = [NSString stringWithFormat:@"%@", settingModel.displayText];
    self.switcher.on = settingModel.open;
}

- (IBAction)switcherValueChanged:(UISwitch *)sender {
    self.settingModel.open = sender.on;
}

@end
