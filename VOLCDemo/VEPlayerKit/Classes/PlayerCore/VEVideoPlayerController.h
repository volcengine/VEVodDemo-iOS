//
//  VEVideoPlayerController.h
//  VOLCDemo
//
//  Created by wangzhiyong on 2021/11/11.
//  Copyright © 2021 ByteDance. All rights reserved.
//

@import UIKit;
#import "VEVideoPlayback.h"
#import <TTSDKFramework/TTSDKFramework.h>
#import "VEPlayProtocol.h"
#import "VEPlayerBaseModule.h"
#import "VEVideoPlayerConfiguration.h"

NS_ASSUME_NONNULL_BEGIN

@interface VEPreRenderVideoEngineMediatorDelegate : NSObject <TTVideoEnginePreRenderDelegate>

@property (nonatomic, weak) VEVideoPlayerConfiguration *playerConfig;
@property (nonatomic, strong) NSMutableDictionary *subtitleModels;
@property (nonatomic, weak) id<TTVideoEngineSubtitleDelegate> subtitleDelegate;

+ (VEPreRenderVideoEngineMediatorDelegate *)shareInstance;

@end

@class VEVideoPlayerController;

@protocol VEVideoPlayerControllerSubtitleDelegate <NSObject>
@optional

- (void)videoPlayerController:(VEVideoPlayerController *)videoPlayerController onSubtitleTextUpdated:(NSString *)subtitle;
- (void)videoPlayerController:(VEVideoPlayerController *)videoPlayerController onSubtitleChanged:(NSInteger)newSubtitleId;
- (void)videoPlayerController:(VEVideoPlayerController *)videoPlayerController onSubtitleRequestFinished:(TTVideoEngineSubDecInfoModel *)subtitleInfoModel error:(NSError * _Nullable)error;
- (void)videoPlayerController:(VEVideoPlayerController *)videoPlayerController onSubtitleLoadFinished:(BOOL)success;
- (NSInteger)getMatchedSubtitleId:(TTVideoEngineSubDecInfoModel *)subtitleInfoModel;
@end

@interface VEVideoPlayerController : UIViewController <VEPlayCoreAbilityProtocol, VEVideoPlayback>

@property (nonatomic, strong, readonly) TTVideoEngine *videoEngine;

@property (nonatomic, readonly) VEVideoPlayerConfiguration *playerConfig;

@property (nonatomic, weak) id<VEVideoPlayerControllerSubtitleDelegate> subtitleDelegate;

// VEPlayCoreAbilityProtocol
@property (nonatomic, weak) id<VEPlayCoreCallBackAbilityProtocol> _Nullable receiver;

- (instancetype)initWithConfiguration:(VEVideoPlayerConfiguration *)configuration;

- (instancetype)initWithConfiguration:(VEVideoPlayerConfiguration *)configuration 
                         moduleLoader:(VEPlayerBaseModule *)moduleLoader;

- (instancetype)initWithConfiguration:(VEVideoPlayerConfiguration *)configuration 
                         moduleLoader:(VEPlayerBaseModule *)moduleLoader
                  playerContainerView:(UIView * _Nullable)containerView;

- (void)setSubtitleAuthToken:(NSString *)subtitleAuthToken;

- (void)setSubtitleInfoModel:(TTVideoEngineSubDecInfoModel *)subtitleInfoModel;

- (void)setSubtitleId:(NSInteger)subtitleId;

- (void)loadBackgourdImageWithMediaSource:(id<TTVideoEngineMediaSource> _Nonnull)mediaSource;

- (void)preparePip;

- (void)switchPip;

+ (void)cleanCache;

@end

NS_ASSUME_NONNULL_END
