// Copyright (c) 2025 Beijing Volcano Engine Technology Co., Ltd.
// SPDX-License-Identifier: MIT
//
//  VEAPITools.m
//  VEVodPlayerAPIExample
//
//  Created by ByteDance on 2025/5/28.
//

#import "VEAPITools.h"
#import <CommonCrypto/CommonDigest.h>

@implementation VEAPITools

+ (nullable NSString *)convertSecondsToStr:(CGFloat)seconds {
    NSInteger totalSeconds = (NSInteger)round(seconds);
    NSInteger hours = totalSeconds / 3600;
    NSInteger remainingSeconds = totalSeconds % 3600;
    NSInteger minutes = remainingSeconds / 60;
    NSInteger secondsPart = remainingSeconds % 60;
    return [NSString stringWithFormat:@"%02ld:%02ld:%02ld", (long)hours, (long)minutes, (long)secondsPart];
}

+(NSString *)md5With:(NSString *)ori {
    const char *cStr = [ori UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, strlen(cStr), digest );
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", digest[i]];
    }
    return output;
}

@end
