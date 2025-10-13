//
//  VELongVideoDetailViewController.m
//  VOLCDemo
//
//  Created by RealZhao on 2021/12/23.
//

#import "VELongVideoDetailViewController.h"
#import "VEVideoModel.h"
#import "VESettingManager.h"
#import "VEVideoPlayerConfigurationFactory.h"
#import "VEPlayerKit.h"
#import <Masonry/Masonry.h>
#import "UIViewController+Orientation.h"
#import "VEVideoPlayerPipController.h"
#import "VELongVideoPlayerModuleLoader.h"
#import "VEPlayerContextKeyDefine.h"

@interface VELongVideoDetailViewController ()

@property (nonatomic, strong) VEVideoPlayerController *playerController; // player Container

@property (nonatomic, strong) UIView *playContainerView; // playerView & playerControlView Container

@property (nonatomic, strong) VELongVideoPlayerModuleLoader *moduleLoader;

@property (nonatomic, assign) NSInteger portraitTop;

@end

@implementation VELongVideoDetailViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self playerStop];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createPlayer];
    [self layoutUI];
    [self addObserver];
    
    self.playerController.playerTitle = self.videoModel.title;
    [self.moduleLoader.context post:self.videoModel.title forKey:VEPlayerContextKeyDataModelChanged];
    TTVideoEngineVidSource *vidSource = [VEVideoModel ConvertVideoEngineSource:self.videoModel];
    [self playerOptions];
    [self.playerController preparePip];
    [self.playerController playWithMediaSource:vidSource];
    [self.playerController play];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[VEVideoPlayerPipController shared] setVideoViewMode:VEVideoViewModeAspectFit];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)addObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(screenOrientationChanged:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
}

- (void)layoutUI {
    self.view.backgroundColor = [UIColor blackColor];
    self.navigationItem.hidesBackButton = YES;
    self.navigationController.navigationItem.title = @"";
    [self.view addSubview:self.playContainerView];
    [self.playContainerView addSubview:self.playerController.view];

    CGFloat screenRate = (self.preferredInterfaceOrientationForPresentation == UIInterfaceOrientationPortrait) ? (3.0 / 4.0) : (UIScreen.mainScreen.bounds.size.height / UIScreen.mainScreen.bounds.size.width);
    CGFloat height = UIScreen.mainScreen.bounds.size.width * (screenRate);
    if (UIApplication.sharedApplication.statusBarFrame.size.height > 0) {
        self.portraitTop = UIApplication.sharedApplication.statusBarFrame.size.height;
    }
    CGFloat top = (self.preferredInterfaceOrientationForPresentation == UIInterfaceOrientationPortrait) ? self.portraitTop : 0.0;

    
    [self.playContainerView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(top);
        make.leading.trailing.equalTo(self.view);
        make.height.equalTo(@(height + 80));
    }];
    
    [self.playerController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.playContainerView);
        make.bottom.equalTo(self.playContainerView).with.offset(-80);
    }];
}

- (void)setVideoModel:(VEVideoModel *)videoModel {
    _videoModel = videoModel;
}

- (void)createPlayer {
    if (self.playerController == nil) {
        self.moduleLoader = [[VELongVideoPlayerModuleLoader alloc] init];
        self.moduleLoader.curVC = self;
        VEVideoPlayerConfiguration *configration = [VEVideoPlayerConfigurationFactory getConfiguration];
        [VEPreRenderVideoEngineMediatorDelegate shareInstance].playerConfig = configration;
        self.playerController = [[VEVideoPlayerController alloc] initWithConfiguration:configration moduleLoader:self.moduleLoader playerContainerView:self.playContainerView];
    }
}

- (UIView *)playContainerView {
    if (!_playContainerView) {
        _playContainerView = [UIView new];
    }
    return _playContainerView;
}

- (void)playerOptions {
    VESettingModel *preRender = [[VESettingManager universalManager] settingForKey:VESettingKeyShortVideoPreRenderStrategy];
    self.playerController.preRenderOpen = preRender.open;
    
    VESettingModel *preload = [[VESettingManager universalManager] settingForKey:VESettingKeyShortVideoPreloadStrategy];
    self.playerController.preloadOpen = preload.open;
}

- (void)playerStop {
    @autoreleasepool {
        [self.playerController stop];
        [self.playerController.view removeFromSuperview];
        self.playerController = nil;
    }
}

#pragma mark ----- UIInterfaceOrientation

- (void)screenOrientationChanged:(NSNotification *)notification {
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    switch (interfaceOrientation) {
        case UIInterfaceOrientationLandscapeRight: {
            self.navigationController.interactivePopGestureRecognizer.enabled = NO;
        }
            break;
        case UIInterfaceOrientationPortrait:
        default: {
            self.navigationController.interactivePopGestureRecognizer.enabled = YES;
        }
            break;
    }
    if ([self respondsToSelector:@selector(selectorsetNeedsUpdateOfHomeIndicatorAutoHidden)]) {
        [self setNeedsUpdateOfHomeIndicatorAutoHidden];
    }
    [self layoutUI];
    [self.view setNeedsLayout];
}

- (BOOL)prefersHomeIndicatorAutoHidden {
    if (self.preferredInterfaceOrientationForPresentation == UIInterfaceOrientationPortrait) {
        return NO;
    } else {
        return YES;
    }
}


#pragma mark - Status Bar

- (UIStatusBarStyle)preferredStatusBarStyle {
    return 1;
}

- (void)close {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
