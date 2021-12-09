//
//  VEPlayerSliderControlView.h
//  VOLCDemo
//
//  Created by wangzhiyong on 2021/5/31.
//  Copyright © 2021 ByteDance. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol VEPlayerSliderControlViewDelegate <NSObject>

- (void)sliderWillDragingProgress:(CGFloat)progress;

- (void)sliderProgressValueChanged:(CGFloat)progress;

- (void)sliderDidSeekToProgress:(CGFloat)progress;

@end

@interface VEPlayerSliderControlView : UIView

@property (nonatomic, weak) id<VEPlayerSliderControlViewDelegate> delegate;

@property (nonatomic, readonly) CGFloat progress; // value [0,1]
@property (nonatomic, readonly) CGFloat cacheProgress; // value [0,1]

@property (nonatomic, readonly, getter=isInteractive) BOOL interactive;

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated;

- (void)setCacheProgress:(CGFloat)progress animated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
