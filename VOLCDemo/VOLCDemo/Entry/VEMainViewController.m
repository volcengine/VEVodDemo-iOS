//
//  VEMainViewController.m
//  VOLCDemo
//
//  Created by real on 2021/5/23.
//

#import "VEMainViewController.h"
#import <VEPlayModule/VEShortVideoViewController.h>
#import <VEPlayModule/VEFeedVideoViewController.h>
#import <VEPlayModule/VELongVideoViewController.h>
#import <VEPlayModule/VESettingViewController.h>
#import <TTSDK/TTSDKManager.h>

@interface VEMainViewController ()

@property (weak, nonatomic) IBOutlet UILabel *versionLabel;

@end

@implementation VEMainViewController

- (void)viewDidLoad {
    self.versionLabel.text = [NSString stringWithFormat:@"TTSDK - %@", [TTSDKManager SDKVersionString]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}


#pragma mark - Action

- (IBAction)shortVideoTouchUpInsideAction:(id)sender {
    VEShortVideoViewController *shortVideoViewController = [VEShortVideoViewController new];
    [self.navigationController pushViewController:shortVideoViewController animated:YES];
}

- (IBAction)feedVideoTouchUpInsideAction:(id)sender {
    VEFeedVideoViewController *feedVideoViewController = [VEFeedVideoViewController new];
    [self.navigationController pushViewController:feedVideoViewController animated:YES];
}

- (IBAction)longVideoTouchUpInsideAction:(id)sender {
    VELongVideoViewController *longVideoViewController = [VELongVideoViewController new];
    [self.navigationController pushViewController:longVideoViewController animated:YES];
}

- (IBAction)settingTouchUpInsideAction:(id)sender {
    VESettingViewController *settingViewController = [VESettingViewController new];
    [self.navigationController pushViewController:settingViewController animated:YES];
}


#pragma mark - System

- (UIStatusBarStyle)preferredStatusBarStyle {
    return 3;
}


@end
