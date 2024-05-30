//
//  VELongVideoDetailViewController.m
//  VOLCDemo
//
//  Created by RealZhao on 2021/12/23.
//

#import "VELongVideoDetailViewController.h"
#import "VEVideoModel.h"
#import "VESettingManager.h"

#import "VEPlayerUIModule.h"
#import "VEInterfaceSimpleBlockSceneConf.h"
#import "VEPlayerKit.h"
#import <Masonry/Masonry.h>
#import "UIViewController+Orientation.h"

@interface VELongVideoDetailViewController () <VEInterfaceDelegate>

@property (nonatomic, strong) VEVideoPlayerController *playerController; // player Container

@property (nonatomic, strong) VEInterface *playerControlView; // player Control view

@property (nonatomic, strong) UIView *playContainerView; // playerView & playerControlView Container

@end

@implementation VELongVideoDetailViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self playerStop];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self layoutUI];
    [self addObserver];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
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
    [self.playContainerView addSubview:self.playerControlView];
    CGFloat screenRate = (self.preferredInterfaceOrientationForPresentation == UIInterfaceOrientationPortrait) ? (3.0 / 4.0) : (UIScreen.mainScreen.bounds.size.height / UIScreen.mainScreen.bounds.size.width);
    CGFloat height = UIScreen.mainScreen.bounds.size.width * (screenRate);
    CGFloat top = (self.preferredInterfaceOrientationForPresentation == UIInterfaceOrientationPortrait) ? UIApplication.sharedApplication.statusBarFrame.size.height : 0.0;
    
    [self.playContainerView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(top);
        make.leading.trailing.equalTo(self.view);
        make.height.equalTo(@(height));
    }];
    
    [self.playerController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.playContainerView);
    }];
    [self.playerControlView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.playContainerView);
    }];
}

- (void)setVideoModel:(VEVideoModel *)videoModel {
    _videoModel = videoModel;
    self.playerController.playerTitle = videoModel.title;
    TTVideoEngineVidSource *vidSource = [VEVideoModel ConvertVideoEngineSource:videoModel];
    [self playerOptions];
    [self.playerController playWithMediaSource:vidSource];
    [self.playerController play];
}

- (UIView *)playContainerView {
    if (!_playContainerView) {
        _playContainerView = [UIView new];
    }
    return _playContainerView;
}

- (VEInterface *)playerControlView {
    if (!_playerControlView) {
        _playerControlView = [[VEInterface alloc] initWithPlayerCore:self.playerController scene:[VEInterfaceSimpleBlockSceneConf new]];
        _playerControlView.delegate = self;
    }
    return _playerControlView;
}

- (VEVideoPlayerController *)playerController {
    if (!_playerController) {
        _playerController = [VEVideoPlayerController new];
    }
    return _playerController;
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

- (void)playerStop {
    @autoreleasepool {
        [self.playerControlView removeFromSuperview];
        [self.playerControlView destory];
        self.playerControlView = nil;
        [self.playerController stop];
        [self.playerController.view removeFromSuperview];
        self.playerController = nil;
    }
}


#pragma mark ----- VEInterfaceDelegate


- (void)interfaceCallScreenRotation:(UIView *)interface {
    UIDeviceOrientation oriention = ([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortrait) ? UIDeviceOrientationLandscapeRight : UIDeviceOrientationPortrait;
    [self setDeviceInterfaceOrientation:oriention];
    [self layoutUI];
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

- (void)interfaceCallPageBack:(UIView *)interface {
    switch (self.preferredInterfaceOrientationForPresentation) {
        case UIInterfaceOrientationLandscapeRight: {
            [self interfaceCallScreenRotation:nil];
        }
            break;
        case UIInterfaceOrientationPortrait:
        default: {
            [self close];
        }
            break;
    }
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
