// Copyright (c) 2025 Beijing Volcano Engine Technology Co., Ltd.
// SPDX-License-Identifier: MIT
//
//  ShortVideoOCTableViewCell.h
//  VEVodPlayerAPIExample
//
//  Created by ByteDance on 2025/6/19.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ShortVideoOCTableViewCell : UITableViewCell
@property (nonatomic, assign) NSInteger row;
- (void)configureSource:(NSString *)sourceUrl cover:(NSString *)coverUrl;
- (void)play;
- (void)pause;
- (void)closeAysnc;

@end

NS_ASSUME_NONNULL_END
