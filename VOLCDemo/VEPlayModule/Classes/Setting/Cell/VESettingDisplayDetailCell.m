//
//  VESettingDisplayDetailCell.m
//  VOLCDemo
//
//  Created by real on 2022/8/22.
//  Copyright © 2022 ByteDance. All rights reserved.
//

#import "VESettingDisplayDetailCell.h"
#import "VESettingModel.h"

const NSString *VESettingDisplayDetailCellReuseID = @"VESettingDisplayDetailCellReuseID";

@interface VESettingDisplayDetailCell ()

@property (weak, nonatomic) IBOutlet UIView *topSepLine;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UILabel *detailLabel;

@property (weak, nonatomic) IBOutlet UIButton *operationButton;

@end

@implementation VESettingDisplayDetailCell

- (void)setSettingModel:(VESettingModel *)settingModel {
    _settingModel = settingModel;
    self.titleLabel.text = [NSString stringWithFormat:@"%@", settingModel.displayText];
    self.detailLabel.text = [NSString stringWithFormat:@"%@", settingModel.detailText];
}

- (IBAction)operationButtonTouchUpInsideAction:(id)sender {
    [UIPasteboard generalPasteboard].string = [NSString stringWithFormat:@"%@", self.settingModel.detailText];
}

@end
