//
//  VESettingModel.h
//  VOLCDemo
//
//  Created by real on 2022/8/22.
//  Copyright © 2022 ByteDance. All rights reserved.
//

@import Foundation;

typedef NS_ENUM(NSUInteger, VESceneType){
    VESceneTypeShortVideo,
    VESceneTypeFeedVideo,
    VESceneTypeLongVideo,
};

typedef NS_ENUM(NSUInteger, VEPlaySourceType){
    VEPlaySourceType_Vid,
    VEPlaySourceType_Url,
};

typedef NS_ENUM(NSUInteger, VEVideoCodecType){
    VEVideoCodecType_H264 = 0,
    VEVideoCodecType_H265 = 1,
};

typedef NS_ENUM(NSUInteger, VEVideoFormatType){
    VEVideoFormatType_MP4 = 1,
    VEVideoFormatType_HLS = 9,
};

typedef enum : NSUInteger {
    VESettingTypeDisplay,
    VESettingTypeDisplayDetail,
    VESettingTypeSwitcher,
    VESettingTypeMutilSelector
} VESettingDisplayType;

typedef enum : NSUInteger {
    VESettingKeyUniversalPlaySourceType = 0000,
    VESettingKeyUniversalH265,
    VESettingKeyUniversalHardwareDecode,
    VESettingKeyUniversalSR,
    VESettingKeyUniversalDeviceID,
    VESettingKeyUniversalActionCleanCache = 1000,
    
    VESettingKeyShortVideoPreloadStrategy = 10000,
    VESettingKeyShortVideoPreRenderStrategy,
    
    VESettingKeyDebugCustomPlaySourceType = 100000,

    VESettingKeyAdEnable = 1000000,
    VESettingKeyAdPreloadCount,
    VESettingKeyAdInterval,
} VESettingKey;

@interface VESettingModel : NSObject

@property (nonatomic, assign) VESettingKey settingKey;

@property (nonatomic, assign) VESettingDisplayType settingType;

@property (nonatomic, assign) BOOL open;

@property (nonatomic, strong) id currentValue;

@property (nonatomic, strong) NSString *displayText;

@property (nonatomic, strong) NSString *detailText;

@property (nonatomic, copy) void(^allAreaAction)(void);

@end

@interface VESettingModel (DisplayCell)

- (NSDictionary *)cellInfo;

- (CGFloat)cellHeight;

@end
