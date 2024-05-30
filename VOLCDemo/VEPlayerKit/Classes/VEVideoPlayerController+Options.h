//
//  VEVideoPlayerController+Options.h
//  VOLCDemo
//
//  Created by wangzhiyong on 2021/12/5.
//

#import "VEVideoPlayerController.h"


@interface VEVideoPlayerController (EngineOptions)

@property (nonatomic, assign) BOOL h265Open; // open h265
@property (nonatomic, assign) BOOL hardwareDecodeOpen; // use hardware decode
@property (nonatomic, assign) BOOL srOpen; // open super resolution

- (void)openVideoEngineDefaultOptions;

@end

