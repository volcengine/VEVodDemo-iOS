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

#import <Masonry/Masonry.h>
#import <VEPlayerUIModule/VEPlayerUIModule.h>
#import <VEPlayerUIModule/VEInterfaceSimpleMethodSceneConf.h>
#import <VEPlayerKit/VEPlayerKit.h>


@interface VEShortVideoCellController () <VEInterfaceDelegate>

@property (nonatomic, strong) VEVideoPlayerController *playerController;

@property (nonatomic, strong) VEInterface *playerControlInterface;

@end

@implementation VEShortVideoCellController

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


#pragma mark ----- Play

- (void)playerCover {
    if (self.playerController.isPlaying) {
        return;
    }
    [self createPlayer];
    [self.playerController loadBackgourdImageWithMediaSource:[VEVideoModel ConvertVideoEngineSource:self.videoModel]];
}

- (void)playerStart {
    if (self.playerController.isPlaying){
        return;
    }
    if (!self.playerController) {
        [self createPlayer];
    }
    [self createPlayerControl];
    [self playerOptions];
    [self.playerController playWithMediaSource:[VEVideoModel ConvertVideoEngineSource:self.videoModel]];
    [self.playerController play];
    self.playerController.looping = YES;
}

- (void)playerStop {
    @autoreleasepool {
        [self.playerController stop];
        [self.playerControlInterface removeFromSuperview];
        self.playerControlInterface = nil;
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
        make.edges.equalTo(self.view);
    }];
}

- (void)createPlayerControl {
    self.playerControlInterface = [[VEInterface alloc] initWithPlayerCore:self.playerController scene:[VEInterfaceSimpleMethodSceneConf new]];
    self.playerControlInterface.delegate = self;
    [self.view addSubview:self.playerControlInterface];
    [self.playerControlInterface mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
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


#pragma mark ----- VEInterfaceDelegate

- (void)interfaceShouldEnableSlide:(BOOL)enable {
    if ([self.delegate respondsToSelector:@selector(shortVideoController:shouldLockVerticalScroll:)]) {
        [self.delegate shortVideoController:self shouldLockVerticalScroll:enable];
    }
}

@end
