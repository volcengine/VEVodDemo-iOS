//
//  VEVideoPlayerViewController+Tips.m
//  VOLCDemo
//
//  Created by wangzhiyong on 2021/12/8.
//

#import "VEVideoPlayerViewController+Tips.h"

@implementation VEVideoPlayerViewController (ShowTips)

- (void)showTips:(NSString *)message {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.playerView animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.label.text = message;
    [hud hideAnimated:YES afterDelay:2.0];
}

@end
