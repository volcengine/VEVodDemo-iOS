//
//  VEVideoPlayerConfiguration.h
//  VEPlayerKit
//
//  Created by zyw on 2024/7/16.
//

#import <Foundation/Foundation.h>
#import "VEVideoPlayback.h"

NS_ASSUME_NONNULL_BEGIN

@interface VEVideoPlayerConfiguration : NSObject

// 播放器默认显示模式, 默认值 VEVideoViewModeAspectFill
@property (nonatomic, assign) VEVideoViewMode videoViewMode;
// 是否音频模式播放, 默认值 NO
@property (nonatomic, assign) BOOL audioMode;
// 是否静音播放, 默认值 NO
@property (nonatomic, assign) BOOL muted;
// 是否循环播放, 默认值 NO
@property (nonatomic, assign) BOOL looping;
// 播放倍速, 默认值 1.0
@property (nonatomic, assign) CGFloat playbackRate;
// 起播时间点, 默认值 0
@property (nonatomic, assign) NSTimeInterval startTime;
// 是否开启H.265播放，H.265播放源开启, 默认关闭
@property (nonatomic, assign) BOOL isH265;
// 播放器是否支持画中画, 默认关闭 API_AVAILABLE(ios(14.0))
@property (nonatomic, assign) BOOL isSupportPictureInPictureMode;
// 是否开启硬解, 默认开启
@property (nonatomic, assign) BOOL isOpenHardware;
// 是否开启超分, 默认关闭
@property (nonatomic, assign) BOOL isOpenSR;
// 开启下载速度
@property (nonatomic, assign) BOOL enableLoadSpeed;

+ (VEVideoPlayerConfiguration *)defaultPlayerConfiguration;

@end

NS_ASSUME_NONNULL_END
