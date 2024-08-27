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

@interface VEVideoEngineURLInfo : JSONModel

@property (nonatomic, nullable, copy) NSString *playUrl;

@end

@interface VEVideoEngineInfoModel : JSONModel

@property (nonatomic, nullable, copy) NSString *videoID;

@property (nonatomic, nullable, strong) NSArray<VEVideoEngineURLInfo *> *urlList;

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

@property (nonatomic, nullable, strong) VEVideoEngineInfoModel *videoEngineInfoModel;

+ (id<TTVideoEngineMediaSource>_Nullable)ConvertVideoEngineSource:(VEVideoModel *_Nullable)videoModel;

@end
