//
//  VEVideoPlayerViewController+DebugTool.h
//  VOLCDemo
//
//  Created by wangzhiyong on 2021/12/6.
//

#import "VEVideoPlayerViewController.h"
#import <TTSDK/TTVideoEngineDebugTools.h>

NS_ASSUME_NONNULL_BEGIN

@interface VEVideoPlayerViewController (DebugTool)

@property (nonatomic, strong) TTVideoEngineDebugTools *videoEngineDebugTool; // debug tool

- (void)showDebugViewInView:(UIView *)hudView;

- (void)removeDebugTool;

@end

NS_ASSUME_NONNULL_END
