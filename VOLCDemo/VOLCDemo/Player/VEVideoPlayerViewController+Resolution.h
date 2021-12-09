//
//  VEVideoPlayerViewController+Resolution.h
//  VOLCDemo
//
//  Created by wangzhiyong on 2021/12/5.
//

#import "VEVideoPlayerViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface VEVideoPlayerViewController (Resolution)

+ (TTVideoEngineResolutionType)getPlayerCurrentResolution;

+ (void)setPlayerCurrentResolution:(TTVideoEngineResolutionType)defaultResolution;

@end

NS_ASSUME_NONNULL_END
