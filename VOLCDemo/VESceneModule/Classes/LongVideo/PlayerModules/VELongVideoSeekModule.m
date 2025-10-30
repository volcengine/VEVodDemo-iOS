//
//  VELongVideoSeekModule.m
//  VESceneModule
//
//  Created by zys on 2025/10/15.
//

#import "VELongVideoSeekModule.h"
#import "VEPlayerContextKeyDefine.h"
#import "VEPlayerActionViewInterface.h"
#import "VEPlayerGestureServiceInterface.h"
#import "VEPlayerGestureHandlerProtocol.h"
#import "VEPlayerContext.h"
#import <Masonry/Masonry.h>
#import "VELongVideoSliderControlView.h"
#import "VEPlayerSeekState.h"
#import "VEVideoPlayback.h"
#import "UIView+BDShowView.h"

@interface VELongVideoSeekModule () <VESliderControlViewDelegate, VEPlayerGestureHandlerProtocol>

@property (nonatomic, strong) VELongVideoSliderControlView *sliderControlView;

@property (nonatomic, weak) id<VEVideoPlayback> playerInterface;

@property (nonatomic, weak) id<VEPlayerGestureServiceInterface> gestureService;

@property (nonatomic, weak) id<VEPlayerActionViewInterface> actionViewInterface;

@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, assign) BOOL isLocking;

@property (nonatomic, assign) BOOL isForCell;

@end

@implementation VELongVideoSeekModule

VEPlayerContextDILink(playerInterface, VEVideoPlayback, self.context);
VEPlayerContextDILink(gestureService, VEPlayerGestureServiceInterface, self.context);
VEPlayerContextDILink(actionViewInterface, VEPlayerActionViewInterface, self.context);

#pragma mark - Life Cycle

- (instancetype)initForCell:(BOOL)isForCell {
    self = [super init];
    if (self) {
        _isForCell = isForCell;
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
    [self.context addKey:VEPlayerContextKeyPlaybackState withObserver:self handler:^(id  _Nullable object, NSString *key) {
        @strongify(self);
        if (self.playerInterface.playbackState == VEVideoPlaybackStatePlaying) {
            [self _startTimer];
            if (self.sliderControlView.totalDutation != self.playerInterface.duration) {
                self.sliderControlView.totalDutation = self.playerInterface.duration;
            }
        } else {
            [self _invalidateTimer];
        }
    }];
    [self.context addKey:VEPlayerContextKeySliderSeekBegin withObserver:self handler:^(id  _Nullable object, NSString *key) {
        @strongify(self);
        [self _invalidateTimer];
    }];
    [self.context addKey:VEPlayerContextKeySliderCancel withObserver:self handler:^(id  _Nullable object, NSString *key) {
        @strongify(self);
        if (self.playerInterface.playbackState == VEVideoPlaybackStatePlaying) {
            [self _startTimer];
        }else {
            [self _timerHandle];
        }
    }];
    [self.context addKey:VEPlayerContextKeySliderSeekEnd withObserver:self handler:^(VEPlayerSeekState *seekState, NSString *key) {
        @strongify(self);

        if (self.playerInterface.playbackState == VEVideoPlaybackStatePlaying) {
            [self _startTimer];
        }
        
        NSTimeInterval playbackTime = seekState.progress * seekState.duration;
        [self.playerInterface seekToTime:playbackTime complete:nil renderComplete:nil];
    }];
    [self.context addKey:VEPlayerContextKeySpeedTipViewShowed withObserver:self handler:^(id  _Nullable object, NSString *key) {
        @strongify(self);
        BOOL showSpeedTipView = [object boolValue];
        self.sliderControlView.userInteractionEnabled = !showSpeedTipView;
    }];
    
    [self.context addKey:VEPlayerContextKeyViewVisible withObserver:self handler:^(NSNumber *shown, NSString * _Nullable key) {
        @strongify(self);
        if (!self.isLocking) {
            BOOL value = [shown boolValue];
            [self.sliderControlView showView:value];
        }
    }];
    
    [self.context addKey:VEPlayerContextKeyRotateScreen withObserver:self handler:^(NSNumber *ori, NSString * _Nullable key) {
        @strongify(self);
        if (self.sliderControlView.superview == NULL) {
            [self configuratoinCustomView];
        }
        UIDeviceOrientation curOri = (UIDeviceOrientation)[ori intValue];
        if (curOri == UIDeviceOrientationLandscapeRight) {
            [self.sliderControlView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.actionViewInterface.playbackControlView).offset(35);
                make.right.equalTo(self.actionViewInterface.playbackControlView).offset(-50);
                make.bottom.equalTo(self.actionViewInterface.playbackControlView).offset(-67);
                make.height.mas_equalTo(40);
            }];
            [self.sliderControlView updateCustomViewsWithOri:UIDeviceOrientationLandscapeRight];
        }else if (curOri == UIDeviceOrientationPortrait) {
            [self.sliderControlView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.actionViewInterface.playbackControlView);
                make.right.equalTo(self.actionViewInterface.playbackControlView).offset(-40);
                make.bottom.equalTo(self.actionViewInterface.playbackControlView).offset(-17);
                make.height.mas_equalTo(20);
            }];
            [self.sliderControlView updateCustomViewsWithOri:UIDeviceOrientationPortrait];
        }
    }];
    
    [self.context addKey:VEPlayerContextKeyLockControl withObserver:self handler:^(NSNumber *lock, NSString * _Nullable key) {
        BOOL value = [lock boolValue];
        self.isLocking = value;
        [self.sliderControlView showView:!value];
    }];
}

