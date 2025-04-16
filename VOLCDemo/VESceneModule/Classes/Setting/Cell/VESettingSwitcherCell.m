//
//  VESettingSwitcherCell.m
//  VOLCDemo
//
//  Created by real on 2022/8/22.
//  Copyright © 2022 ByteDance. All rights reserved.
//

#import "VESettingSwitcherCell.h"
#import "VESettingModel.h"
#import "TTVideoEngine.h"
#import "MBProgressHUD/MBProgressHUD.h"

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
    if (self.settingModel.settingType == VESettingKeyUniversalSR) {
        TTVideoEngine *videoEngine = [[TTVideoEngine alloc] init];
        if (![videoEngine isSupportSR]) {
            [sender setOn:!sender.isOn];
            [self showTips:@"The device not support SR"];
            return;
        }
    }
    self.settingModel.open = sender.on;
    if (self.settingModel.switchAction) {
        self.settingModel.switchAction();
    }
}

- (void)showTips:(NSString *)tips {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:UIApplication.sharedApplication.keyWindow animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.label.text = tips;
    [hud hideAnimated:YES afterDelay:1.0];
}

@end
