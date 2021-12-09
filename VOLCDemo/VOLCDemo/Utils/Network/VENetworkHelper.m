//
//  VENetworkHelper.m
//  VOLCDemo
//
//  Created by wangzhiyong on 2021/5/26.
//  Copyright © 2021 ByteDance. All rights reserved.
//

#import "VENetworkHelper.h"

@implementation VENetworkHelper

+ (void)requestDataWithUrl:(NSString *)url
                httpMethod:(NSString *)method
                parameters:(NSDictionary *)parameters
                   success:(HttpSuccessResponseBlock)success
                   failure:(HttpFailureResponseBlock)failure {
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:method];
    [request setValue:@"application/json; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    [request setTimeoutInterval:60];
    
    if ([method isEqualToString:@"POST"]) {
        if (parameters && parameters.allKeys.count > 0) {
            NSString *jsonParam = [[self class] configJsonParam:parameters];
            request.HTTPBody = [jsonParam dataUsingEncoding:NSUTF8StringEncoding];
        }
    }
    
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (failure) {
                    failure(error.description);
                }
            });
        } else {
            NSError *error = nil;
            NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!error) {
                    if (success) {
                        success(responseDictionary);
                    }
                } else {
                    if (failure) {
                        failure(error.description);
                    }
                }
            });
        }
    }];
    [task resume];
}

+ (NSString *)configJsonParam:(NSDictionary *)parameters {
    if (!parameters) {
        return nil;
    }
    
    NSError *error = nil;
    NSData *jsonData = nil;
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [parameters enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSString *keyString = nil;
        NSString *valueString = nil;
        if ([key isKindOfClass:[NSString class]]) {
            keyString = key;
        } else{
            keyString = [NSString stringWithFormat:@"%@",key];
        }
        if ([obj isKindOfClass:[NSString class]]) {
            valueString = obj;
        } else{
            valueString = [NSString stringWithFormat:@"%@",obj];
        }
        [dict setObject:valueString forKey:keyString];
    }];
    
    jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    if ([jsonData length] == 0 || error != nil) {
        return nil;
    }
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    return jsonString;
}

@end
