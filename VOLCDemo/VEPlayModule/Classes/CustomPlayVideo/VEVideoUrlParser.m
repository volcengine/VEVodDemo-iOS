//
//  VEVideoUrlParser.m
//  VideoPlaybackEdit
//
//  Created by bytedance on 2023/11/2.
//

#import "VEVideoUrlParser.h"
#import "NSString+VE.h"

@implementation VEVideoUrlParser

+ (NSArray<VEVideoModel *> *)parseUrl:(NSString *)urlString {
    if (!urlString.length) {
        return nil;
    }
    NSData *data = [urlString dataUsingEncoding:NSUTF8StringEncoding];
    if (!data) {
        return nil;
    }
    NSMutableArray *modelsArray = [NSMutableArray array];
    NSError *error = nil;
    id obj = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    if (error == nil) {
        //json array or dictionary.
        if ([obj isKindOfClass:[NSArray class]]) {
            NSArray *ary = (NSArray *)obj;
            for (id item in ary) {
                if ([item isKindOfClass:[NSDictionary class]]) {
                    NSDictionary *dic = (NSDictionary *)item;
                    VEVideoModel *videoModel = [[VEVideoModel alloc] initWithDictionary:dic error:nil];
                    [modelsArray addObject:videoModel];
                }
            }
        } else if ([obj isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dic = (NSDictionary *)obj;
            VEVideoModel *videoModel = [[VEVideoModel alloc] initWithDictionary:dic error:nil];
            [modelsArray addObject:videoModel];
        }
    } else {        
        //check if it's url array.
        NSArray *array = [urlString componentsSeparatedByString:@"\n"];
        if (array.count) {
            for (NSString *url in array) {
                VEVideoModel *model = [VEVideoUrlParser parseSingleUrl:url];
                if (model) {
                    [modelsArray addObject:model];
                }
            }
        }
    }
    return modelsArray;
}

+ (VEVideoModel * _Nullable)parseSingleUrl:(NSString *)urlString {
    if (!urlString.length) {
        return nil;
    }
    //file dir
    if ([[urlString substringToIndex:1] isEqualToString:@"/"]) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:urlString]) {
            VEVideoModel *model = [VEVideoModel new];
            model.playUrl = urlString;
            return model;
        } else {
            return nil;
        }
    } else if (urlString.length > 7 && [[urlString substringToIndex:4] isEqualToString:@"http"]) {
        VEVideoModel *model = [VEVideoModel new];
        model.playUrl = urlString;
        return model;
    }
    return nil;
}

@end
