//
//  VEPlayerSpeedModule.m
//  VEPlayerKit
//
//  Created by zys on 2025/10/21.
//

#import "VEPlayerSpeedModule.h"
#import "VEPlayerSpeedView.h"
#import "VEPlayerActionViewInterface.h"
#import "VEPlayerContextKeyDefine.h"
#import "UIView+BDShowView.h"
#import <Masonry/Masonry.h>

@interface VEPlayerSpeedModule ()

@property (nonatomic, strong) UIButton *speedButton;

@property (nonatomic, strong) VEPlayerSpeedView *speedView;

@property (nonatomic, weak) id<VEPlayerActionViewInterface> actionViewInterface;

@property (nonatomic, assign) BOOL isLandscape;

@property (nonatomic, assign) BOOL isLocking;

@end

@implementation VEPlayerSpeedModule

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
        if (self.isLandscape && !self.isLocking) {
            [self.speedButton showView:value];
        }
    }];
    
    [self.context addKey:VEPlayerContextKeyRotateScreen withObserver:self handler:^(NSNumber *ori, NSString * _Nullable key) {
        @strongify(self);
        UIDeviceOrientation curOri = (UIDeviceOrientation)[ori intValue];
        if (curOri == UIDeviceOrientationLandscapeRight) {
            self.isLandscape = YES;
            [self.actionViewInterface.playbackControlView addSubview:self.speedButton];
            [self.speedButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(80, 30));
                make.right.equalTo(self.actionViewInterface.playbackControlView).offset(-160);
                make.bottom.equalTo(self.actionViewInterface.playbackControlView).offset(-20);
            }];
        }else if (curOri == UIDeviceOrientationPortrait) {
            self.isLandscape = NO;
            [self.speedButton removeFromSuperview];
        }
    }];
    
    [self.context addKey:VEPlayerContextKeyPlaybackSpeedChanged withObserver:self handler:^(NSNumber *speed, NSString * _Nullable key) {
        @strongify(self);
        NSString *speedStr = [NSString stringWithFormat:@"%.1fx", [speed doubleValue]];
        [self.speedButton setTitle:speedStr forState:UIControlStateNormal];
    }];
    
    [self.context addKey:VEPlayerContextKeyLockControl withObserver:self handler:^(NSNumber *lock, NSString * _Nullable key) {
        @strongify(self);
        BOOL value = [lock boolValue];
        self.isLocking = value;
        [self.speedButton showView:!value];
    }];
}

- (void)controlViewTemplateDidUpdate {
    [super controlViewTemplateDidUpdate];
}

- (void)configuratoinCustomView {

}

- (void)moduleDidUnLoad {
    [super moduleDidUnLoad];
    if (self.speedButton) {
        [self.speedButton removeFromSuperview];
        self.speedButton = nil;
    }
}

#pragma mark - lazy load

- (UIButton *)speedButton {
    if (_speedButton == nil) {
        _speedButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_speedButton setImage:[UIImage imageNamed:@"long_video_speed"] forState:UIControlStateNormal];
        [_speedButton setTitle:@"1.0x" forState:UIControlStateNormal];
        [_speedButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_speedButton addTarget:self action:@selector(onSpeedButtonHandle:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _speedButton;
}

- (VEPlayerSpeedView *)speedView {
    if (!_speedView) {
        _speedView = [[VEPlayerSpeedView alloc] init];
        _speedView.context = self.context;
    }
    return _speedView;
}

#pragma mark - Event Response

- (void)onSpeedButtonHandle:(UIButton *)button {
    [self.context post:@(0) forKey:VEPlayerContextKeyViewVisible];
    [self.context post:@(0) forKey:VEPlayerContextKeyGestureEnabled];
    [self.actionViewInterface.playbackControlView addSubview:self.speedView];
    [self.speedView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.actionViewInterface.playbackControlView);
    }];
}

@end
