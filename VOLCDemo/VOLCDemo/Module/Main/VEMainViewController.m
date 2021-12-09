//
//  VEMainViewController.m
//  VOLCDemo
//
//  Created by real on 2021/5/23.
//

#import "VEMainViewController.h"
#import "VESmallVideoViewController.h"
#import "UIButton+MainViewItem.h"
#import "VEUserGlobalConfigViewController.h"

@interface VEMainViewController ()

@property (nonatomic, strong) UIButton *cleanMDLCacheButton;

@end

@implementation VEMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configuratoinCustomView];
}


#pragma mark - UI

- (void)configuratoinCustomView {

    CGFloat div = 30.0;
    CGFloat btnWidth = 110.0;
    CGFloat btnHeight = 100.0;
    
    UIButton *smallVideoButton = [UIButton __newButtonWithTitle:NSLocalizedString(@"title_small_video", nil) icon:@"icon_small" target:self action:@selector(__handleButtonClicked:) type:SenceButtonTypeSmallVideo];
    [self.view addSubview:smallVideoButton];
    [smallVideoButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).with.offset(230);//207
        make.leading.equalTo(self.view).with.offset(div);
        make.width.mas_equalTo(btnWidth);
        make.height.mas_equalTo(btnHeight);
    }];
    
    
    [self.view addSubview:self.cleanMDLCacheButton];
    [self.cleanMDLCacheButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.view).with.offset(div);
        make.top.equalTo(smallVideoButton.mas_bottom).with.offset(100);
        make.size.mas_equalTo(CGSizeMake(100, 40));
    }];
}

#pragma mark - Pirvate

- (void)__handleButtonClicked:(UIButton *)sender {
    switch (sender.tag) {
        case SenceButtonTypeSmallVideo: {
            VEUserGlobalConfigViewController *configViewController = [[VEUserGlobalConfigViewController alloc] initWithSence:VESenceType_SmallVideo];
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:configViewController];
            navigationController.modalPresentationStyle = UIModalPresentationFullScreen;
            [self presentViewController:navigationController animated:YES completion:^{}];
        }
            break;
        default:{
        }
            break;
    }
}

- (void)__handleCleanButtonClicked:(UIButton *)sender {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.label.text = NSLocalizedString(@"tip_clean_success", nil);
    [hud hideAnimated:YES afterDelay:1.5];
}


#pragma mark - lazy load

- (UIButton *)cleanMDLCacheButton {
    if (!_cleanMDLCacheButton) {
        _cleanMDLCacheButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cleanMDLCacheButton setTitle:NSLocalizedString(@"title_clean_cache", nil) forState:UIControlStateNormal];
        [_cleanMDLCacheButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _cleanMDLCacheButton.titleLabel.font = [UIFont systemFontOfSize:15];
        [_cleanMDLCacheButton addTarget:self action:@selector(__handleCleanButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        _cleanMDLCacheButton.backgroundColor = [[UIColor darkGrayColor] colorWithAlphaComponent:0.5];
        _cleanMDLCacheButton.layer.masksToBounds = YES;
        _cleanMDLCacheButton.layer.cornerRadius = 20.0f;
    }
    return _cleanMDLCacheButton;
}


#pragma mark - System

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}


@end
