//
//  NSString+VOLC.m
//  VOLCDemo
//
//  Created by wangzhiyong on 2021/6/20.
//  Copyright © 2021 ByteDance. All rights reserved.
//

#import "NSString+VOLC.h"
#include <CommonCrypto/CommonCrypto.h>

@implementation NSString (VOLC)

- (NSString *)vloc_md5String {
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(data.bytes, (CC_LONG)data.length, result);
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

@end
