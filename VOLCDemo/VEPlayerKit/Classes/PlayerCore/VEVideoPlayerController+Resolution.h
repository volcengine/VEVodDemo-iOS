//
//  VEVideoPlayerController+Resolution.h
//  VOLCDemo
//
//  Created by wangzhiyong on 2021/12/5.
//

#import "VEVideoPlayerController.h"

NS_ASSUME_NONNULL_BEGIN

@interface VEVideoPlayerController (Resolution)

+ (TTVideoEngineResolutionType)getPlayerCurrentResolution;

+ (void)setPlayerCurrentResolution:(TTVideoEngineResolutionType)defaultResolution;

@end

NS_ASSUME_NONNULL_END
