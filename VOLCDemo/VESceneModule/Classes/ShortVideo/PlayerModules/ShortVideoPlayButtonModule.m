//
//  ShortVideoPlayButtonModule.m
//

#import "ShortVideoPlayButtonModule.h"
#import "VEPlayerActionViewInterface.h"
#import "VEPlayerGestureServiceInterface.h"
#import "VEPlayerGestureHandlerProtocol.h"
#import "VEPlayerContext.h"
#import "VEPlayerContextKeyDefine.h"
#import <Masonry/Masonry.h>
#import "VEVideoPlayback.h"

#define DisableAutoHiddenKey_NotPlaying @"DisableAutoHiddenKey_NotPlaying"

@interface ShortVideoPlayButtonModule() <VEPlayerGestureHandlerProtocol>

@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, weak) id<VEVideoPlayback> playerInterface;
@property (nonatomic, weak) id<VEPlayerGestureServiceInterface> gestureService;
@property (nonatomic, weak) id<VEPlayerActionViewInterface> actionViewInterface;

@end

@implementation ShortVideoPlayButtonModule

VEPlayerContextDILink(playerInterface, VEVideoPlayback, self.context);
VEPlayerContextDILink(gestureService, VEPlayerGestureServiceInterface, self.context);
VEPlayerContextDILink(actionViewInterface, VEPlayerActionViewInterface, self.context);

#pragma mark - Life Cycle

- (void)moduleDidLoad {
    [super moduleDidLoad];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configuratoinCustomView];
    
    [self.gestureService addGestureHandler:self forType:VEGestureType_SingleTap];
    
    @weakify(self);
    [self.context addKey:VEPlayerContextKeyPlayAction withObserver:self handler:^(id  _Nullable object, NSString *key) {
        @strongify(self);
        if (object) {
            [self updatePlayButtonWithPlayState:YES];
        }
    }];
    
    [self.context addKey:VEPlayerContextKeyPauseAction withObserver:self handler:^(id  _Nullable object, NSString *key) {
        @strongify(self);
        [self updatePlayButtonWithPlayState:NO];
    }];
    
    [self.context addKey:VEPlayerContextKeyPlaybackState withObserver:self handler:^(id  _Nullable object, NSString *key) {
        @strongify(self);
        VEVideoPlaybackState playbackState = (VEVideoPlaybackState)[(NSNumber *)object integerValue];
        [self updatePlayButtonWithPlayState:(playbackState == VEVideoPlaybackStatePlaying)];
    }];
}

- (void)controlViewTemplateDidUpdate {
    [super controlViewTemplateDidUpdate];
}

- (void)configuratoinCustomView {
    [self.actionViewInterface.playbackControlView addSubview:self.playButton];
    [self.playButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.actionViewInterface.playbackControlView);
    }];
}

- (void)moduleDidUnLoad {
    [super moduleDidUnLoad];
    [self.gestureService removeGestureHandler:self];
    [self.context removeHandlersForObserver:self];
    if (self.playButton) {
        [self.playButton removeFromSuperview];
        self.playButton = nil;
    }
}

#pragma mark - Public Mehtod

- (void)updatePlayButtonWithPlayState:(BOOL)isPlaying {
    self.playButton.hidden = isPlaying;
    [[UIApplication sharedApplication] setIdleTimerDisabled:isPlaying];
}

#pragma mark - VEPlayerGestureHandlerProtocol

- (void)handleGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer gestureType:(VEGestureType)gestureType {
    VEVideoPlaybackState playbackState = (VEVideoPlaybackState)[self.context integerForHandlerKey:VEPlayerContextKeyPlaybackState];
    if (playbackState == VEVideoPlaybackStatePlaying) {
        [self.playerInterface pause];
    } else if (playbackState == VEVideoPlaybackStatePaused) {
        [self.playerInterface play];
    }
    [self.context post:@(self.playerInterface.playbackState) forKey:VEPlayerContextKeyPlayButtonSingleTap];
}

#pragma mark - Event Action

- (void)onClickPlayButton:(UIButton *)sender {
    [self.playerInterface play];
    [self.context post:@(self.playerInterface.playbackState) forKey:VEPlayerContextKeyPlayButtonSingleTap];
}

#pragma mark - Setter & Getter

- (UIButton *)playButton {
    if (_playButton == nil) {
        _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playButton setImage:[UIImage imageNamed:@"video_drama_play"] forState:UIControlStateNormal];
        [_playButton addTarget:self action:@selector(onClickPlayButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playButton;
}

@end
