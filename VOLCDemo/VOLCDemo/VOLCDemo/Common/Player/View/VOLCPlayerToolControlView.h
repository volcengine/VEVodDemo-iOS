//
//  VOLCPlayerToolControlView.h
//  VOLCDemo
//
//  Created by wangzhiyong on 2021/5/31.
//  Copyright © 2021 ByteDance. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class VOLCPlayerToolControlView;

@protocol VOLCPlayerToolControlViewDelegate <NSObject>

- (void)toolControlViewDebugButtonDidClicked:(VOLCPlayerToolControlView *)controlView isShow:(BOOL)isShow;

- (void)toolControlViewLogMuteButtonDidClicked:(VOLCPlayerToolControlView *)controlView isMute:(BOOL)mute;

- (void)toolControlViewLogAudioButtonDidClicked:(VOLCPlayerToolControlView *)controlView isAudio:(BOOL)isAudio;

@end

@interface VOLCPlayerToolControlView : UIView

@property (nonatomic, weak) id<VOLCPlayerToolControlViewDelegate> delegate;
@property (nonatomic, assign, readonly) BOOL isMuteOn;
@property (nonatomic, assign, readonly) BOOL isAudioOn;

- (void)reset;

@end

NS_ASSUME_NONNULL_END
