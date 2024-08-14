//
//  VEPlayerSeekProgressModule.m
//  VEPlayModule
//
//  Created by zyw on 2024/7/8.
//

#import "VEPlayerSeekProgressModule.h"
#import "VEPlayerContextKeyDefine.h"
#import "VEPlayerActionViewInterface.h"
#import "VEPlayerGestureServiceInterface.h"
#import "VEPlayerSeekProgressView.h"
#import <Masonry/Masonry.h>
#import "VEPlayerSeekState.h"
#import "VEVideoPlayback.h"

@interface VEPlayerSeekProgressModule ()

@property (nonatomic, strong) VEPlayerSeekProgressView *seekProgressTipView;

@property (nonatomic, weak) id<VEVideoPlayback> playerInterface;

@property (nonatomic, weak) id<VEPlayerActionViewInterface> actionViewInterface;

@end

@implementation VEPlayerSeekProgressModule

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
    [self.context addKey:VEPlayerContextKeySliderSeekBegin withObserver:self handler:^(VEPlayerSeekState *seekState, NSString *key) {
        @strongify(self);
        [self.seekProgressTipView showView:YES];
        [self __updateSeekProgress:seekState];
    }];
    [self.context addKey:VEPlayerContextKeySliderChanging withObserver:self handler:^(VEPlayerSeekState *seekState, NSString *key) {
        @strongify(self);
        [self.seekProgressTipView showView:YES];
        [self __updateSeekProgress:seekState];
    }];
    [self.context addKey:VEPlayerContextKeySliderCancel withObserver:self handler:^(VEPlayerSeekState *seekState, NSString *key) {
        @strongify(self);
        [self.seekProgressTipView showView:NO];
        [self __updateSeekProgress:seekState];
    }];
    [self.context addKey:VEPlayerContextKeySliderSeekEnd withObserver:self handler:^(VEPlayerSeekState *seekState, NSString *key) {
        @strongify(self);
        [self.seekProgressTipView showView:NO];
        [self __updateSeekProgress:seekState];
    }];
}

- (void)controlViewTemplateDidUpdate {
    [super controlViewTemplateDidUpdate];
}

- (void)configuratoinCustomView {
    [self.actionViewInterface.overlayControlView addSubview:self.seekProgressTipView];
    
    [self.seekProgressTipView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.actionViewInterface.overlayControlView);
        make.bottom.equalTo(self.actionViewInterface.overlayControlView).with.offset(-130);
        make.left.right.equalTo(self.actionViewInterface.overlayControlView);
        make.height.mas_equalTo(30);
    }];
}

- (void)moduleDidUnLoad {
    [super moduleDidUnLoad];
    if (self.seekProgressTipView) {
        [self.seekProgressTipView removeFromSuperview];
        self.seekProgressTipView = nil;
    }
}

#pragma mark - Private

- (void)__updateSeekProgress:(VEPlayerSeekState *)state {
    NSInteger playbackTime = state.progress * state.duration;
    [self.seekProgressTipView updateProgress:playbackTime duration:state.duration];
}

#pragma mark - Getter && Setter

- (VEPlayerSeekProgressView *)seekProgressTipView {
    if (_seekProgressTipView == nil) {
        _seekProgressTipView = [[VEPlayerSeekProgressView alloc] init];
    }
    return _seekProgressTipView;
}

@end
