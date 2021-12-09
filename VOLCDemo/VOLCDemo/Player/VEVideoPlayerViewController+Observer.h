//
//  VEVideoPlayerViewController+Observer.h
//  VOLCDemo
//
//  Created by wangzhiyong on 2021/12/5.
//

#import "VEVideoPlayerViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface VEVideoPlayerViewController (Observer)

@property (nonatomic, assign) BOOL needResumePlay;

- (void)addObserver;

- (void)removeObserver;

@end

NS_ASSUME_NONNULL_END
