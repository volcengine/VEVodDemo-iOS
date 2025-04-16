//
//  VEShortDramaDetailVideoCellController.m
//  VEPlayModule
//

#import "VEShortDramaDetailVideoCellController.h"
#import "VEShortDramaDetailFeedViewController.h"
#import "VEShortDramaPagingViewController.h"
#import "VEDramaVideoInfoModel.h"
#import "VESettingManager.h"
#import <Masonry/Masonry.h>
#import "VEPlayerKit.h"
#import "ShortDramaDetailPlayerModuleLoader.h"
#import "VEPlayerContextKeyDefine.h"
#import "ShortDramaCollectViewController.h"
#import "ShortDramaPraiseViewController.h"
#import "VEPlayerUtility.h"
#import "BTDMacros.h"
#import "VEVideoPlayerConfigurationFactory.h"
#import "VEDataManager.h"
#import "VEVideoPlayerPipController.h"
#import "ShortDramaRecordStartTimeModule.h"

static NSInteger VEShortDramaDetailVideoCellBottomOffset = 83;

@interface VEShortDramaDetailVideoCellController () <VEVideoPlaybackDelegate, ShortDramaDetailPlayerModuleLoaderDelegate, VEVideoPlayerControllerSubtitleDelegate>

@property (nonatomic, strong, readwrite) VEDramaVideoInfoModel *dramaVideoInfo;
@property (nonatomic, strong) ShortDramaDetailPlayerModuleLoader *moduleLoader;
@property (nonatomic, strong) ShortDramaCollectViewController *collectViewController;
@property (nonatomic, strong) ShortDramaPraiseViewController *praiseViewController;

@end

@implementation VEShortDramaDetailVideoCellController

@synthesize reuseIdentifier;

#pragma mark ----- Life Circle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self configuratoinCustomView];
    [self loadPlayerCover];
    if (self.continuePlay) {
        [self playerStart];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (!self.continuePlay) {
        [self playerStart];
    }
    self.continuePlay = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self playerStop];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark - UI

- (void)configuratoinCustomView {
    self.view.backgroundColor = [UIColor blackColor];

    [self addChildViewController:self.collectViewController];
    [self.view addSubview:self.collectViewController.view];
    [self addChildViewController:self.praiseViewController];
    [self.view addSubview:self.praiseViewController.view];
    
    [self.collectViewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).with.offset(-20-VEShortDramaDetailVideoCellBottomOffset);
        make.right.equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(ShortDramaCollectViewControllerWdithHeight, ShortDramaCollectViewControllerWdithHeight));
    }];
    
    [self.praiseViewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.collectViewController.view.mas_top).with.offset(-12);
        make.right.equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(ShortDramaPraiseViewControllerWdithHeight, ShortDramaPraiseViewControllerWdithHeight));
    }];
}

#pragma mark - Public

- (void)reloadData:(VEDramaVideoInfoModel *)dramaVideoInfo {
    self.dramaVideoInfo = dramaVideoInfo;
    
    // 提前加载封面图
    [self loadPlayerCover];
}

- (void)recordPlaybackTime {
    [self.moduleLoader.context post:nil forKey:VEPlayerContextKeyDramaSceneWillSwitch];
}

#pragma mark - ShortDramaDetailPlayerModuleLoaderDelegate

- (void)onClickDramaSelectionCallback {
    if (self.delegate && [self.delegate respondsToSelector:@selector(onClickDramaSelectionCallback:)]) {
        [self.delegate onClickDramaSelectionCallback:self.dramaVideoInfo];
    }
}

#pragma mark ----- Play

- (void)playerStart {
    if (self.playerController.isPlaying){
        return;
    }
    if (!self.playerController) {
        [self createPlayer];
    }
    [self.playerController preparePip];
    if ([VEDataManager getSubtitleSourceType] == VESubtitleSourceType_Vid_AuthToken) {
        [self.playerController setSubtitleAuthToken:self.dramaVideoInfo.subtitleAuthToken];
    } else if ([VEDataManager getSubtitleSourceType] == VESubtitleSourceType_Url) {
        TTVideoEngineSubDecInfoModel *subtitleInfoModel = [[TTVideoEngineSubDecInfoModel alloc] initWithDictionary:self.dramaVideoInfo.subtitleInfoDict];
        [self.playerController setSubtitleInfoModel:subtitleInfoModel];
        [self.playerController setSubtitleId:[VEDataManager getMatchedSubtitleId:subtitleInfoModel]];
    }
    if (self.dramaVideoInfo.payInfo.payStatus == VEDramaPayStatus_Paid) {
        [self.playerController playWithMediaSource:[VEDramaVideoInfoModel toVideoEngineSource:self.dramaVideoInfo]];
    } else {
        [self.moduleLoader.context post:self.dramaVideoInfo forKey:VEPlayerContextKeyShortDramaShowPayModule];
    }
    self.playerController.videoViewMode = VEVideoViewModeAspectFill;
    if (self.delegate && [self.delegate respondsToSelector:@selector(onDramaDetailVideoPlayStart:)]) {
        [self.delegate onDramaDetailVideoPlayStart:self.dramaVideoInfo];
    }
}

- (void)setContinuePlay:(BOOL)continuePlay {
    _continuePlay = continuePlay;
}

