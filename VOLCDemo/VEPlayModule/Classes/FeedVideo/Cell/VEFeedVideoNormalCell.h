//
//  VEFeedVideoNormalCell.h
//  VOLCDemo
//
//  Created by real on 2022/8/19.
//  Copyright © 2022 ByteDance. All rights reserved.
//

@import UIKit;
@class VEVideoModel;
@class VEFeedVideoNormalCell;

@protocol VEFeedVideoNormalCellDelegate <NSObject>

- (id)feedVideoCellShouldPlay:(VEFeedVideoNormalCell *)cell;

@end

@interface VEFeedVideoNormalCell : UITableViewCell

@property (nonatomic, strong) VEVideoModel *videoModel;

@property (nonatomic, weak) id<VEFeedVideoNormalCellDelegate> delegate;

- (void)cellDidEndDisplay:(BOOL)force;

+ (CGFloat)cellHeight:(VEVideoModel *)videoModel;

@end
