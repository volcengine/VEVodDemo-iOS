//
//  VEPlayerResolutionModule.m
//  VEPlayerKit
//
//  Created by zys on 2025/10/20.
//

#import "VEPlayerResolutionModule.h"
#import "VEPlayerActionViewInterface.h"
#import "VEPlayerContextKeyDefine.h"
#import "UIView+BDShowView.h"
#import "VEVideoPlayback.h"
#import "VEVideoPlayerController.h"
#import "VEPlayerResolutionView.h"
#import <Masonry/Masonry.h>

@interface VEPlayerResolutionModule ()

@property (nonatomic, strong) UIButton *resolutionButton;

@property (nonatomic, strong) VEPlayerResolutionView *resolutionView;

@property (nonatomic, weak) id<VEPlayerActionViewInterface> actionViewInterface;

@property (nonatomic, weak) id<VEVideoPlayback> playerInterface;

@property (nonatomic, assign) BOOL isLandscape;

@property (nonatomic, assign) BOOL isLocking;

@end

@implementation VEPlayerResolutionModule

VEPlayerContextDILink(playerInterface, VEVideoPlayback, self.context);
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
            [self.resolutionButton showView:value];
        }
    }];
    
    [self.context addKey:VEPlayerContextKeyRotateScreen withObserver:self handler:^(NSNumber *ori, NSString * _Nullable key) {
        @strongify(self);
        UIDeviceOrientation curOri = (UIDeviceOrientation)[ori intValue];
        if (curOri == UIDeviceOrientationLandscapeRight) {
            self.isLandscape = YES;
            [self.actionViewInterface.playbackControlView addSubview:self.resolutionButton];
            [self.resolutionButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(80, 30));
                make.right.equalTo(self.actionViewInterface.playbackControlView).offset(-75);
                make.bottom.equalTo(self.actionViewInterface.playbackControlView).offset(-20);
            }];
        }else if (curOri == UIDeviceOrientationPortrait) {
            self.isLandscape = NO;
            [self.resolutionButton removeFromSuperview];
        }
    }];
    
    [self.context addKey:VEPlayerContextKeyResolutionChanged withObserver:self handler:^(NSNumber *resolution, NSString * _Nullable key) {
        @strongify(self);
        TTVideoEngineResolutionType selectedResolution = (TTVideoEngineResolutionType)[resolution intValue];
        NSString *selectedResolutionStr = [VEVideoPlayerController transferResolutionTitleByType:selectedResolution];
        [self.resolutionButton setTitle:selectedResolutionStr forState:UIControlStateNormal];
    }];
    
    [self.context addKey:VEPlayerContextKeyLockControl withObserver:self handler:^(NSNumber *lock, NSString * _Nullable key) {
        BOOL value = [lock boolValue];
        self.isLocking = value;
        [self.resolutionButton showView:!value];
    }];
}

- (void)controlViewTemplateDidUpdate {
    [super controlViewTemplateDidUpdate];
}

- (void)configuratoinCustomView {

}

- (void)moduleDidUnLoad {
    [super moduleDidUnLoad];
    if (self.resolutionButton) {
        [self.resolutionButton removeFromSuperview];
        self.resolutionButton = nil;
    }
}

#pragma mark - lazy load

- (UIButton *)resolutionButton {
    if (_resolutionButton == nil) {
        _resolutionButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_resolutionButton setImage:[UIImage imageNamed:@"long_video_resolution"] forState:UIControlStateNormal];
        NSString *curResolutionStr = [VEVideoPlayerController transferResolutionTitleByType:self.playerInterface.currentResolution];
        [_resolutionButton setTitle:curResolutionStr forState:UIControlStateNormal];
        [_resolutionButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_resolutionButton addTarget:self action:@selector(onResolutionButtonHandle:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _resolutionButton;
}

- (VEPlayerResolutionView *)resolutionView {
    if (!_resolutionView) {
        NSString *curResolutionStr = [VEVideoPlayerController transferResolutionTitleByType:self.playerInterface.currentResolution];
        _resolutionView = [[VEPlayerResolutionView alloc] initWithResolutionSet:self.playerInterface.resolutionSet CurResolution:curResolutionStr];
        _resolutionView.context = self.context;
    }
    return _resolutionView;
}

#pragma mark - Event Response

- (void)onResolutionButtonHandle:(UIButton *)button {
    [self.context post:@(0) forKey:VEPlayerContextKeyViewVisible];
    [self.context post:@(0) forKey:VEPlayerContextKeyGestureEnabled];
    [self.actionViewInterface.playbackControlView addSubview:self.resolutionView];
    [self.resolutionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.actionViewInterface.playbackControlView);
    }];
}

@end
