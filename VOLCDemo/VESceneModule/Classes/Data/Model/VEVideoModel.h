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

@interface VEVideoItemModel : JSONModel

@property (nonatomic, nullable, copy) NSString *playUrl;

@property (nonatomic, nullable, copy) NSString *fileId;

@end


@interface VEVideoInfoModel : JSONModel

@property (nonatomic, nullable, strong) NSArray<VEVideoItemModel *> *urlList;

@end


@interface VEVideoModel : JSONModel

@property (nonatomic, nullable, copy) NSString *playUrl;

@property (nonatomic, nullable, copy) NSString *h265PlayUrl;

@property (nonatomic, nullable, copy) NSString *videoId;

@property (nonatomic, nullable, copy) NSString *playAuthToken;

@property (nonatomic, nullable, copy) NSString *title;

@property (nonatomic, nullable, copy) NSString *detail;

@property (nonatomic, nullable, copy) NSString *coverUrl;

@property (nonatomic, nullable, copy) NSString *duration;

@property (nonatomic, nullable, strong) VEVideoInfoModel *videoInfoModel;

@property (nonatomic, nullable, copy) NSString *subtitleAuthToken;

@property (nonatomic, nullable, strong) NSDictionary *subtitleInfoDict;

+ (id<TTVideoEngineMediaSource>_Nullable)ConvertVideoEngineSource:(VEVideoModel *_Nullable)videoModel;
+ (id<TTVideoEngineMediaSource>_Nullable)ConvertVideoEngineSource:(VEVideoModel *_Nullable)videoModel forPreloadStrategy:(BOOL)forPreloadStrategy;

@end
