//
//  VEVideoPlayerViewController.h
//  VOLCDemo
//
//  Created by wangzhiyong on 2021/11/11.
//  Copyright © 2021 ByteDance. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VEVideoPlayback.h"
#import "VEVideoPlaybackPanel.h"
#import <TTSDK/TTVideoEngineHeader.h>

NS_ASSUME_NONNULL_BEGIN

@interface VEPreRenderVideoEngineMediatorDelegate : NSObject <TTVideoEnginePreRenderDelegate>

+ (VEPreRenderVideoEngineMediatorDelegate *)shareInstance;

@end


@interface VEVideoPlayerViewController : UIViewController <VEVideoPlayback>

@property (nonatomic, strong, readonly) TTVideoEngine *videoEngine;

- (void)registePlaybackPanelController:(UIViewController<VEVideoPlaybackPanelPotocol> *)playbackPanelController;

- (void)loadBackgourdImageWithMediaSource:(id<TTVideoEngineMediaSource> _Nonnull)mediaSource;

@end

NS_ASSUME_NONNULL_END
