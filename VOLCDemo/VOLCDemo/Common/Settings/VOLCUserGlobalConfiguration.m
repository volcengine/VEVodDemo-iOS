//
//  VOLCGlobalConfigModel.h
//  VOLCDemo
//
//  Created by wangzhiyong on 2021/5/31.
//  Copyright © 2021 ByteDance. All rights reserved.
//

#import "VOLCUserGlobalConfiguration.h"

@interface VOLCUserGlobalConfiguration()

// switch
@property (nonatomic, assign) BOOL isH265Enabled;
@property (nonatomic, assign) BOOL isHardDecodeOn;
@property (nonatomic, assign) BOOL isMDLPreloadOn;
@property (nonatomic, assign) BOOL isEngineReportLog;
@property (nonatomic, assign) BOOL isMDLReportLog;

@end

NSString * _Nullable kUserDefaultGlobalConfig = @"kUserDefaultGlobalConfig";

@implementation VOLCUserGlobalConfiguration

+ (VOLCUserGlobalConfiguration *)sharedInstance {
    static VOLCUserGlobalConfiguration *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //deserialization first
        NSData * data = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultGlobalConfig];
        sharedInstance = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        
        if (!sharedInstance) {
            sharedInstance = [[VOLCUserGlobalConfiguration alloc] init];
            // default open
            sharedInstance.isH265Enabled = YES;
            sharedInstance.isHardDecodeOn = YES;
            sharedInstance.isMDLPreloadOn = YES;
            sharedInstance.isEngineReportLog = YES;
            sharedInstance.isMDLReportLog = YES;
        }
    });
    return sharedInstance;
}

- (void)setSwitch:(BOOL)isOn forType:(UserGlobalConfigType)type {
    //make sure here is no warnning
    switch (type) {
        case UserGlobalConfigH265:
            self.isH265Enabled = isOn;
            break;
        case UserGlobalConfigHardDecode:
            self.isHardDecodeOn = isOn;
            break;
        case UserGlobalConfigisMDLPreloadOn:
            self.isMDLPreloadOn = isOn;
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
    [coder encodeObject:@(self.isH265Enabled) forKey:@"k_isH265Enabled"];
    [coder encodeObject:@(self.isHardDecodeOn) forKey:@"k_is_hardDecode"];
    [coder encodeObject:@(self.isMDLPreloadOn) forKey:@"k_is_need_preload"];
    [coder encodeObject:@(self.isEngineReportLog) forKey:@"k_is_engine_report_log"];
    [coder encodeObject:@(self.isMDLReportLog) forKey:@"k_is_mdl_report_log"];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        NSNumber *h265Enabled = [coder decodeObjectForKey:@"k_isH265Enabled"];
        self.isH265Enabled = [h265Enabled boolValue];
        
        NSNumber *hardDecodeon = [coder decodeObjectForKey:@"k_is_hardDecode"];
        self.isHardDecodeOn = [hardDecodeon boolValue];
        
        NSNumber *isMDLPreloadOn = [coder decodeObjectForKey:@"k_is_need_preload"];
        self.isMDLPreloadOn = [isMDLPreloadOn boolValue];
        
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
