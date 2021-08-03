//
//  VOLCCustomHeaderView.h
//  VOLCDemo
//
//  Created by wangzhiyong on 2021/5/31.
//  Copyright © 2021 ByteDance. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class VOLCCustomHeaderView;

@protocol VOLCCustomHeaderViewDelegate <NSObject>

@optional

- (void)headerViewBackButtonDidClicked:(VOLCCustomHeaderView *)headerView;

- (void)headerViewSettingButtonDidClicked:(VOLCCustomHeaderView *)headerView;

@end

@interface VOLCCustomHeaderView : UIView

@property (nonatomic, weak) id<VOLCCustomHeaderViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
