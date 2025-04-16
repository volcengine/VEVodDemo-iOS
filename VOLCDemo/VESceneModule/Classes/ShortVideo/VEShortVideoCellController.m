//
//  VEShortVideoCellController.m
//  VOLCDemo
//
//  Created by real on 2022/8/22.
//  Copyright © 2022 ByteDance. All rights reserved.
//

#import "VEShortVideoCellController.h"
#import "VEVideoModel.h"
#import "VESettingManager.h"
#import "VEShortVideoPlayerModuleLoader.h"
#import "VEVideoPlayerConfigurationFactory.h"
#import <Masonry/Masonry.h>
#import "VEPlayerKit.h"
#import "VEDataManager.h"

@interface VEShortVideoCellController () <VEVideoPlayerControllerSubtitleDelegate>

@property (nonatomic, strong, readwrite) VEVideoModel *videoModel;
@property (nonatomic, strong) VEVideoPlayerController *playerController;
@property (nonatomic, strong) VEShortVideoPlayerModuleLoader *moduleLoader;

@end

@implementation VEShortVideoCellController

@synthesize reuseIdentifier;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
}

#pragma mark - Public

- (void)reloadData:(VEVideoModel *)videoModel {
    self.videoModel = videoModel;
    // 提前加载封面图
    [self loadPlayerCover];
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
        [self.playerController setSubtitleAuthToken:self.videoModel.subtitleAuthToken];
    } else if ([VEDataManager getSubtitleSourceType] == VESubtitleSourceType_Url) {
        TTVideoEngineSubDecInfoModel *subtitleInfoModel = [[TTVideoEngineSubDecInfoModel alloc] initWithDictionary:self.videoModel.subtitleInfoDict];
        [self.playerController setSubtitleInfoModel:subtitleInfoModel];
        [self.playerController setSubtitleId:[VEDataManager getMatchedSubtitleId:subtitleInfoModel]];
    }
    [self.playerController playWithMediaSource:[VEVideoModel ConvertVideoEngineSource:self.videoModel]];
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
        self.moduleLoader = [[VEShortVideoPlayerModuleLoader alloc] init];
        
        VEVideoPlayerConfiguration *configration = [VEVideoPlayerConfigurationFactory getConfiguration];
        [VEPreRenderVideoEngineMediatorDelegate shareInstance].playerConfig = configration;
        self.playerController = [[VEVideoPlayerController alloc] initWithConfiguration:configration moduleLoader:self.moduleLoader playerContainerView:self.view];
        self.playerController.subtitleDelegate = self;
        [self.view addSubview:self.playerController.view];
        [self.view bringSubviewToFront:self.playerController.view];
        [self.playerController.view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.equalTo(self.view);
            make.bottom.equalTo(self.view).with.offset(-80);
        }];
        [self playerOptions];
    }
}

- (void)loadPlayerCover {
    if (self.playerController.isPlaying) {
        return;
    }
    [self createPlayer];
    self.playerController.videoViewMode = VEVideoViewModeAspectFill;
    [self.playerController loadBackgourdImageWithMediaSource:[VEVideoModel ConvertVideoEngineSource:self.videoModel]];
}

- (void)playerOptions {
    VESettingModel *preRender = [[VESettingManager universalManager] settingForKey:VESettingKeyShortVideoPreRenderStrategy];
    self.playerController.preRenderOpen = preRender.open;
    
    VESettingModel *preload = [[VESettingManager universalManager] settingForKey:VESettingKeyShortVideoPreloadStrategy];
    self.playerController.preloadOpen = preload.open;
}

@end
