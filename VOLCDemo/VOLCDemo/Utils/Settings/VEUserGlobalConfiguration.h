//
//  VEGlobalConfigModel.h
//  VOLCDemo
//
//  Created by wangzhiyong on 2021/5/31.
//  Copyright © 2021 ByteDance. All rights reserved.
//

#ifndef _PLAYER_GLOBAL_CONFIG
#define _PLAYER_GLOBAL_CONFIG

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, UserGlobalConfigType) {
    // strategy
    UserGlobalConfigPreloadStrategy,
    UserGlobalConfigPreRenderStrategy,
    
    // common
    UserGlobalConfigH265,
    UserGlobalConfigHardDecode,
};

NS_ASSUME_NONNULL_BEGIN

@interface VEUserGlobalConfiguration : NSObject<NSCoding>

// strategy
@property (nonatomic, assign, readonly) BOOL preloadStrategyEnabled;
@property (nonatomic, assign, readonly) BOOL preRenderStrategyEnabled;

// common
@property (nonatomic, assign, readonly) BOOL isH265Enabled;
@property (nonatomic, assign, readonly) BOOL isHardDecodeOn;

+ (VEUserGlobalConfiguration *)sharedInstance;

- (void)setSwitch:(BOOL)isOn forType:(UserGlobalConfigType)type;

- (void)serializeData;

@end

NS_ASSUME_NONNULL_END

#endif
