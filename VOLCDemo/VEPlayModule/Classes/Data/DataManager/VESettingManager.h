//
//  VESettingManager.h
//  VOLCDemo
//
//  Created by real on 2022/8/22.
//  Copyright © 2022 ByteDance. All rights reserved.
//

@import Foundation;
#import "VESettingModel.h"

@interface VESettingManager : NSObject

+ (VESettingManager *)universalManager;
// 分区
- (NSArray *)settingSections;
// 分区/设置
- (NSDictionary *)settings;

- (VESettingModel *)settingForKey:(VESettingKey)key;

@end
