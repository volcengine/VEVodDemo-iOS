//
//  VEPlayerLockModule.m
//  VEPlayerKit
//
//  Created by zys on 2025/10/21.
//

#import "VEPlayerLockModule.h"
#import "VEPlayerActionViewInterface.h"
#import "VEPlayerContextKeyDefine.h"
#import "UIView+BDShowView.h"
#import <Masonry/Masonry.h>

@interface VEPlayerLockModule ()

@property (nonatomic, strong) UIButton *lockButton;

@property (nonatomic, assign) BOOL isLocking;

@property (nonatomic, weak) id<VEPlayerActionViewInterface> actionViewInterface;

@end

@implementation VEPlayerLockModule

VEPlayerContextDILink(actionViewInterface, VEPlayerActionViewInterface, self.context);

#pragma mark - Life Cycle

- (void)moduleDidLoad {
    [super moduleDidLoad];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configuratoinCustomView];
    
    @weakify(self);
    
    [self.context addKey:VEPlayerContextKeyViewVisible withObserver:self handler:^(NSNumber *shown, NSString * _Nullable key) {
        @strongify(self);
        BOOL value = [shown boolValue];
        [self.lockButton showView:value];
    }];
    
    [self.context addKey:VEPlayerContextKeyRotateScreen withObserver:self handler:^(NSNumber *ori, NSString * _Nullable key) {
        @strongify(self);
        UIDeviceOrientation curOri = (UIDeviceOrientation)[ori intValue];
        [self.lockButton mas_updateConstraints:^(MASConstraintMaker *make) {
            if (curOri == UIDeviceOrientationPortrait) {
                [self.lockButton mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.left.equalTo(self.actionViewInterface.overlayControlView).offset(12);
                }];
            }else if (curOri == UIDeviceOrientationLandscapeRight) {
                [self.lockButton mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.left.equalTo(self.actionViewInterface.overlayControlView).offset(44);
                }];
            }
        }];
    }];
}

- (void)controlViewTemplateDidUpdate {
    [super controlViewTemplateDidUpdate];
}

- (void)configuratoinCustomView {
    [self.actionViewInterface.overlayControlView addSubview:self.lockButton];
    [self.lockButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.actionViewInterface.overlayControlView).offset(110);
        make.left.equalTo(self.actionViewInterface.overlayControlView).offset(12);
        make.size.mas_equalTo(CGSizeMake(36, 36));
    }];
}

- (void)moduleDidUnLoad {
    [super moduleDidUnLoad];
    if (self.lockButton) {
        [self.lockButton removeFromSuperview];
        self.lockButton = nil;
    }
}

#pragma mark - lazy load

- (UIButton *)lockButton {
    if (!_lockButton) {
        _lockButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_lockButton setImage:[UIImage imageNamed:@"long_video_unlock"] forState:UIControlStateNormal];
        [_lockButton addTarget:self action:@selector(onClickLockButtonHandle:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _lockButton;
}

#pragma mark - event

- (void)onClickLockButtonHandle:(UIButton *)sender {
    self.isLocking = !self.isLocking;
    if (self.isLocking) {
        [_lockButton setImage:[UIImage imageNamed:@"long_video_lock"] forState:UIControlStateNormal];
        [self.context post:@(1) forKey:VEPlayerContextKeyLockControl];
    }else {
        [_lockButton setImage:[UIImage imageNamed:@"long_video_unlock"] forState:UIControlStateNormal];
        [self.context post:@(0) forKey:VEPlayerContextKeyLockControl];
    }
}

@end
