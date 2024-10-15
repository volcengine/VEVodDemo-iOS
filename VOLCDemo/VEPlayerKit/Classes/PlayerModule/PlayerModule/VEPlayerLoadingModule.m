//
//  VEPlayerLoadingModule.m
//  VEPlayerKit
//

#import "VEPlayerLoadingModule.h"
#import "VEPlayerActionViewInterface.h"
#import "VEPlayerContext.h"
#import "VEPlayerContextKeyDefine.h"
#import "VELPlayerLoadingView.h"
#import "VEPlayerUtility.h"
#import "VEPlayFinishStatus.h"
#import <Reachability/Reachability.h>
#import "VEPlayerGestureServiceInterface.h"
#import "VEVideoPlayback.h"

@interface VEPlayerLoadingModule () <VEPlayerLoadingViewDataSource>

@property (nonatomic, strong, readwrite) UIView<VEPlayerLoadingViewProtocol> *loadingView;

@property (nonatomic, weak) id<VEVideoPlayback> playerInterface;

@property (nonatomic, weak) id<VEPlayerActionViewInterface> actionViewService;

@property (nonatomic, weak) id<VEPlayerGestureServiceInterface> gestureService;

@property (nonatomic, assign) BOOL userPlayAction;

@property (nonatomic, assign) BOOL userSeeking;

@property (nonatomic, assign) BOOL isLoading; // 播放器是否处于loading状态

@property (nonatomic, strong) Class<VEPlayerLoadingViewProtocol> noNetworTipClass;

@property(nonatomic, strong) id<VEPlayerGestureHandlerProtocol> disableAllGestureHandler;

@end

@implementation VEPlayerLoadingModule

VEPlayerContextDILink(actionViewService, VEPlayerActionViewInterface, self.context)
VEPlayerContextDILink(playerInterface, VEVideoPlayback, self.context)
VEPlayerContextDILink(gestureService, VEPlayerGestureServiceInterface, self.context);

#pragma mark - Life Cycle
- (void)moduleDidLoad {
    [super moduleDidLoad];
    
    @weakify(self);
    [self.context addKeys:@[VEPlayerContextKeyPlayAction, VEPlayerContextKeyPauseAction] withObserver:self handler:^(id  _Nullable object, NSString *key) {
        @strongify(self);
        self.userPlayAction = [key isEqualToString:VEPlayerContextKeyPlayAction] && object;
        [self updateLoadingState];
    }];
    
    [self.context addKey:VEPlayerContextKeyPlaybackDidFinish withObserver:self handler:^(VEPlayFinishStatus *finishStatus, NSString *key) {
        @strongify(self);
        if (finishStatus) {
            if (![finishStatus error] || !self.playerInterface.looping) {
                self.userPlayAction = NO;
            }
            [self updateLoadingState];
        }
    }];
    
    [self.context addKeys:@[VEPlayerContextKeySliderSeekBegin, VEPlayerContextKeySliderSeekEnd] withObserver:self handler:^(id  _Nullable object, NSString *key) {
        @strongify(self);
        self.userSeeking = [key isEqualToString:VEPlayerContextKeySliderSeekBegin];
        [self updateLoadingState];
    }];
    
    [self.context addKeys:@[VEPlayerContextKeyLoadState, VEPlayerContextKeyPlaybackState] withObserver:self handler:^(id  _Nullable object, NSString *key) {
        @strongify(self);
        [self updateLoadingState];
    }];
    
    [self.context addKeys:@[VEPlayerContextKeyShowLoadingNetWorkSpeed, VEPlayerContextKeyRotateScreen] withObserver:self handler:^(id  _Nullable object, NSString *key) {
        @strongify(self);
        [self updateLoadingView];
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self updateLoadingState];
}

- (void)moduleDidUnLoad {
    [super moduleDidUnLoad];
    if (self.loadingView) {
        [self.loadingView removeFromSuperview];
        self.loadingView = nil;
    }
}

#pragma mark - Private Mehtod
- (void)updateLoadingView {
    BOOL isFullScreen = [[self.context objectForHandlerKey:VEPlayerContextKeyRotateScreen] isFullScreen];
    self.loadingView.isFullScreen = isFullScreen;
    self.loadingView.showNetSpeedTip = [self.context boolForHandlerKey:VEPlayerContextKeyShowLoadingNetWorkSpeed];
    self.loadingView.dataSource = self;
}

- (void)updateLoadingState {
    if (self.userSeeking) {
        [self showLoading:NO];
    } else {
        //如果播放器复用 && 使用closeAycn context中的loadstate没有被重置，直接从播放器取更准确
        VEVideoLoadState loadState = self.playerInterface.loadState;
        VEVideoPlaybackState playbackState = (VEVideoPlaybackState)[self.context integerForHandlerKey:VEPlayerContextKeyPlaybackState];
        BOOL isPlaying = (playbackState == TTVideoEnginePlaybackStatePlaying);
        BOOL isStartPlaying = (playbackState == TTVideoEnginePlaybackStateStopped && self.userPlayAction); // 正在启动播放
        BOOL showLoading = (isPlaying || isStartPlaying) && (loadState != VEVideoLoadStatePlayable);
        [self showLoading:showLoading];
    }
}

#pragma mark - TTVPlayerLoadingInterface
- (void)showLoading:(BOOL)show {
    if (self.isLoading == show) {
        return;
    }
    self.isLoading = show;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(performShowLoadingView) object:nil];
    if (show) {
        // 对齐原逻辑：延迟1s显示loading视图，避免启播时闪一下loading视图
        [self performSelector:@selector(performShowLoadingView) withObject:nil afterDelay:1];
        
    } else {
        // 将播放器停止loading状态分发出去
        [self.context post:nil forKey:VEPlayerContextKeyFinishLoading];
        
        if (!self.isViewLoaded) {
            return;
        }
        [self.loadingView stopLoading];
    }
}

- (void)performShowLoadingView {
    // 将播放器开始loading状态分发出去
    [self.context post:nil forKey:VEPlayerContextKeyStartLoading];
    
    if (!self.isViewLoaded) {
        return;
    }
    if (!self.loadingView) {
        self.loadingView = [self createLoadingView];
    }
    if (!self.loadingView) {
        return;
    }
    [self.actionViewService.overlayControlView addSubview:self.loadingView];
    [self.loadingView startLoading];
}

#pragma mark - getter & setter

- (UIView<VEPlayerLoadingViewProtocol> *)createLoadingView {
    VELPlayerLoadingView *loadingView = [[VELPlayerLoadingView alloc] init];
    loadingView.isFullScreen = [[self.context objectForHandlerKey:VEPlayerContextKeyRotateScreen] isFullScreen];
    loadingView.showNetSpeedTip = [self.context boolForHandlerKey:VEPlayerContextKeyShowLoadingNetWorkSpeed];
    loadingView.dataSource = self;
    return loadingView;
}

#pragma mark - VEPlayerLoadingViewDataSource

- (NSString *)netWorkSpeedInfo {
    return [VEPlayerUtility netWorkSpeedStringWithKBPerSeconds:self.playerInterface.netWorkSpeed];
}

- (void)addNetworkReachabilityChangedNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(networkReachabilityChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
}
 
- (void)removeNetworkReachabilityChangedNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
}

- (void)networkReachabilityChanged:(NSNotification *)notification {
    if ([[Reachability reachabilityForInternetConnection] isReachable]) {
        if (self.playerInterface.playbackState == VEVideoPlaybackStatePaused) {
            [self.playerInterface play];
        }
    }
}

@end
