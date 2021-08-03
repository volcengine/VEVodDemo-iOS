//
//  VOLCSmallVideoFeedCell.h
//  VOLCDemo
//
//  Created by wangzhiyong on 2021/6/30.
//  Copyright © 2021 Copyright © 2021 ByteDance. All rights reserved. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class VOLCVideoModel;

@protocol VOLCSmallVideoFeedCellProtocol

@property (nonatomic, assign) NSInteger indexPath;

- (void)configWithVideoModel:(VOLCVideoModel *)videoModle;
- (void)play;
- (void)stop;
- (void)pause;

@end

@interface VOLCSmallVideoFeedCell : UITableViewCell <VOLCSmallVideoFeedCellProtocol>


@end

NS_ASSUME_NONNULL_END
