//
//  VEPlayerInteractionDefine.h
//  VEPlayerKit
//


#ifndef VEPlayerInteractionDefine_h
#define VEPlayerInteractionDefine_h

typedef NS_OPTIONS(NSUInteger, VEGestureType) {
    VEGestureType_None           = 0,
    VEGestureType_SingleTap      = 1 << 0,
    VEGestureType_DoubleTap      = 1 << 1,
    VEGestureType_Pan            = 1 << 2,
    VEGestureType_LongPress      = 1 << 3,
    VEGestureType_Pinch          = 1 << 4,
    VEGestureType_All            = NSUIntegerMax,
};

#endif /* VEPlayerInteractionDefine_h */
