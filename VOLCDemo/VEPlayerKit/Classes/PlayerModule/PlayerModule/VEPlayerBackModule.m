//
//  VEPlayerBackModule.m
//  VEPlayerKit
//
//  Created by zys on 2025/10/17.
//

#import "VEPlayerBackModule.h"
#import "VEPlayerActionViewInterface.h"
#import "VEPlayerContextKeyDefine.h"
#import "VEVideoPlayerController+Strategy.h"
#import "VEVideoPlayerPipController.h"
#import "UIView+BDShowView.h"
#import "UIViewController+Orientation.h"
#import <Masonry/Masonry.h>

@interface VEPlayerBackModule ()

@property (nonatomic, strong) UIButton *backButton;

@property (nonatomic, weak) id<VEPlayerActionViewInterface> actionViewInterface;

@property (nonatomic, assign) BOOL isLocking;

@end

@implementation VEPlayerBackModule

VEPlayerContextDILink(actionViewInterface, VEPlayerActionViewInterface, self.context);

#pragma mark - Life Cycle

- (instancetype)initWithCurVC:(UIViewController *)vc {
    self = [super init];
    if (self) {
        _curVC = vc;
    }
    return self;
}

- (void)moduleDidLoad {
    [super moduleDidLoad];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self configuratoinCustomView];

    @weakify(self);
    
    [self.context addKey:VEPlayerContextKeyViewVisible withObserver:self handler:^(NSNumber *shown, NSString * _Nullable key) {
        @strongify(self);
        if (!self.isLocking) {
            BOOL value = [shown boolValue];
            [self.backButton showView:value];
        }
    }];
    
    [self.context addKey:VEPlayerContextKeyRotateScreen withObserver:self handler:^(NSNumber *ori, NSString * _Nullable key) {
        @strongify(self);
        if (self.backButton.superview == NULL) {
            [self configuratoinCustomView];
        }
        UIDeviceOrientation curOri = (UIDeviceOrientation)[ori intValue];
        if (curOri == UIDeviceOrientationLandscapeRight) {
            [self.backButton mas_updateConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.actionViewInterface.playbackControlView).offset(40);
            }];
        }else if (curOri == UIDeviceOrientationPortrait) {
            [self.backButton mas_updateConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.actionViewInterface.playbackControlView).offset(3);
            }];
        }
    }];
    
    [self.context addKey:VEPlayerContextKeyLockControl withObserver:self handler:^(NSNumber *lock, NSString * _Nullable key) {
        @strongify(self);
        BOOL value = [lock boolValue];
        self.isLocking = value;
        [self.backButton showView:!value];
    }];
}

- (void)controlViewTemplateDidUpdate {
    [super controlViewTemplateDidUpdate];
}

- (void)configuratoinCustomView {
    [self.actionViewInterface.playbackControlView addSubview:self.backButton];
    [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.actionViewInterface.playbackControlView).offset(15);
        make.left.equalTo(self.actionViewInterface.playbackControlView).offset(3);
        make.size.mas_equalTo(CGSizeMake(40, 40));
    }];
}

- (void)moduleDidUnLoad {
    [super moduleDidUnLoad];
    if (self.backButton) {
        [self.backButton removeFromSuperview];
        self.backButton = nil;
    }
}

#pragma mark - lazy load

- (UIButton *)backButton {
    if (_backButton == nil) {
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backButton setImage:[UIImage imageNamed:@"video_page_back"] forState:UIControlStateNormal];
        [_backButton addTarget:self action:@selector(onBackButtonHandle:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backButton;
}

#pragma mark - Event Response

- (void)onBackButtonHandle:(UIButton *)button {
    if (self.curVC == NULL) {
        return;
    }
    if (self.curVC.orientation != UIInterfaceOrientationPortrait) {
        [self.curVC setDeviceInterfaceOrientation:UIDeviceOrientationPortrait];
        [self.context post:@(UIDeviceOrientationPortrait) forKey:VEPlayerContextKeyRotateScreen];
    }else {
        UIViewController *presentingViewController = self.curVC.presentingViewController;
        if (presentingViewController) {
            [presentingViewController dismissViewControllerAnimated:NO completion:nil];
        } else if (self.curVC.navigationController) {
            [self.curVC.navigationController popViewControllerAnimated:YES];
        }
        [VEVideoPlayerController clearAllEngineStrategy];
        [[VEVideoPlayerPipController shared] stopPip];
    }
}

@end
