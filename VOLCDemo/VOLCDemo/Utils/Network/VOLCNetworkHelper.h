//
//  VOLCNetworkHelper.h
//  VOLCDemo
//
//  Created by wangzhiyong on 2021/5/26.
//  Copyright © 2021 ByteDance. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^HttpSuccessResponseBlock)(id responseObject);
typedef void(^HttpFailureResponseBlock)(NSString *errorMessage);

@interface VOLCNetworkHelper : NSObject

+ (void)requestDataWithUrl:(NSString *)url
                httpMethod:(NSString *)method
                parameters:(NSDictionary * __nullable)parameters
                   success:(HttpSuccessResponseBlock)success
                   failure:(HttpFailureResponseBlock)failure;

@end

NS_ASSUME_NONNULL_END
