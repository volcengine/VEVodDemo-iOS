//
//  VEPlayerViewService.m
//  VEPlayerKit
//

#import "VEPlayerViewService.h"
#import "BTDMacros.h"
#import "VEPlayerModuleManager.h"

@interface VEPlayerViewService()

@property (nonatomic, strong) VEPlayerActionView *actionView;
@property (nonatomic, strong) VEPlayerControlView *underlayControlView;
@property (nonatomic, strong) VEPlayerControlView *playbackControlView;
@property (nonatomic, strong) VEPlayerControlView *playbackLockControlView;
@property (nonatomic, strong) VEPlayerControlView *overlayControlView;

@end

@implementation VEPlayerViewService

@synthesize playerContainerView;

#pragma mark - Getter && Setter

- (VEPlayerActionView *)actionView {
    if (!_actionView) {
        _actionView = [[VEPlayerActionView alloc] initWithFrame:CGRectZero];
    }
    return _actionView;
}

- (VEPlayerControlView *)underlayControlView {
    if (!_underlayControlView) {
        _underlayControlView = [[VEPlayerControlView alloc] initWithFrame:self.actionView.bounds];
        _underlayControlView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.actionView addPlayerControlView:_underlayControlView viewType:VEPlayerControlViewType_Underlay];
    }
    return _underlayControlView;
}

- (VEPlayerControlView *)playbackControlView {
    if (!_playbackControlView) {
        _playbackControlView = [[VEPlayerControlView alloc] initWithFrame:self.actionView.bounds];
        _playbackControlView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.actionView addPlayerControlView:_playbackControlView viewType:VEPlayerControlViewType_Playback];
    }
    return _playbackControlView;
}

- (VEPlayerControlView *)playbackLockControlView {
    if (_playbackLockControlView) {
        _playbackLockControlView = [[VEPlayerControlView alloc] initWithFrame:self.actionView.bounds];
        _playbackLockControlView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.actionView addPlayerControlView:_playbackLockControlView viewType:VEPlayerControlViewType_PlaybackLock];
    }
    return _playbackLockControlView;
}

- (VEPlayerControlView *)overlayControlView {
    if (!_overlayControlView) {
        _overlayControlView = [[VEPlayerControlView alloc] initWithFrame:self.actionView.bounds];
        _overlayControlView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.actionView addPlayerControlView:_overlayControlView viewType:VEPlayerControlViewType_Overlay];
    }
    return _overlayControlView;
}

@end
