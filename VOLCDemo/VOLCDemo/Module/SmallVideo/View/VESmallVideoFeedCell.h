//
//  VESmallVideoFeedCell.h
//  VOLCDemo
//
//  Created by wangzhiyong on 2021/6/30.
//  Copyright © 2021 ByteDance. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class VEVideoModel;

@protocol VEVideoFeedViewCellProtocol

@property (nonatomic, assign) NSInteger indexPath;

- (void)configWithVideoModel:(VEVideoModel *)videoModel;
- (void)play;
- (void)stop;
- (void)pause;

@end

@interface VESmallVideoFeedCell : UITableViewCell <VEVideoFeedViewCellProtocol>


@end

NS_ASSUME_NONNULL_END
