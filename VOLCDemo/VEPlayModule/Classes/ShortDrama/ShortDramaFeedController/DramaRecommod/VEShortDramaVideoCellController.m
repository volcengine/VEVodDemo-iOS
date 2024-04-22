//
//  VEShortDramaVideoCellController.m
//  VOLCDemo
//

#import "VEShortDramaVideoCellController.h"
#import "ShortDramaPlayControlViewController.h"
#import "VEDramaVideoInfoModel.h"
#import "VESettingManager.h"
#import <Masonry/Masonry.h>
#import "VEPlayerKit.h"

static NSInteger VEShortDramaVideoCellBottomOffset = 83;

@interface VEShortDramaVideoCellController () <VEVideoPlaybackDelegate>

@property (nonatomic, strong) VEVideoPlayerController *playerController;
@property (nonatomic, strong) ShortDramaPlayControlViewController *controlViewController;

@end

@implementation VEShortDramaVideoCellController

@synthesize reuseIdentifier;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
}

#pragma mark ----- Life Circle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self playerCover];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self playerStart];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    // this method may call player pause, it depends on application logic.
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self playerStop];
}

- (void)recordStartTime {
    if (self.playerController) {
        NSInteger curTime = self.playerController.currentPlaybackTime;
        NSInteger duration = self.playerController.duration;
        if (curTime && duration && (duration - curTime > 5)) {
            self.dramaVideoInfo.startTime = curTime;
        } else {
            self.dramaVideoInfo.startTime = 0;
        }
    }
}

#pragma mark ----- Play

- (void)playerCover {
    if (self.playerController.isPlaying) {
        return;
    }
    [self createPlayer];
    [self.playerController loadBackgourdImageWithMediaSource:[VEDramaVideoInfoModel toVideoEngineSource:self.dramaVideoInfo]];
}

- (void)playerStart {
    if (self.playerController.isPlaying){
        return;
    }
    if (!self.playerController) {
        [self createPlayer];
    }
    [self playerOptions];
    [self.playerController playWithMediaSource:[VEDramaVideoInfoModel toVideoEngineSource:self.dramaVideoInfo]];
    if (self.dramaVideoInfo.startTime > 0) {
        self.playerController.startTime = self.dramaVideoInfo.startTime;
        self.dramaVideoInfo.startTime = 0;
    }
    [self.playerController play];
}

- (void)playerStop {
    @autoreleasepool {
        [self recordStartTime];
        [self.playerController stop];
        [self.controlViewController closePlayer];
        [self.controlViewController.view removeFromSuperview];
        [self.controlViewController removeFromParentViewController];
        self.controlViewController = nil;
        [self.playerController.view removeFromSuperview];
        [self.playerController removeFromParentViewController];
        self.playerController = nil;
    }
}

#pragma mark ----- Player

- (void)createPlayer {
    self.playerController = [[VEVideoPlayerController alloc] init];
    self.playerController.delegate = self;
    self.playerController.videoViewMode = VEVideoViewModeAspectFill;
    [self.view addSubview:self.playerController.view];
    [self.view bringSubviewToFront:self.playerController.view];
    [self.playerController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.bottom.equalTo(self.view).with.offset(-VEShortDramaVideoCellBottomOffset);
    }];
    
    self.controlViewController = [[ShortDramaPlayControlViewController alloc] initWithVideoPlayerController:self.playerController];
    [self.playerController addChildViewController:self.controlViewController];
    [self.playerController.view addSubview:self.controlViewController.view];
    [self.controlViewController didMoveToParentViewController:self];
    [self.controlViewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.playerController.view);
    }];
    [self.controlViewController reloadData:self.dramaVideoInfo];
}

- (void)playerOptions {
    VESettingModel *preRender = [[VESettingManager universalManager] settingForKey:VESettingKeyShortVideoPreRenderStrategy];
    self.playerController.preRenderOpen = preRender.open;
    
    VESettingModel *preload = [[VESettingManager universalManager] settingForKey:VESettingKeyShortVideoPreloadStrategy];
    self.playerController.preloadOpen = preload.open;
    
    VESettingModel *h265 = [[VESettingManager universalManager] settingForKey:VESettingKeyUniversalH265];
    self.playerController.h265Open = h265.open;
    
    VESettingModel *hardwareDecode = [[VESettingManager universalManager] settingForKey:VESettingKeyUniversalHardwareDecode];
    self.playerController.hardwareDecodeOpen = hardwareDecode.open;
    
    VESettingModel *sr = [[VESettingManager universalManager] settingForKey:VESettingKeyUniversalSR];
    self.playerController.srOpen = sr.open;
}

#pragma mark - VEVideoPlaybackDelegate

- (void)videoPlayer:(id<VEVideoPlayback> _Nullable)player playbackStateDidChange:(VEVideoPlaybackState)state {
    if (state == VEVideoPlaybackStateFinished) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(dramaVideoPlayFinish:)]) {
            [self recordStartTime];
            [self.delegate dramaVideoPlayFinish:self.dramaVideoInfo];
        }
    }
}

@end
