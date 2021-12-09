//
//  VEPlayerToolControlView.h
//  VOLCDemo
//
//  Created by wangzhiyong on 2021/5/31.
//  Copyright © 2021 ByteDance. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class VEPlayerToolControlView;

@protocol VEPlayerToolControlViewDelegate <NSObject>

- (void)toolControlViewDebugButtonDidClicked:(VEPlayerToolControlView *)controlView isShow:(BOOL)isShow;

- (void)toolControlViewLogMuteButtonDidClicked:(VEPlayerToolControlView *)controlView isMute:(BOOL)mute;

- (void)toolControlViewLogAudioButtonDidClicked:(VEPlayerToolControlView *)controlView isAudio:(BOOL)isAudio;

@end

@interface VEPlayerToolControlView : UIView

@property (nonatomic, weak) id<VEPlayerToolControlViewDelegate> delegate;
@property (nonatomic, assign, readonly) BOOL isMuteOn;
@property (nonatomic, assign, readonly) BOOL isAudioOn;

- (void)reset;

@end

NS_ASSUME_NONNULL_END
