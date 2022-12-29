//
//  VEVideoModel.h
//  VOLCDemo
//
//  Created by wangzhiyong on 2021/5/24.
//  Copyright © 2021 ByteDance. All rights reserved.
//

@import Foundation;
#import "TTVideoEngineSourceCategory.h"
#import <JSONModel/JSONModel.h>

@interface VEVideoModel : JSONModel

@property (nonatomic, copy) NSString *playUrl;

@property (nonatomic, copy) NSString *h265PlayUrl;

@property (nonatomic, copy) NSString *videoId;

@property (nonatomic, copy) NSString *playAuthToken;

@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) NSString *detail;

@property (nonatomic, copy) NSString *coverUrl;

@property (nonatomic, copy) NSString *duration;

+ (TTVideoEngineVidSource *)videoEngineVidSource:(VEVideoModel *)videoModel;

+ (TTVideoEngineUrlSource *)videoEngineUrlSource:(VEVideoModel *)videoModel;



@end
