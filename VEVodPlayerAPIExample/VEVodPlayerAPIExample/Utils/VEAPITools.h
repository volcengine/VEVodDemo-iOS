// Copyright (c) 2025 Beijing Volcano Engine Technology Co., Ltd.
// SPDX-License-Identifier: MIT
//
//  VEAPITools.h
//  VEVodPlayerAPIExample
//
//  Created by ByteDance on 2025/5/28.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VEAPITools : NSObject

+ (nullable NSString *)convertSecondsToStr:(CGFloat)seconds;
+ (NSString *)md5With:(NSString *)ori;

@end

NS_ASSUME_NONNULL_END
