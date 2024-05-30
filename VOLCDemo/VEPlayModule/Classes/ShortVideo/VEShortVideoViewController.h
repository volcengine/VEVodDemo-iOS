//
//  VEShortVideoViewController.h
//  VOLCDemo
//
//  Created by real on 2022/8/22.
//  Copyright © 2022 ByteDance. All rights reserved.
//

#import "VEViewController.h"

@class VEVideoModel;

@interface VEShortVideoViewController : VEViewController

- (instancetype)initWtihVideoSources:(NSArray<VEVideoModel *> *)videoModels;

@end
