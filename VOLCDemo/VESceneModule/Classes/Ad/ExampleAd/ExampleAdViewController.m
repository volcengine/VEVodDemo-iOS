//
//  ExampleAdViewController.m
//  VESceneModule
//
//  Created by litao.he on 2024/11/7.
//

#import "ExampleAdViewController.h"
#import "ExampleAdContextKeyDefine.h"
#import "VEAdActionResponderDelegate.h"
#import <Masonry/Masonry.h>
#import "VEVideoPlayerController.h"
#import "ExampleAdPlayerModuleLoader.h"
#import "VEVideoModel.h"
#import "VEPlayerUIModule.h"
#import "VEPlayerKit.h"
#import "VESettingManager.h"
#import "ExampleAdAction.h"

@interface ExampleAdViewController () <VEVideoPlaybackDelegate>

@property (nonatomic, strong, readwrite) VEVideoModel *adModel;
@property (nonatomic, strong) NSString* adId;
@property (nonatomic, assign) NSInteger hostSceneType;
@property (nonatomic, strong) ExampleAdPlayerModuleLoader *moduleLoader;
@property (nonatomic, strong) VEVideoPlayerController *playerController;

@end

@implementation ExampleAdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor blackColor];
}

#pragma mark - Public

- (void)reloadData:(VEVideoModel *)adModel forAdId:(NSString*)adId andSceneType:(NSInteger)sceneType {
    self.adModel = adModel;
    self.adId = adId;
    self.hostSceneType = sceneType;
    // 提前加载封面图
    [self loadPlayerCover];
}

- (void)play {
    [self playerStart];
}

#pragma mark ----- Life Circle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadPlayerCover];
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

#pragma mark - VEVideoPlaybackDelegate

- (void)videoPlayer:(id<VEVideoPlayback> _Nullable)player playbackStateDidChange:(VEVideoPlaybackState)state {

}

- (void)videoPlayer:(id<VEVideoPlayback> _Nullable)player didFinishedWithStatus:(VEPlayFinishStatus *_Nullable)finishStatus {
    if (finishStatus.error) {
        // catch error here
    } else {
        if (finishStatus.finishState == VEVideoPlayFinishStatusType_SystemFinish) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(adPlayFinished:)]) {
                [self.delegate adPlayFinished:self.adId];
            }
        }
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
    [self.playerController playWithMediaSource:[VEVideoModel ConvertVideoEngineSource:self.adModel]];
    [self.playerController play];
    self.playerController.looping = YES;
}

- (void)playerStop {
    if (self.playerController) {
        [self.playerController stop];
        [self.playerController.view removeFromSuperview];
        [self.playerController removeFromParentViewController];
        self.playerController = nil;
    }
}

#pragma mark ----- Player

- (void)createPlayer {
    if (self.playerController == nil) {
        self.moduleLoader = [[ExampleAdPlayerModuleLoader alloc] initWithSceneType:self.hostSceneType];

        VEVideoPlayerConfiguration *configration = [VEVideoPlayerConfiguration defaultPlayerConfiguration];
        configration.looping = NO;
        self.playerController = [[VEVideoPlayerController alloc] initWithConfiguration:configration moduleLoader:self.moduleLoader playerContainerView:self.view];
        self.playerController.delegate = self;
        [self.view addSubview:self.playerController.view];
        [self.view bringSubviewToFront:self.playerController.view];
        [self.playerController.view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.bottom.equalTo(self.view);
//            make.bottom.equalTo(self.view).with.offset(-80);
        }];
        [self playerOptions];
        [self.moduleLoader.context post:self.adModel forKey:ExampleAdContextKeyDataModelChanged];
        @weakify(self);
        [self.moduleLoader.context addKey:ExampleAdContextKeyActionTriggered withObserver:self handler:^(ExampleAdAction *action, NSString *key) {
            @strongify(self);
            if ([action.action isEqual: @"MoreDetail"]) {
                NSURL *url = [NSURL URLWithString:[action.params objectForKey:@"url"]];
                if ([[UIApplication sharedApplication] canOpenURL:url]) {
                    [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
                        if (success) {
                            // success processor here
                        } else {
                            // failed processor here
                        }
                    }];
                } else {
                    // failed processor here
                }
            }
        }];
    }
}

- (void)loadPlayerCover {
    if (self.playerController.isPlaying) {
        return;
    }
    [self createPlayer];
    self.playerController.videoViewMode = VEVideoViewModeAspectFill;
    [self.playerController loadBackgourdImageWithMediaSource:[VEVideoModel ConvertVideoEngineSource:self.adModel]];
}

- (void)playerOptions {
    VESettingModel *preRender = [[VESettingManager universalManager] settingForKey:VESettingKeyShortVideoPreRenderStrategy];
    self.playerController.preRenderOpen = NO; //preRender.open;
    
    VESettingModel *preload = [[VESettingManager universalManager] settingForKey:VESettingKeyShortVideoPreloadStrategy];
    self.playerController.preloadOpen = NO; //preload.open;
}

@end
