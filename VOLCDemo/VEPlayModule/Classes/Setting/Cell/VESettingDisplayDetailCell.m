//
//  VESettingDisplayDetailCell.m
//  VOLCDemo
//
//  Created by real on 2022/8/22.
//  Copyright © 2022 ByteDance. All rights reserved.
//

#import "VESettingDisplayDetailCell.h"
#import "VESettingModel.h"
#import <MBProgressHUD/MBProgressHUD.h>

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
    [self.operationButton setTitle:NSLocalizedStringFromTable(@"title_common_copy", @"VodLocalizable", nil) forState:UIControlStateNormal];
    self.titleLabel.text = [NSString stringWithFormat:@"%@", settingModel.displayText];
    self.detailLabel.text = [NSString stringWithFormat:@"%@", settingModel.detailText];
}

- (IBAction)operationButtonTouchUpInsideAction:(id)sender {
    [UIPasteboard generalPasteboard].string = [NSString stringWithFormat:@"%@", self.settingModel.detailText];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:UIApplication.sharedApplication.keyWindow animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.label.text = NSLocalizedStringFromTable(@"tip_copy_success", @"VodLocalizable", nil);
    [hud hideAnimated:YES afterDelay:1.0];
}

@end
