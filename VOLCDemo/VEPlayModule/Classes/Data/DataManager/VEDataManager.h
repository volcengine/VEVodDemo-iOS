//
//  VEDataManager.h
//  VOLCDemo
//
//  Created by real on 2022/8/22.
//  Copyright © 2022 ByteDance. All rights reserved.
//

@import Foundation;
@class VEVideoModel;
#import "VESettingModel.h"

@interface VEDataManager : NSObject

+ (void)dataForScene:(VESceneType)type range:(NSRange)range result:(void(^)(NSArray<VEVideoModel *> *))result;

@end
