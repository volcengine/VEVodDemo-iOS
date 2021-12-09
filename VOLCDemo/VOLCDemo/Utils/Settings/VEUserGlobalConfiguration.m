//
//  VEGlobalConfigModel.h
//  VOLCDemo
//
//  Created by wangzhiyong on 2021/5/31.
//  Copyright © 2021 ByteDance. All rights reserved.
//

#import "VEUserGlobalConfiguration.h"

@interface VEUserGlobalConfiguration()

// strategy
@property (nonatomic, assign) BOOL commonStrategyEnabled;
@property (nonatomic, assign) BOOL preloadStrategyEnabled;
@property (nonatomic, assign) BOOL preRenderStrategyEnabled;

// switch
@property (nonatomic, assign) BOOL isH265Enabled;
@property (nonatomic, assign) BOOL isHardDecodeOn;
@property (nonatomic, assign) BOOL isEngineReportLog;
@property (nonatomic, assign) BOOL isMDLReportLog;

@end

NSString * _Nullable kUserDefaultGlobalConfig = @"kUserDefaultGlobalConfig";

@implementation VEUserGlobalConfiguration

+ (VEUserGlobalConfiguration *)sharedInstance {
    static VEUserGlobalConfiguration *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //deserialization first
        NSData * data = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultGlobalConfig];
        sharedInstance = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        
        if (!sharedInstance) {
            sharedInstance = [[VEUserGlobalConfiguration alloc] init];
            // default open
            sharedInstance.commonStrategyEnabled = YES;
            sharedInstance.preloadStrategyEnabled = YES;
            sharedInstance.preRenderStrategyEnabled = YES;
            
            sharedInstance.isH265Enabled = YES;
            sharedInstance.isHardDecodeOn = YES;
            sharedInstance.isEngineReportLog = YES;
            sharedInstance.isMDLReportLog = YES;
        }
    });
    return sharedInstance;
}

- (void)setSwitch:(BOOL)isOn forType:(UserGlobalConfigType)type {
    //make sure here is no warnning
    switch (type) {
        case UserGlobalConfigCommonStrategy:
            self.commonStrategyEnabled = isOn;
            break;
        case UserGlobalConfigPreloadStrategy:
            self.preloadStrategyEnabled = isOn;
            break;
        case UserGlobalConfigPreRenderStrategy:
            self.preRenderStrategyEnabled = isOn;
            break;
        case UserGlobalConfigH265:
            self.isH265Enabled = isOn;
            break;
        case UserGlobalConfigHardDecode:
            self.isHardDecodeOn = isOn;
            break;
        case UserGlobalConfigEngineReportLog:
            self.isEngineReportLog = isOn;
            break;
        case UserGlobalConfigMDLReportLog:
            self.isMDLReportLog = isOn;
            break;
    }
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:@(self.commonStrategyEnabled) forKey:@"k_commonStrategyEnabled"];
    [coder encodeObject:@(self.preloadStrategyEnabled) forKey:@"k_preloadStrategyEnabled"];
    [coder encodeObject:@(self.preRenderStrategyEnabled) forKey:@"k_preRenderStrategyEnabled"];
    
    [coder encodeObject:@(self.isH265Enabled) forKey:@"k_isH265Enabled"];
    [coder encodeObject:@(self.isHardDecodeOn) forKey:@"k_is_hardDecode"];
    [coder encodeObject:@(self.isEngineReportLog) forKey:@"k_is_engine_report_log"];
    [coder encodeObject:@(self.isMDLReportLog) forKey:@"k_is_mdl_report_log"];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        self.commonStrategyEnabled = [[coder decodeObjectForKey:@"k_commonStrategyEnabled"] boolValue];
        self.preloadStrategyEnabled = [[coder decodeObjectForKey:@"k_preloadStrategyEnabled"] boolValue];
        self.preRenderStrategyEnabled = [[coder decodeObjectForKey:@"k_preRenderStrategyEnabled"] boolValue];
        
        self.isH265Enabled = [[coder decodeObjectForKey:@"k_isH265Enabled"] boolValue];
        self.isHardDecodeOn = [[coder decodeObjectForKey:@"k_is_hardDecode"] boolValue];
        self.isEngineReportLog = [[coder decodeObjectForKey:@"k_is_engine_report_log"] boolValue];
        self.isMDLReportLog = [[coder decodeObjectForKey:@"k_is_mdl_report_log"] boolValue];
    }
    return self;
}

- (void)serializeData {
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:kUserDefaultGlobalConfig];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
