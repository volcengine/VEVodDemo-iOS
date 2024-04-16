//
//  VEShortDramaDetailVideoCellController.m
//  VEPlayModule
//

#import "VEShortDramaDetailVideoCellController.h"
#import "ShortDramaDetailPlayControlViewController.h"
#import "ShortDramaSelectionView.h"
#import "VEDramaVideoInfoModel.h"
#import "VESettingManager.h"
#import <Masonry/Masonry.h>
#import <VEPlayerKit/VEPlayerKit.h>

static NSInteger VEShortDramaDetailVideoCellBottomOffset = 83;

@interface VEShortDramaDetailVideoCellController () <ShortDramaSelectionViewDelegate>

@property (nonatomic, strong) VEVideoPlayerController *playerController;
@property (nonatomic, strong) ShortDramaDetailPlayControlViewController *controlViewController;
@property (nonatomic, strong) ShortDramaSelectionView *drameSelectionView;

@end

@implementation VEShortDramaDetailVideoCellController

@synthesize reuseIdentifier;

#pragma mark ----- Life Circle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self reloadData];
    [self playerCover];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self playerStart];
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
    
    [self configuratoinCustomView];
}

#pragma mark - UI

- (void)configuratoinCustomView {
    self.view.backgroundColor = [UIColor blackColor];
    
    [self.view addSubview:self.drameSelectionView];
    [self.drameSelectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).with.offset(12);
        make.right.equalTo(self.view).with.offset(-12);
        make.bottom.equalTo(self.view).with.offset(-33);
        make.height.mas_equalTo(ShortDramaSelectionViewHeight);
    }];
}

- (void)reloadData {
    [self.controlViewController reloadData:self.dramaVideoInfo];
    [self.drameSelectionView reloadData:self.dramaVideoInfo];
}

#pragma mark - ShortDramaSelectionViewDelegate

- (void)onClickDramaSelectionCallback {
    if (self.delegate && [self.delegate respondsToSelector:@selector(onClickDramaSelectionCallback:)]) {
        [self.delegate onClickDramaSelectionCallback:self.dramaVideoInfo];
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
    [self.playerController play];
    self.playerController.looping = YES;
    self.playerController.videoViewMode = VEVideoViewModeAspectFill;
}

- (void)playerStop {
    @autoreleasepool {
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
    [self.view addSubview:self.playerController.view];
    [self.view bringSubviewToFront:self.playerController.view];
    [self.playerController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.bottom.equalTo(self.view).with.offset(-VEShortDramaDetailVideoCellBottomOffset);
    }];
    
    self.controlViewController = [[ShortDramaDetailPlayControlViewController alloc] initWithVideoPlayerController:self.playerController];
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

#pragma mark - lazy load

- (ShortDramaSelectionView *)drameSelectionView {
    if (_drameSelectionView == nil) {
        _drameSelectionView = [[ShortDramaSelectionView alloc] init];
        _drameSelectionView.delegate = self;
    }
    return _drameSelectionView;
}

@end
