//
//  UIScrollView+Refresh.h
//  VOLCDemo
//
//  Created by real on 2022/8/29.
//  Copyright © 2022 ByteDance. All rights reserved.
//

@import UIKit;

@interface UIScrollView (Refresh)

@property (nonatomic, assign) BOOL veLoading;

- (void)systemRefresh:(void (^)(void))handler;

- (void)beginRefresh;

- (void)endRefresh;

@end
