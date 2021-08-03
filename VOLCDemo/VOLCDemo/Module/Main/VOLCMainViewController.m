//
//  VOLCMainViewController.m
//  VOLCDemo
//
//  Created by real on 2021/5/23.
//

#import "VOLCMainViewController.h"
#import "VOLCSmallVideoViewController.h"
#import "VOLCPreloadHelper.h"

typedef  NS_ENUM(NSUInteger, SenceButtonType){
    SenceButtonTypeSmallVideo,
};

@interface VOLCMainViewController ()

@property (nonatomic, strong) UIButton *cleanMDLCacheButton;

@end

@implementation VOLCMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configuratoinCustomView];
}

#pragma mark - UI

- (void)configuratoinCustomView {
    [self.navigationController setNavigationBarHidden:YES];
    
    UIButton *smallVideoButton = [self __newButtonWithTitle:NSLocalizedString(@"title_small_video", nil) icon:@"icon_small" target:self action:@selector(__handleButtonClicked:) type:SenceButtonTypeSmallVideo];
    [self.view addSubview:smallVideoButton];
    [smallVideoButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).with.offset(230);//207
        make.left.equalTo(self.view).with.offset(30);
        make.width.mas_equalTo(110);
        make.height.mas_equalTo(100);
    }];
    
    [self.view addSubview:self.cleanMDLCacheButton];
    [self.cleanMDLCacheButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).with.offset(30);
        make.top.equalTo(smallVideoButton.mas_bottom).with.offset(100);
        make.size.mas_equalTo(CGSizeMake(100, 40));
    }];
}

#pragma mark - Pirvate

- (void)__handleButtonClicked:(UIButton *)sender {
    switch (sender.tag) {
        case SenceButtonTypeSmallVideo: {
            VOLCSmallVideoViewController *smallVideoController = [[VOLCSmallVideoViewController alloc] init];
            [self.navigationController pushViewController:smallVideoController animated:YES];
        }
            break;
            
        default:
            break;
    }
}

- (void)__handleCleanButtonClicked {
    [[VOLCPreloadHelper shareInstance] cleanAllCacheData];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.label.text = NSLocalizedString(@"tip_clean_success", nil);
    [hud hideAnimated:YES afterDelay:1.5];
}

- (UIButton *)__newButtonWithTitle:(NSString*)title icon:(NSString*)iconName target:(id)target action:(SEL)selector type:(SenceButtonType)type {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *icon = [UIImage imageNamed:iconName];
    CGSize imgSize = icon.size;
    UIImageView *imageView = [[UIImageView alloc] initWithImage:icon];
    [button addSubview:imageView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(button).with.offset(15);
        make.centerX.equalTo(button);
        make.size.mas_equalTo(CGSizeMake(imgSize.width/2, imgSize.height/2));
    }];
    
    UILabel *label = [[UILabel alloc] init];
    label.text = title;
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:14.f];
    [button addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(imageView.mas_bottom).with.offset(10);
        make.centerX.equalTo(button);
    }];
    
    button.backgroundColor = [UIColor darkGrayColor];
    button.tag = type;
    button.layer.cornerRadius = 10;
    [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}


#pragma mark - lazy load

- (UIButton *)cleanMDLCacheButton {
    if (!_cleanMDLCacheButton) {
        _cleanMDLCacheButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cleanMDLCacheButton setTitle:NSLocalizedString(@"title_clean_cache", nil) forState:UIControlStateNormal];
        [_cleanMDLCacheButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _cleanMDLCacheButton.titleLabel.font = [UIFont systemFontOfSize:15];
        [_cleanMDLCacheButton addTarget:self action:@selector(__handleCleanButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        _cleanMDLCacheButton.backgroundColor = [[UIColor darkGrayColor] colorWithAlphaComponent:0.5];
        _cleanMDLCacheButton.layer.masksToBounds = YES;
        _cleanMDLCacheButton.layer.cornerRadius = 20.0f;
    }
    return _cleanMDLCacheButton;
}


#pragma mark - System

- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}


@end
