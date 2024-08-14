//
//  VEVideoPlaybackDefine.h
//  VEPlayerKit
//

#ifndef VEVideoPlaybackDefine_h
#define VEVideoPlaybackDefine_h


typedef NS_ENUM(NSUInteger, VEPlayerVideoSource) {
    VEPlayerVideoSourceFromUnknown,
    VEPlayerVideoSourceFromVid,///vid
    VEPlayerVideoSourceFromLocal,///本地播放视频
    VEPlayerVideoSourceFromUrl,///远程播放地址
    VEPlayerVideoSourceFromUrlArray, ///远程播放地址数组
    VEPlayerVideoSourceFromVideoModel,///videoModel
};

typedef NS_ENUM(NSInteger, VEVideoPlaybackState) {
    VEVideoPlaybackStateUnkown = 0,
    VEVideoPlaybackStatePlaying,
    VEVideoPlaybackStatePaused,
    VEVideoPlaybackStateStopped,
    VEVideoPlaybackStateError,
};

typedef NS_ENUM(NSInteger, VEVideoLoadState) {
    VEVideoLoadStateUnkown = 0,
    VEVideoLoadStatePlayable,
    VEVideoLoadStateStalled,
    VEVideoLoadStateError
};

typedef NS_ENUM(NSInteger, VEVideoViewMode) {
    VEVideoViewModeNone = 0,
    VEVideoViewModeAspectFit,
    VEVideoViewModeAspectFill,
    VEVideoViewModeModeFill
};


typedef NS_ENUM(NSUInteger, VEVideoPlayFinishStatusType) {
    VEVideoPlayFinishStatusType_Unknown =  0,
    VEVideoPlayFinishStatusType_SystemFinish = 1 << 0,   /// 系统正常播放结束 或者 出错结束（数据源出错，播放过程中出错）
    VEVideoPlayFinishStatusType_UserFinish = 1 << 1,     /// 用户手动调用 stop
    VEVideoPlayFinishStatusType_CloseAnsync = 1 << 2,    /// closeAnsync
    VEVideoPlayFinishStatusType_Finish = VEVideoPlayFinishStatusType_SystemFinish | VEVideoPlayFinishStatusType_UserFinish | VEVideoPlayFinishStatusType_CloseAnsync,
};

#endif /* VEVideoPlaybackDefine_h */
