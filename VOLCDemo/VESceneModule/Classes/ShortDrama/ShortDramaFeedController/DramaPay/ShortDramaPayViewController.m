//
//  ShortDramaPayViewController.m
//  Pods
//
//  Created by zyw on 2024/7/23.
//

#import "ShortDramaPayViewController.h"
#import <Masonry/Masonry.h>
#import "UIColor+RGB.h"
#import "ShortDramaCachePayManager.h"
#import <MBProgressHUD/MBProgressHUD.h>

@interface ShortDramaPayViewController ()

@property (nonatomic, strong) UILabel *priceLabel;
@property (nonatomic, strong) UIImageView *moneyIcomImageView;

@property (nonatomic, strong) VEDramaVideoInfoModel *dramaVideoInfo;

@end

@implementation ShortDramaPayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configuratoinCustomView];
}

- (void)configuratoinCustomView {
    self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    
    UIView *containerView = [[UIView alloc] init];
    containerView.backgroundColor = [UIColor whiteColor];
    containerView.layer.cornerRadius = 16;
    [self.view addSubview:containerView];
    [containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(280, 230));
    }];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.font = [UIFont boldSystemFontOfSize:17];
    titleLabel.textColor = [UIColor colorWithRGB:0x161823 alpha:1.0];
    titleLabel.text = NSLocalizedStringFromTable(@"short_drama_pay_title", @"VodLocalizable", nil);
    [containerView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(containerView).with.offset(30);
        make.centerX.equalTo(containerView);
    }];
    
    _priceLabel = [[UILabel alloc] init];
    _priceLabel.font = [UIFont boldSystemFontOfSize:30];
    _priceLabel.textColor = [UIColor blackColor];
    [containerView addSubview:_priceLabel];
    [_priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleLabel.mas_bottom).with.offset(20);
        make.centerX.equalTo(containerView).with.offset(-10);
    }];
    
    _moneyIcomImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_money"]];
    [containerView addSubview:_moneyIcomImageView];
    [_moneyIcomImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.priceLabel.mas_right).with.offset(2);
        make.centerY.equalTo(self.priceLabel);
    }];
    
    UIButton *leaveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [leaveButton setBackgroundColor:[UIColor clearColor]];
    [leaveButton setTitleColor:[UIColor colorWithRGB:0x161823 alpha:.6] forState:UIControlStateNormal];
    leaveButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [leaveButton setTitle:NSLocalizedStringFromTable(@"short_drama_pay_leave_button_title", @"VodLocalizable", nil) forState:UIControlStateNormal];
    [leaveButton addTarget:self action:@selector(leaveButtonHandle) forControlEvents:UIControlEventTouchUpInside];
    [containerView addSubview:leaveButton];
    [leaveButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(containerView).with.offset(-5);
        make.left.equalTo(containerView).with.offset(30);
        make.right.equalTo(containerView).with.offset(-30);
        make.height.mas_equalTo(44);
    }];
    
    UIButton *payButton = [UIButton buttonWithType:UIButtonTypeCustom];
    payButton.layer.cornerRadius = 8;
    [payButton setBackgroundColor:[UIColor colorWithRGB:0xFE2C55 alpha:1.0]];
    [payButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    payButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [payButton setTitle:NSLocalizedStringFromTable(@"short_drama_pay_button_title", @"VodLocalizable", nil) forState:UIControlStateNormal];
    [payButton addTarget:self action:@selector(payButtonHandle) forControlEvents:UIControlEventTouchUpInside];
    [containerView addSubview:payButton];
    [payButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(leaveButton.mas_top).with.offset(-5);
        make.left.equalTo(containerView).with.offset(30);
        make.right.equalTo(containerView).with.offset(-30);
        make.height.mas_equalTo(44);
    }];
}

#pragma mark - Public

- (void)reloadData:(VEDramaVideoInfoModel *)dramaVideoInfo {
    self.dramaVideoInfo = dramaVideoInfo;
    self.priceLabel.text = [NSString stringWithFormat:@"%.1f", dramaVideoInfo.payInfo.price / 100.0];
}

#pragma mark - Private

- (void)payButtonHandle {
    if (self.delegate && [self.delegate respondsToSelector:@selector(onPayingCallback:)]) {
        [self.delegate onPayingCallback:self.dramaVideoInfo];
    }

    NSString *message = NSLocalizedStringFromTable(@"short_drama_pay_paying", @"VodLocalizable", nil);
    MBProgressHUD *hud = [self showPaymentLoading:message];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSString *message = NSLocalizedStringFromTable(@"short_drama_pay_success", @"VodLocalizable", nil);
        hud.label.text = message;
        [hud hideAnimated:YES afterDelay:2.0];
        
        // test payment success
        [[ShortDramaCachePayManager shareInstance] cachePaidDrama:self.dramaVideoInfo.dramaEpisodeInfo.dramaInfo.dramaId episodeNumber:self.dramaVideoInfo.dramaEpisodeInfo.episodeNumber];
        self.dramaVideoInfo.payInfo.payStatus = VEDramaPayStatus_Paid;
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(onPaySuccessCallback:)]) {
            [self.delegate onPaySuccessCallback:self.dramaVideoInfo];
        }
    });
}

- (void)leaveButtonHandle {
    if (self.delegate && [self.delegate respondsToSelector:@selector(onPayCancelCallback:)]) {
        [self.delegate onPayCancelCallback:self.dramaVideoInfo];
    }
}

- (MBProgressHUD *)showPaymentLoading:(NSString *)message {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:UIApplication.sharedApplication.keyWindow animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.label.text = message;
    hud.offset = CGPointMake(0, 50);
    return hud;
}

@end
