//
//  VOLCGlobalConfigModel.h
//  VOLCDemo
//
//  Created by wangzhiyong on 2021/5/31.
//  Copyright © 2021 ByteDance. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, VOLCSettingType) {
    VOLCSettingTypeHardDecode = 0,
    VOLCSettingTypeH265,
    VOLCSettingTypePreload,
    VOLCSettingTypeEngineReportLog,
    VOLCSettingTypeMDLReportLog,
    
    VOLCSettingTypeCopyDeviceId,
};

@interface VOLCGlobalConfigModel : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *deviceId;
@property (nonatomic, assign) BOOL isSwitchOn;
@property (nonatomic, assign) VOLCSettingType settingType;

@end

NS_ASSUME_NONNULL_END
