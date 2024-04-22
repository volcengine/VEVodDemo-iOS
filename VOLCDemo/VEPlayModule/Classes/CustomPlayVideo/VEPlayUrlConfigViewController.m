//
//  VEPlayUrlConfigViewController.m
//  VideoPlaybackEdit
//
//  Created by bytedance on 2023/11/1.
//

#import "VEPlayUrlConfigViewController.h"
#import <Masonry/Masonry.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import "VEVideoUrlParser.h"
#import "VEShortVideoViewController.h"
#import "VEFeedVideoViewController.h"
#import "VESettingModel.h"
#import "VESettingManager.h"

@interface VEPlayUrlConfigViewController ()

@property (nonatomic, strong) UITextView *inputView;
@property (nonatomic, strong) UILabel *tipsLable;
@property (nonatomic, assign) CGFloat keyboardHeight;

@end

@implementation VEPlayUrlConfigViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initialUI];
}

#pragma mark ----- Base

- (void)initialUI {
    self.view.backgroundColor = [UIColor whiteColor];

    self.inputView = [UITextView new];
    
    self.inputView.textColor = [UIColor blackColor];
    [self.view addSubview:self.inputView];
    self.inputView.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1.0];
    self.inputView.layer.cornerRadius = 5;
    [self.inputView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(10);
        make.right.equalTo(self.view).offset(-10);
        if (@available(iOS 11.0, *)) {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(20);
        } else {
            make.top.equalTo(self.view).offset(64);
        }
        make.height.equalTo(@(300));
    }];
    
    self.tipsLable = [[UILabel alloc] init];
    self.tipsLable.font = [UIFont systemFontOfSize:13];
    self.tipsLable.textColor = [UIColor redColor];
    self.tipsLable.numberOfLines = 0;
    self.tipsLable.text = NSLocalizedStringFromTable(@"title_custom_source_valid_tip", @"VodLocalizable", nil);
    [self.view addSubview:self.tipsLable];
    [self.tipsLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(10);
        make.right.equalTo(self.view).offset(-10);
        make.top.equalTo(self.inputView.mas_bottom).offset(15);
        make.height.equalTo(@(36));
    }];
    
    NSArray *titles = @[ NSLocalizedStringFromTable(@"title_custom_source_enter_short_video", @"VodLocalizable", nil),
                         NSLocalizedStringFromTable(@"title_custom_source_enter_feed_video", @"VodLocalizable", nil),
                         NSLocalizedStringFromTable(@"title_custom_source_clean_cache", @"VodLocalizable", nil) ];
    
    CGFloat buttonHeight = 44;
    CGRect rect = CGRectMake(10, self.view.frame.size.height - buttonHeight*3 - 20 - 40, self.view.frame.size.width-20, buttonHeight);
    for (NSUInteger i = 0; i <= titles.count - 1; i++) {
        NSString *title = titles[i];
        UIButton *btn = [UIButton new];
        [btn setTitle:title forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn setBackgroundColor:[UIColor colorWithWhite:0.8 alpha:1.0]];
        btn.layer.cornerRadius = 4;
        btn.tag = i;
        [btn addTarget:self action:@selector(onButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn];
        btn.frame = rect;
        rect.origin.y += buttonHeight + 10;
    }
    
    self.title = NSLocalizedStringFromTable(@"title_custom_source", @"VodLocalizable", nil);
    self.navigationItem.leftBarButtonItem = ({
        UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(close)];
        leftItem.tintColor = [UIColor blackColor];
        leftItem;
    });
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillShow:)
                                                     name:UIKeyboardWillShowNotification
                                                   object:nil];
    
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
    [self.view addGestureRecognizer:tap];
}

- (void)keyboardWillShow:(NSNotification *)noti {
    NSValue *value = [noti.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect rect = value.CGRectValue;
    self.keyboardHeight = rect.size.height;
}

- (void)onTap:(UITapGestureRecognizer *)tap {
    CGPoint point = [tap locationInView:self.view];
    if (self.keyboardHeight > 0 && point.y < self.view.frame.size.height - self.keyboardHeight) {
        [self.inputView resignFirstResponder];
    }
}

- (void)onButtonClick:(UIButton *)sender {
    if (sender.tag == 2) {
        self.inputView.text = nil;
        return;
    }
    NSString *url = [self.inputView text];
    if (!url.length) {
        [self showTipMessage:@"Input url is nil, please check it."];
        return;
    }
    NSArray *videoModels = [VEVideoUrlParser parseUrl:url];
    if (!videoModels.count) {
        [self showTipMessage:@"Input url error, please check it."];
        return;
    }
    
    VESettingModel *model = [[VESettingManager universalManager] settingForKey:VESettingKeyUniversalPlaySourceType];
    model.currentValue = @(VEPlaySourceType_Url);
    if (sender.tag == 0) {
        //short video
        VEShortVideoViewController *vc = [[VEShortVideoViewController alloc] initWtihVideoSources:videoModels];
        [self.navigationController pushViewController:vc animated:YES];
    } else if (sender.tag == 1) {
        //feed video
        VEFeedVideoViewController *vc = [[VEFeedVideoViewController alloc] initWtihVideoSources:videoModels];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)onClose {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)showTipMessage:(NSString *)tip {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:UIApplication.sharedApplication.keyWindow animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.label.text = tip;
    [hud hideAnimated:YES afterDelay:1.0];
}

@end
