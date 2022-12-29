//
//  VEVideoPlayerController+Options.h
//  VOLCDemo
//
//  Created by wangzhiyong on 2021/12/5.
//

#import "VEVideoPlayerController.h"


@interface VEVideoPlayerController (EngineOptions)

@property (nonatomic, assign) BOOL h265Open;

@property (nonatomic, assign) BOOL hardwareDecodeOpen;

- (void)openVideoEngineDefaultOptions;

@end

