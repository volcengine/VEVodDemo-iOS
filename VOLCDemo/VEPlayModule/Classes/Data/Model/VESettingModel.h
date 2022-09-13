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

typedef enum : NSUInteger {
    VESettingTypeDisplay,
    VESettingTypeDisplayDetail,
    VESettingTypeSwitcher,
    VESettingTypeMutilSelector
} VESettingDisplayType;

typedef enum : NSUInteger {
    VESettingKeyUniversalH265 = 0000,
    VESettingKeyUniversalHardwareDecode,
    VESettingKeyUniversalDeviceID,
    
    VESettingKeyUniversalActionCleanCache = 1000,
    
    
    VESettingKeyShortVideoPreloadStrategy = 10000,
    VESettingKeyShortVideoPreRenderStrategy,
    
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
