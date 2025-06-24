// Copyright (c) 2025 Beijing Volcano Engine Technology Co., Ltd.
// SPDX-License-Identifier: MIT
//
//  InitSDKExample.h
//  VEVodPlayerAPIExample
//
//  Created by ByteDance on 2025/5/29.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface InitSDKExample : NSObject

+ (void)initSDKWithAppID:(NSString *)appID LicenseName:(NSString *)licenseName;
+ (void)clearUniqueID;
+ (NSString *)getDeviceID;

@end

NS_ASSUME_NONNULL_END
