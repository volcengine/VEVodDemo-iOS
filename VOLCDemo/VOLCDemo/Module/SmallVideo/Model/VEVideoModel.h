//
//  VEVideoModel.h
//  VOLCDemo
//
//  Created by wangzhiyong on 2021/5/24.
//  Copyright © 2021 ByteDance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TTSDK/TTVideoEngineVidSource.h>
#import <TTSDK/TTVideoEngineUrlSource.h>
#import <TTSDK/TTVideoEngineMultiEncodingUrlSource.h>
#import "TTVideoEngineVidSource+VEVidSource.h"
#import "TTVideoEngineUrlSource+VEUrlSource.h"
#import "TTVideoEngineMultiEncodingUrlSource+VECodecUrlSource.h"

NS_ASSUME_NONNULL_BEGIN

@interface VEVideoModel : NSObject

/// play with url
@property (nonatomic, copy) NSString *playUrl;
@property (nonatomic, copy) NSString *h265PlayUrl;

/// play with video id and play auth token
@property (nonatomic, copy) NSString *videoId;
@property (nonatomic, copy) NSString *playAuthToken;

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *coverUrl;
@property (nonatomic, copy) NSString *duration;
@property (nonatomic, assign) NSInteger extendIndex;

- (instancetype)initWithJsonDictionary:(NSDictionary *)jsonDictionary;

+ (TTVideoEngineVidSource *)videoEngineVidSource:(VEVideoModel *)videoModel;

+ (TTVideoEngineUrlSource *)videoEngineUrlSource:(VEVideoModel *)videoModel;

@end

NS_ASSUME_NONNULL_END