- (void)controlViewTemplateDidUpdate {
    [super controlViewTemplateDidUpdate];
}

- (void)configuratoinCustomView {
    [self.actionViewInterface.playbackControlView addSubview:self.sliderControlView];
    
    [self.sliderControlView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (self.isForCell) {
            make.left.equalTo(self.actionViewInterface.playbackControlView).offset(20);
            make.right.equalTo(self.actionViewInterface.playbackControlView).offset(-20);
        }else {
            make.left.equalTo(self.actionViewInterface.playbackControlView);
            make.right.equalTo(self.actionViewInterface.playbackControlView).offset(-40);
        }
        make.bottom.equalTo(self.actionViewInterface.playbackControlView).offset(-17);
        make.height.mas_equalTo(20);
    }];
}

- (void)moduleDidUnLoad {
    [super moduleDidUnLoad];
    if (self.sliderControlView) {
        [self.sliderControlView removeFromSuperview];
        self.sliderControlView = nil;
    }
    [self _invalidateTimer];
}

#pragma mark - Timer

- (void)_startTimer {
    [self _invalidateTimer];
    if (_timer == nil) {
        _timer = [NSTimer timerWithTimeInterval:.1f target:self selector:@selector(_timerHandle) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSDefaultRunLoopMode];
    }
}

- (void)_invalidateTimer {
    [_timer invalidate];
    _timer = nil;
}

- (void)_timerHandle {
    if (self.playerInterface.duration) {
        self.sliderControlView.progressValue = self.playerInterface.currentPlaybackTime / self.playerInterface.duration;
    }
}

#pragma mark - VESliderControlView Delegate

- (void)progressBeginSlideChange:(VESliderControlView *)sliderControlView {
    VEPlayerSeekState *seekState = [[VEPlayerSeekState alloc] init];
    seekState.seekStage = VEPlayerSeekStageSliderBegin;
    seekState.progress = sliderControlView.progressValue;
    seekState.duration = self.playerInterface.duration;
    [self.context post:seekState forKey:VEPlayerContextKeySliderSeekBegin];
}

- (void)progressSliding:(VESliderControlView *)sliderControlView value:(CGFloat)value {
    VEPlayerSeekState *seekState = [[VEPlayerSeekState alloc] init];
    seekState.seekStage = VEPlayerSeekStageSliderChanging;
    seekState.progress = sliderControlView.progressValue;
    seekState.duration = self.playerInterface.duration;
    [self.context post:seekState forKey:VEPlayerContextKeySliderChanging];
}

- (void)progressDidEndSlide:(VESliderControlView *)sliderControlView value:(CGFloat)value {
    VEPlayerSeekState *seekState = [[VEPlayerSeekState alloc] init];
    seekState.seekStage = VEPlayerSeekStageSliderEnd;
    seekState.progress = sliderControlView.progressValue;
    seekState.duration = self.playerInterface.duration;
    [self.context post:seekState forKey:VEPlayerContextKeySliderSeekEnd];
}

- (void)progressSlideCancel:(VESliderControlView *)sliderControlView {
    VEPlayerSeekState *seekState = [[VEPlayerSeekState alloc] init];
    seekState.seekStage = VEPlayerSeekStageSliderCancel;
    seekState.progress = sliderControlView.progressValue;
    seekState.duration = self.playerInterface.duration;
    [self.context post:seekState forKey:VEPlayerContextKeySliderCancel];
}

#pragma mark - Setter & Getter

- (VELongVideoSliderControlView *)sliderControlView {
    if (_sliderControlView == nil) {
        _sliderControlView = [[VELongVideoSliderControlView alloc] initWithContentMode:VESliderControlViewContentModeBottom];
        _sliderControlView.progressBackgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.2];
        _sliderControlView.progressColor = [UIColor whiteColor];
        _sliderControlView.progressBufferColor = [UIColor clearColor];
        _sliderControlView.thumbHeight = 4;
        _sliderControlView.thumbOffset = 12;
        _sliderControlView.delegate = self;
        _sliderControlView.extendTouchSize = CGSizeMake(0, 20);
    }
    return _sliderControlView;
}

@end
