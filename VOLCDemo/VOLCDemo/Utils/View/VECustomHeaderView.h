//
//  VECustomHeaderView.h
//  VOLCDemo
//
//  Created by wangzhiyong on 2021/5/31.
//  Copyright © 2021 ByteDance. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class VECustomHeaderView;

@protocol VECustomHeaderViewDelegate <NSObject>

@optional

- (void)headerViewBackButtonDidClicked:(VECustomHeaderView *)headerView;

- (void)headerViewSettingButtonDidClicked:(VECustomHeaderView *)headerView;

@end

@interface VECustomHeaderView : UIView

@property (nonatomic, weak) id<VECustomHeaderViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
