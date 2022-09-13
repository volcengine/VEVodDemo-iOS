//
//  VENetworkHelper.h
//  VOLCDemo
//
//  Created by wangzhiyong on 2021/5/26.
//  Copyright © 2021 ByteDance. All rights reserved.
//

@import Foundation;

typedef void(^HttpSuccessResponseBlock)(id responseObject);
typedef void(^HttpFailureResponseBlock)(NSString *errorMessage);

@interface VENetworkHelper : NSObject

+ (void)requestDataWithUrl:(NSString *)url
                httpMethod:(NSString *)method
                parameters:(NSDictionary * __nullable)parameters
                   success:(HttpSuccessResponseBlock)success
                   failure:(HttpFailureResponseBlock)failure;

@end