- (void)playerStop {
    if (self.playerController) {
        // 处理无缝切换
        if ([[VEPlayerUtility lm_topmostViewController] isKindOfClass:[VEShortDramaDetailFeedViewController class]]) {
            [self.playerController stop];
        } else {
            UIViewController *topViewController = [VEPlayerUtility lm_topmostViewController];
            if ([topViewController isKindOfClass:[VEShortDramaPagingViewController class]]) {
                if ([(VEShortDramaPagingViewController *)topViewController currentPage] == VEShortDramaTypeDrama) {
                    [self.playerController stop];
                }
            }
        }
        [self.collectViewController removeFromParentViewController];
        [self.collectViewController.view removeFromSuperview];
        self.collectViewController = nil;
        [self.praiseViewController removeFromParentViewController];
        [self.praiseViewController.view removeFromSuperview];
        self.praiseViewController = nil;
        [self.playerController.view removeFromSuperview];
        [self.playerController removeFromParentViewController];
        self.playerController = nil;
    }
}

#pragma mark ----- VEVideoPlayerControllerSubtitleDelegate
- (void)videoPlayerController:(VEVideoPlayerController *)videoPlayerController onSubtitleTextUpdated:(NSString *)subtitle {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"on subtitle: %@", subtitle);
        [self.moduleLoader setSubtitle:subtitle];
    });
}

- (NSInteger)getMatchedSubtitleId:(TTVideoEngineSubDecInfoModel *)subtitleInfoModel {
    return [VEDataManager getMatchedSubtitleId:subtitleInfoModel];
}

#pragma mark ----- Player

- (void)createPlayer {
    if (self.playerController == nil) {
        self.moduleLoader = [[ShortDramaDetailPlayerModuleLoader alloc] init];
        self.moduleLoader.delegate = self;
        VEVideoPlayerConfiguration *playerConfig = [VEVideoPlayerConfigurationFactory getConfiguration];
        [VEPreRenderVideoEngineMediatorDelegate shareInstance].playerConfig = playerConfig;
        self.playerController = [[VEVideoPlayerController alloc] initWithConfiguration:playerConfig moduleLoader:self.moduleLoader playerContainerView:self.view];
        self.playerController.delegate = self;
        self.playerController.subtitleDelegate = self;
        [self.view addSubview:self.playerController.view];
        [self.view bringSubviewToFront:self.collectViewController.view];
        [self.view bringSubviewToFront:self.praiseViewController.view];
        
        [self.playerController.view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.equalTo(self.view);
            make.bottom.equalTo(self.view).with.offset(-VEShortDramaDetailVideoCellBottomOffset);
        }];
        [self playerOptions];
        
        @weakify(self);
        [self.moduleLoader.context addKey:VEPlayerContextKeySpeedTipViewShowed withObserver:self handler:^(id  _Nullable object, NSString *key) {
            @strongify(self);
            BOOL showSpeedTipView = [object boolValue];
            [UIView animateWithDuration:0.3 animations:^{
                self.collectViewController.view.alpha = showSpeedTipView ? 0 : 1;
                self.praiseViewController.view.alpha = showSpeedTipView ? 0 : 1;
            }];
        }];
    }
    
    [self.moduleLoader.context post:self.dramaVideoInfo forKey:VEPlayerContextKeyShortDramaDataModelChanged];
}

- (void)loadPlayerCover {
    if (self.playerController.isPlaying) {
        return;
    }
    [self createPlayer];
    self.playerController.videoViewMode = VEVideoViewModeAspectFill;
    [self.playerController loadBackgourdImageWithMediaSource:[VEDramaVideoInfoModel toVideoEngineSource:self.dramaVideoInfo]];
}

- (void)playerOptions {
    VESettingModel *preRender = [[VESettingManager universalManager] settingForKey:VESettingKeyShortVideoPreRenderStrategy];
    self.playerController.preRenderOpen = preRender.open;
    
    VESettingModel *preload = [[VESettingManager universalManager] settingForKey:VESettingKeyShortVideoPreloadStrategy];
    self.playerController.preloadOpen = preload.open;
}

#pragma mark - VEVideoPlaybackDelegate

- (void)videoPlayer:(id<VEVideoPlayback> _Nullable)player playbackStateDidChange:(VEVideoPlaybackState)state {
    BTDLog(@"playbackStateDidChange %@ %@", @(state), @(self.dramaVideoInfo.dramaEpisodeInfo.episodeNumber));
}

- (void)videoPlayer:(id<VEVideoPlayback> _Nullable)player didFinishedWithStatus:(VEPlayFinishStatus *_Nullable)finishStatus {
    if (finishStatus.error) {
        BTDLog(@"play error::%@", finishStatus.error);
    } else {
        if (finishStatus.finishState == VEVideoPlayFinishStatusType_SystemFinish) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(onDramaDetailVideoPlayFinish:)]) {
                [self.delegate onDramaDetailVideoPlayFinish:self.dramaVideoInfo];
            }
        }
    }
}

#pragma mark - lazy load

- (ShortDramaCollectViewController *)collectViewController {
    if (_collectViewController == nil) {
        _collectViewController = [[ShortDramaCollectViewController alloc] init];
    }
    return _collectViewController;
}

- (ShortDramaPraiseViewController *)praiseViewController {
    if (_praiseViewController == nil) {
        _praiseViewController = [[ShortDramaPraiseViewController alloc] init];
    }
    return _praiseViewController;
}

@end
