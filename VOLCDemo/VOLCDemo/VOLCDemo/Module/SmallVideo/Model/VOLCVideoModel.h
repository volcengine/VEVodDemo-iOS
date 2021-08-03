//
//  VOLCVideoModel.h
//  VOLCDemo
//
//  Created by wangzhiyong on 2021/5/24.
//  Copyright © 2021 ByteDance. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VOLCVideoModel : NSObject

@property (nonatomic, copy) NSString *videoId;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *coverUrl;
@property (nonatomic, copy) NSString *playAuthToken;
@property (nonatomic, copy) NSString *duration;
@property (nonatomic, assign) NSInteger extendIndex;

- (instancetype)initWithJsonDictionary:(NSDictionary *)jsonDictionary;

@end

NS_ASSUME_NONNULL_END
