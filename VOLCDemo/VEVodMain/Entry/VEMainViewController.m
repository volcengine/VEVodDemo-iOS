//
//  VEMainViewController.m
//  VOLCDemo
//
//  Created by real on 2021/5/23.
//

#import "VEMainViewController.h"
#import "VEShortVideoViewController.h"
#import "VEFeedVideoViewController.h"
#import "VELongVideoViewController.h"
#import "VESettingViewController.h"
#import "VEShortDramaPagingViewController.h"
#import "VEPlayUrlConfigViewController.h"
#import <TTSDKFramework/TTSDKManager.h>
#import <AVFoundation/AVFoundation.h>

@interface VEMainViewController ()

@property (weak, nonatomic) IBOutlet UILabel *vodTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *vodSubTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;

@property (weak, nonatomic) IBOutlet UILabel *shortSceneLable;
@property (weak, nonatomic) IBOutlet UILabel *middleSceneLabel;
@property (weak, nonatomic) IBOutlet UILabel *longSceneLabel;
@property (weak, nonatomic) IBOutlet UILabel *shortDramaSceneLabel;
@property (weak, nonatomic) IBOutlet UILabel *settingsLabel;

@end

@implementation VEMainViewController

- (void)viewDidLoad {
    [self configuratoinCustomView];
}

- (void)configuratoinCustomView {
    self.vodTitleLabel.text = NSLocalizedStringFromTable(@"title_volc_vod", @"VodLocalizable", nil);
    self.vodSubTitleLabel.text = NSLocalizedStringFromTable(@"title_volc_vod_desc", @"VodLocalizable", nil);
    
    self.shortSceneLable.text = NSLocalizedStringFromTable(@"title_short_video", @"VodLocalizable", nil);
    self.middleSceneLabel.text = NSLocalizedStringFromTable(@"title_middle_video", @"VodLocalizable", nil);
    self.longSceneLabel.text = NSLocalizedStringFromTable(@"title_long_video", @"VodLocalizable", nil);
    self.shortDramaSceneLabel.text = NSLocalizedStringFromTable(@"title_short_drama_video", @"VodLocalizable", nil);
    self.settingsLabel.text = NSLocalizedStringFromTable(@"title_video_setting", @"VodLocalizable", nil);
    
    self.versionLabel.text = [NSString stringWithFormat:@"TTSDK - %@", [TTSDKManager SDKVersionString]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
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

- (IBAction)shortDramaTouchUpInsideAction:(id)sender {
    VEShortDramaPagingViewController *shortDramaPagingViewController = [[VEShortDramaPagingViewController alloc] initWithDefaultType:VEShortDramaTypeDrama];
    [self.navigationController pushViewController:shortDramaPagingViewController animated:YES];
}


#pragma mark - System

- (UIStatusBarStyle)preferredStatusBarStyle {
    return 3;
}


@end
