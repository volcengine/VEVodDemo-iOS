//
//  VELongVideoPlayButtonModule.m
//  VESceneModule
//
//  Created by zys on 2025/10/15.
//

#import "VELongVideoPlayButtonModule.h"
#import "VEPlayerContextKeyDefine.h"
#import "VEPlayerActionViewInterface.h"
#import <Masonry/Masonry.h>
#import "UIView+BDShowView.h"
#import "VEVideoPlayback.h"

@interface VELongVideoPlayButtonModule ()

@property (nonatomic, strong) UIButton *playButton;

@property (nonatomic, weak) id<VEVideoPlayback> playerInterface;

@property (nonatomic, weak) id<VEPlayerActionViewInterface> actionViewInterface;

@property (nonatomic, assign) BOOL isLocking;

@property (nonatomic, assign) BOOL isLoading;

@end

@implementation VELongVideoPlayButtonModule

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
            if (value && self.isLoading) {
                // 需要显示，但是正在 loading，所以不显示
                [self.playButton showView:NO];
                return;
            }
            [self.playButton showView:value];
        }
    }];
    
    [self.context addKey:VEPlayerContextKeyPlaybackState withObserver:self handler:^(id  _Nullable object, NSString *key) {
        @strongify(self);
        VEVideoPlaybackState playbackState = (VEVideoPlaybackState)[(NSNumber *)object integerValue];
        if (playbackState == VEVideoPlaybackStatePlaying) {
            [self.playButton setImage:[UIImage imageNamed:@"video_pause"] forState:UIControlStateNormal];
        }else {
            [self.playButton setImage:[UIImage imageNamed:@"video_play"] forState:UIControlStateNormal];
        }
    }];
    
    [self.context addKey:VEPlayerContextKeyLockControl withObserver:self handler:^(NSNumber *lock, NSString * _Nullable key) {
        @strongify(self);
        BOOL value = [lock boolValue];
        self.isLocking = value;
        [self.playButton showView:!value];
    }];
    
    [self.context addKey:VEPlayerContextKeyStartLoading withObserver:self handler:^(NSNumber *loadState, NSString * _Nullable key) {
        @strongify(self);
        self.isLoading = YES;
        [self.playButton showView:NO];
    }];
    
    [self.context addKey:VEPlayerContextKeyFinishLoading withObserver:self handler:^(id  _Nullable object, NSString * _Nullable key) {
        @strongify(self);
        self.isLoading = NO;
        [self.playButton showView:YES];
    }];
}

- (void)controlViewTemplateDidUpdate {
    [super controlViewTemplateDidUpdate];
}

- (void)configuratoinCustomView {
    [self.actionViewInterface.playbackControlView addSubview:self.playButton];
    
    [self.playButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(50, 50));
        make.centerX.centerY.equalTo(self.actionViewInterface.playbackControlView);
    }];
}

- (void)moduleDidUnLoad {
    [super moduleDidUnLoad];
    if (self.playButton) {
        [self.playButton removeFromSuperview];
        self.playButton = nil;
    }
}

#pragma mark - Lazy Load

- (UIButton *)playButton {
    if (!_playButton) {
        _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playButton setImage:[UIImage imageNamed:@"video_pause"] forState:UIControlStateNormal];
        [_playButton addTarget:self action:@selector(onClickPlayButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playButton;
}

#pragma mark - event

- (void)onClickPlayButton:(UIButton *)sender {
    if ([self.playerInterface isPlaying]) {
        [self.playerInterface pause];
    } else {
        [self.playerInterface play];
    }
}

@end


