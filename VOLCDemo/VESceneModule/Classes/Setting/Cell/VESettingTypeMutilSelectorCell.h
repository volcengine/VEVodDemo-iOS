//
//  VESettingTypeMutilSelectorCell.h
//  VOLCDemo
//
//  Created by real on 2022/8/22.
//  Copyright © 2022 ByteDance. All rights reserved.
//

@class VESettingModel;
#import "VESettingCell.h"

extern NSString *VESettingTypeMutilSelectorCellReuseID;

@interface VESettingTypeMutilSelectorCell : VESettingCell

@property (nonatomic, strong) VESettingModel *settingModel;

@end
