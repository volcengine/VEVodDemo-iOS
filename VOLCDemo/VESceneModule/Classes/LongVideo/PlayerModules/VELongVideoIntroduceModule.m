//
//  VELongVideoIntroduceModule.m
//  VESceneModule
//
//  Created by zys on 2025/10/14.
//

#import "VELongVideoIntroduceModule.h"
#import "VEPlayerContextKeyDefine.h"
#import "VELongVideoIntroduceView.h"
#import "VEPlayerActionViewInterface.h"
#import <Masonry/Masonry.h>
#import "UIView+BDShowView.h"

@interface VELongVideoIntroduceModule ()

@property (nonatomic, strong) VELongVideoIntroduceView *introduceView;

@property (nonatomic, weak) id<VEPlayerActionViewInterface> actionViewInterface;

@property (nonatomic, assign) BOOL isLocking;

@end

@implementation VELongVideoIntroduceModule

VEPlayerContextDILink(actionViewInterface, VEPlayerActionViewInterface, self.context);

#pragma mark - Life Cycle

- (void)moduleDidLoad {
    [super moduleDidLoad];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configuratoinCustomView];
    
    @weakify(self)
    [self.context addKey:VEPlayerContextKeyDataModelChanged withObserver:self handler:^(NSString * _Nullable title, NSString * _Nullable key) {
        @strongify(self);
        [self.introduceView updateTitle:title];
    }];
    
    [self.context addKey:VEPlayerContextKeyViewVisible withObserver:self handler:^(NSNumber *shown, NSString * _Nullable key) {
        @strongify(self);
        if (!self.isLocking) {
            BOOL value = [shown boolValue];
            [self.introduceView showView:value];
        }
    }];
    
    [self.context addKey:VEPlayerContextKeyRotateScreen withObserver:self handler:^(NSNumber *ori, NSString * _Nullable key) {
        @strongify(self);
        UIDeviceOrientation curOri = (UIDeviceOrientation)[ori intValue];
        if (curOri == UIDeviceOrientationLandscapeRight) {
            [self.introduceView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.actionViewInterface.playbackControlView).offset(72);
            }];
        }else if (curOri == UIDeviceOrientationPortrait) {
            [self.introduceView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.actionViewInterface.playbackControlView).offset(35);
            }];
        }
    }];
    
    [self.context addKey:VEPlayerContextKeyLockControl withObserver:self handler:^(NSNumber *lock, NSString * _Nullable key) {
        @strongify(self);
        BOOL value = [lock boolValue];
        self.isLocking = value;
        [self.introduceView showView:!value];
    }];
}

- (void)controlViewTemplateDidUpdate {
    [super controlViewTemplateDidUpdate];
}

- (void)configuratoinCustomView {
    [self.actionViewInterface.playbackControlView addSubview:self.introduceView];
    
    [self.introduceView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.actionViewInterface.playbackControlView).offset(35);
        make.right.equalTo(self.actionViewInterface.playbackControlView).offset(-40);
        make.top.equalTo(self.actionViewInterface.playbackControlView).offset(15);
        make.height.mas_equalTo(30);
    }];
}

- (void)moduleDidUnLoad {
    [super moduleDidUnLoad];
    if (self.introduceView) {
        [self.introduceView removeFromSuperview];
        self.introduceView = nil;
    }
}

#pragma mark - Getter

- (VELongVideoIntroduceView *)introduceView {
    if (_introduceView == nil) {
        _introduceView = [[VELongVideoIntroduceView alloc] init];
    }
    return _introduceView;
}

@end
