//
//  VOLCGlobalConfigModel.h
//  VOLCDemo
//
//  Created by wangzhiyong on 2021/5/31.
//  Copyright © 2021 ByteDance. All rights reserved.
//

#ifndef _PLAYER_GLOBAL_CONFIG
#define _PLAYER_GLOBAL_CONFIG

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, UserGlobalConfigType) {
    UserGlobalConfigH265,
    UserGlobalConfigHardDecode,
    UserGlobalConfigisMDLPreloadOn,
    UserGlobalConfigEngineReportLog,
    UserGlobalConfigMDLReportLog,
};

NS_ASSUME_NONNULL_BEGIN

@interface VOLCUserGlobalConfiguration : NSObject<NSCoding>

//switch
@property (nonatomic, assign, readonly) BOOL isH265Enabled;
@property (nonatomic, assign, readonly) BOOL isHardDecodeOn;
@property (nonatomic, assign, readonly) BOOL isMDLPreloadOn;
@property (nonatomic, assign, readonly) BOOL isEngineReportLog;
@property (nonatomic, assign, readonly) BOOL isMDLReportLog;


+ (VOLCUserGlobalConfiguration *)sharedInstance;

- (void)setSwitch:(BOOL)isOn forType:(UserGlobalConfigType)type;

- (void)serializeData;

@end

NS_ASSUME_NONNULL_END

#endif
