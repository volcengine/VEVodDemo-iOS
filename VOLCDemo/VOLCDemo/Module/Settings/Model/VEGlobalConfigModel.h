//
//  VEGlobalConfigModel.h
//  VOLCDemo
//
//  Created by wangzhiyong on 2021/5/31.
//  Copyright © 2021 ByteDance. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, VESettingType) {
    VESettingTypeHardDecode = 0,
    VESettingTypeH265,
    VESettingTypeEngineReportLog,
    VESettingTypeMDLReportLog,
    VESettingTypeCopyDeviceId,
    
    //
    VESettingTypeIsUrl,
    VESettingTypeIsCodecUrl,
    VESettingTypeCodecHardware,
    VESettingTypeCodecCost,
    
    VESettingTypeCommonStrategy,
    VESettingTypePreloadStrategy,
    VESettingTypePreRenderStrategy
};

@interface VEGlobalConfigModel : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *deviceId;
@property (nonatomic, assign) BOOL isSwitchOn;
@property (nonatomic, assign) VESettingType settingType;

@end

NS_ASSUME_NONNULL_END
