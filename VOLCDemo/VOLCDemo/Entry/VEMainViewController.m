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

@property (weak, nonatomic) IBOutlet UILabel *vodTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *vodSubTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;

@property (weak, nonatomic) IBOutlet UILabel *shortSceneLable;
@property (weak, nonatomic) IBOutlet UILabel *middleSceneLabel;
@property (weak, nonatomic) IBOutlet UILabel *longSceneLabel;
@property (weak, nonatomic) IBOutlet UILabel *settingsLabel;

@end

@implementation VEMainViewController

- (void)viewDidLoad {
    [self configuratoinCustomView];
}

- (void)configuratoinCustomView {
    self.vodTitleLabel.text = NSLocalizedString(@"title_volc_vod", nil);
    self.vodSubTitleLabel.text = NSLocalizedString(@"title_volc_vod_desc", nil);
    
    self.shortSceneLable.text = NSLocalizedString(@"title_short_video", nil);
    self.middleSceneLabel.text = NSLocalizedString(@"title_middle_video", nil);
    self.longSceneLabel.text = NSLocalizedString(@"title_long_video", nil);
    self.settingsLabel.text = NSLocalizedString(@"title_video_setting", nil);
    
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
