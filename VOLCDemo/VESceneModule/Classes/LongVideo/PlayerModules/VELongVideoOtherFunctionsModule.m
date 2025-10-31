//
//  VELongVideoOtherFunctionsModule.m
//  VESceneModule
//
//  Created by zys on 2025/10/15.
//

#import "VELongVideoOtherFunctionsModule.h"
#import "VEPlayerContextKeyDefine.h"
#import "VEPlayerActionViewInterface.h"
#import <Masonry/Masonry.h>
#import "UIView+BDShowView.h"
#import "VELongVideoOtherFunctionsView.h"
#import "VEVideoPlayback.h"

@interface VELongVideoOtherFunctionsModule ()

@property (nonatomic, strong) UIButton *otherButton;

@property (nonatomic, strong) VELongVideoOtherFunctionsView *otherFunctionsView;

@property (nonatomic, weak) id<VEVideoPlayback> playerInterface;

@property (nonatomic, weak) id<VEPlayerActionViewInterface> actionViewInterface;

@property (nonatomic, assign) BOOL isLocking;

@end

@implementation VELongVideoOtherFunctionsModule

VEPlayerContextDILink(playerInterface, VEVideoPlayback, self.context);
VEPlayerContextDILink(actionViewInterface, VEPlayerActionViewInterface, self.context);

#pragma mark - Life Cycle

- (void)moduleDidLoad {
    [super moduleDidLoad];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configuratoinCustomView];
    
    @weakify(self)
    [self.context addKey:VEPlayerContextKeyViewVisible withObserver:self handler:^(NSNumber *shown, NSString * _Nullable key) {
        @strongify(self);
        if (!self.isLocking) {
            BOOL value = [shown boolValue];
            [self.otherButton showView:value];
        }
    }];
    
    [self.context addKey:VEPlayerContextKeyRotateScreen withObserver:self handler:^(NSNumber *ori, NSString * _Nullable key) {
        @strongify(self);
        UIDeviceOrientation curOri = (UIDeviceOrientation)[ori intValue];
        if (curOri == UIDeviceOrientationLandscapeRight) {
            [self.otherButton mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(30, 30));
                make.right.equalTo(self.actionViewInterface.overlayControlView).offset(-55);
                make.top.equalTo(self.actionViewInterface.overlayControlView).offset(20);
            }];
        }else if (curOri == UIDeviceOrientationPortrait) {
            [self.otherButton mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(30, 30));
                make.right.equalTo(self.actionViewInterface.overlayControlView).offset(-5);
                make.top.equalTo(self.actionViewInterface.overlayControlView).offset(20);
            }];
        }
    }];
    
    [self.context addKey:VEPlayerContextKeyLockControl withObserver:self handler:^(NSNumber *lock, NSString * _Nullable key) {
        @strongify(self);
        BOOL value = [lock boolValue];
        self.isLocking = value;
        [self.otherButton showView:!value];
    }];
}

- (void)controlViewTemplateDidUpdate {
    [super controlViewTemplateDidUpdate];
}

- (void)configuratoinCustomView {
    [self.actionViewInterface.overlayControlView addSubview:self.otherButton];
    
    [self.otherButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(30, 30));
        make.right.equalTo(self.actionViewInterface.overlayControlView).offset(-5);
        make.top.equalTo(self.actionViewInterface.overlayControlView).offset(20);
    }];
}

- (void)moduleDidUnLoad {
    [super moduleDidUnLoad];
    if (self.otherButton) {
        [self.otherButton removeFromSuperview];
        self.otherButton = nil;
    }
}

#pragma mark - Lazy Load

- (UIButton *)otherButton {
    if (_otherButton == nil) {
        _otherButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_otherButton setImage:[UIImage imageNamed:@"long_video_more"] forState:UIControlStateNormal];
        [_otherButton addTarget:self action:@selector(onClickOtherButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _otherButton;
}

- (VELongVideoOtherFunctionsView *)otherFunctionsView {
    if (!_otherFunctionsView) {
        _otherFunctionsView = [[VELongVideoOtherFunctionsView alloc] init];
        _otherFunctionsView.context = self.context;
        _otherFunctionsView.playerInterface = self.playerInterface;
    }
    return _otherFunctionsView;
}

#pragma mark - event

- (void)onClickOtherButton:(UIButton *)sender {
    [self.context post:@(0) forKey:VEPlayerContextKeyViewVisible];
    [self.actionViewInterface.playbackControlView addSubview:self.otherFunctionsView];
    [self.otherFunctionsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.actionViewInterface.playbackControlView);
    }];
}

@end
