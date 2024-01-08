//
//  VEFeedVideoViewController.h
//  VOLCDemo
//
//  Created by real on 2022/8/21.
//  Copyright © 2022 ByteDance. All rights reserved.
//

#import "VEViewController.h"

@class VEVideoModel;

@interface VEFeedVideoViewController : VEViewController

- (instancetype)initWtihVideoSources:(NSArray<VEVideoModel *> *)videoModels;

@end
