//
//  VEPlayerFullScreenModule.m
//  VEPlayerKit
//
//  Created by zys on 2025/10/20.
//

#import "VEPlayerFullScreenModule.h"
#import "VEPlayerActionViewInterface.h"
#import "VEPlayerContextKeyDefine.h"
#import "UIView+BDShowView.h"
#import "UIViewController+Orientation.h"
#import <Masonry/Masonry.h>

@interface VEPlayerFullScreenModule ()

@property (nonatomic, weak) UIViewController *curVC;

@property (nonatomic, strong) UIButton *fullScreenButton;

@property (nonatomic, weak) id<VEPlayerActionViewInterface> actionViewInterface;

@property (nonatomic, assign) BOOL isLocking;

@end

@implementation VEPlayerFullScreenModule

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
            [self.fullScreenButton showView:value];
        }
    }];
    
    [self.context addKey:VEPlayerContextKeyRotateScreen withObserver:self handler:^(NSNumber *ori, NSString * _Nullable key) {
        @strongify(self);
        UIDeviceOrientation curOri = (UIDeviceOrientation)[ori intValue];
        if (curOri == UIDeviceOrientationLandscapeRight) {
            [self.fullScreenButton removeFromSuperview];
        }else if (curOri == UIDeviceOrientationPortrait) {
            [self configuratoinCustomView];
        }
    }];
    
    [self.context addKey:VEPlayerContextKeyLockControl withObserver:self handler:^(NSNumber *lock, NSString * _Nullable key) {
        @strongify(self);
        BOOL value = [lock boolValue];
        self.isLocking = value;
        [self.fullScreenButton showView:!value];
    }];
}

- (void)controlViewTemplateDidUpdate {
    [super controlViewTemplateDidUpdate];
}

- (void)configuratoinCustomView {

    [self.actionViewInterface.playbackControlView addSubview:self.fullScreenButton];
    
    [self.fullScreenButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.actionViewInterface.playbackControlView);
        make.right.equalTo(self.actionViewInterface.playbackControlView);
        make.size.mas_equalTo(CGSizeMake(40, 40));
    }];

}

- (void)moduleDidUnLoad {
    [super moduleDidUnLoad];
    if (self.fullScreenButton) {
        [self.fullScreenButton removeFromSuperview];
        self.fullScreenButton = nil;
    }
}

#pragma mark - lazy load

- (UIButton *)fullScreenButton {
    if (_fullScreenButton == nil) {
        _fullScreenButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_fullScreenButton setImage:[UIImage imageNamed:@"long_video_portrait"] forState:UIControlStateNormal];
        [_fullScreenButton addTarget:self action:@selector(onFullScreenButtonHandle:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _fullScreenButton;
}

#pragma mark - Event Response

- (void)onFullScreenButtonHandle:(UIButton *)button {
    if (self.curVC == NULL) {
        return;
    }
    [self.curVC setDeviceInterfaceOrientation:UIDeviceOrientationLandscapeRight];
    [self.context post:@(UIDeviceOrientationLandscapeRight) forKey:VEPlayerContextKeyRotateScreen];
}

@end

