//
//  VEShortVideoCellController.h
//  VOLCDemo
//
//  Created by real on 2022/8/22.
//  Copyright © 2022 ByteDance. All rights reserved.
//

@import UIKit;
@class VEVideoModel;
@class VEShortVideoCellController;
#import "VEPageViewController.h"

@protocol VEShortVideoCellControllerDelegate <NSObject>

- (void)shortVideoController:(VEShortVideoCellController *)controller shouldLockVerticalScroll:(BOOL)shouldLock;

@end

@interface VEShortVideoCellController : UIViewController <VEPageItem>

@property (nonatomic, weak) id<VEShortVideoCellControllerDelegate> delegate;

@property (nonatomic, strong) VEVideoModel *videoModel;

@end
