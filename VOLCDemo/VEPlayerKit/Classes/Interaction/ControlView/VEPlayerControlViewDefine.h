//
//  VEPlayerControlViewDefine.h
//  VEPlayerKit
//

#ifndef VEPlayerControlViewDefine_h
#define VEPlayerControlViewDefine_h

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, VEPlayerControlViewType) {
    VEPlayerControlViewType_Underlay     = 11,
    VEPlayerControlViewType_Playback     = 12,
    VEPlayerControlViewType_PlaybackLock = 13,
    VEPlayerControlViewType_Overlay      = 14,
};

typedef NS_OPTIONS(NSUInteger, VEPlayerControlViewArea) {
    VEPlayerControlViewAreaNone        = 0,
    VEPlayerControlViewAreaTop         = 1 << 0,
    VEPlayerControlViewAreaLeft        = 1 << 1,
    VEPlayerControlViewAreaBottom      = 1 << 2,
    VEPlayerControlViewAreaRight       = 1 << 3,
    VEPlayerControlViewAreaCenter      = 1 << 4,
};

#endif /* VEPlayerControlViewDefine_h */
