// Copyright (c) 2025 Beijing Volcano Engine Technology Co., Ltd.
// SPDX-License-Identifier: MIT
//
//  InitSDKExample.m
//  VEVodPlayerAPIExample
//
//  Created by ByteDance on 2025/5/29.
//

#import "InitSDKExample.h"
#import <TTSDKFramework/TTSDKFramework.h>

@implementation InitSDKExample

+ (void)initSDKWithAppID:(NSString *)appID LicenseName:(NSString *)licenseName {
    [InitSDKExample initTTSDKWithAppID:appID LicenseName:licenseName];
    [InitSDKExample openDebugLog];
    [InitSDKExample setUniqueID:@"VEVodPlayerAPIExample"];
}

+ (void)initTTSDKWithAppID:(NSString *)appID LicenseName:(NSString *)licenseName {
    // 初始化 SDK
    TTSDKConfiguration *configuration = [TTSDKConfiguration defaultConfigurationWithAppID:appID licenseName:licenseName];
    TTSDKVodConfiguration *vodConfig = [[TTSDKVodConfiguration alloc] init];
    vodConfig.cacheMaxSize = 300 * 1024 *1024;
    configuration.vodConfiguration = vodConfig;

    [TTSDKManager startWithConfiguration:configuration];
}

+ (void)openDebugLog {
    // 打开日志调试，建议在 DEBUG 模式下开启
// #ifdef DEBUG
    [TTVideoEngine setLogFlag:TTVideoEngineLogFlagAll];
// #endif
}

+ (void)setUniqueID:(NSString *)str {
    // 自定义设备 ID
    [TTSDKManager setCurrentUserUniqueID:@"VEVodPlayerAPIExample"];
}

+ (void)clearUniqueID {
    // 清理自定义的设备 ID
    [TTSDKManager clearUserUniqueID];
}

+ (NSString *)getDeviceID {
    // 获取设备 ID，需先接入 RangersAppLog
    NSString *deviceID = [TTSDKManager getRangersDeviceID];
    return deviceID;
}

@end
