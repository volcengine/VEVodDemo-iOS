//
//  VOLCSmallVideoPlayerView.h
//  VOLCDemo
//
//  Created by wangzhiyong on 2021/5/24.
//  Copyright © 2021 ByteDance. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VOLCVideoModel.h"

NS_ASSUME_NONNULL_BEGIN

extern NSString * const kVOLCCanPreLoadNextVideoIfNeedNotification;

@interface VOLCSmallVideoPlayerView : UIView

@property (nonatomic, assign, readonly) BOOL readyDisplay;
@property (nonatomic, assign, readonly) BOOL posterImageLoaded;

- (void)configWithVideoModel:(VOLCVideoModel *)videoModel;
- (void)play;
- (void)stop;
- (void)pause;

@end

NS_ASSUME_NONNULL_END
