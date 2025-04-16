//
//  VEDataManager.m
//  VOLCDemo
//
//  Created by real on 2022/8/22.
//  Copyright © 2022 ByteDance. All rights reserved.
//

#import "VEDataManager.h"
#import "VENetworkHelper.h"
#import "VEVideoModel.h"
#import "VESettingManager.h"
#import "NSString+BTDAdditions.h"
#import "VEVideoPlayerConfiguration.h"

static NSString *longVideoZone = @"long-video";
static NSString *feedVideoZone = @"feedvideo";
static NSString *shortVideoZone = @"short-video";

static NSString *requestVidSourceUrl = @"https://vevod-demo-server.volcvod.com/api/general/v1/getFeedStreamWithPlayAuthToken";
static NSString *requestUrlSourceUrl = @"https://vevod-demo-server.volcvod.com/api/general/v1/getFeedStreamWithVideoModel";

@implementation VEDataManager

+ (void)dataForScene:(VESceneType)type range:(NSRange)range result:(void(^)(NSArray<VEVideoModel *> *))result  onError:(void(^)(NSString* errorMessage))onError {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray *medias = [NSMutableArray array];
        NSString *key;
        switch (type) {
            case VESceneTypeShortVideo: key = shortVideoZone; break;
            case VESceneTypeFeedVideo:  key = feedVideoZone; break;
            case VESceneTypeLongVideo:  key = longVideoZone; break;
        }
        NSDictionary *param;
        if (range.length) {
            param = @{@"userID" : key, @"offset" : @(range.location), @"pageSize" : @(range.length)};
        } else {
            param = @{@"userID" : key};
        }
        
        NSString *urlString = requestVidSourceUrl;
        if ([VEDataManager getRequestSourceType] == VERequestPlaySourceType_Vid) {
            urlString = requestVidSourceUrl;
        } else if ([VEDataManager getRequestSourceType] == VERequestPlaySourceType_Url) {
            urlString = requestUrlSourceUrl;
        }
        [VENetworkHelper requestDataWithUrl:urlString httpMethod:@"POST" parameters:param success:^(id _Nonnull responseObject) {
            if (responseObject && [responseObject isKindOfClass:[NSDictionary class]]) {
                NSArray* results = [responseObject objectForKey:@"result"];
                for (NSDictionary *dic in results) {
                    VEVideoModel *videoModel = nil;
                    if ([VEDataManager getRequestSourceType] == VERequestPlaySourceType_Vid) {
                        videoModel = [[VEVideoModel alloc] initWithDictionary:dic error:nil];
                    } else if ([VEDataManager getRequestSourceType] == VERequestPlaySourceType_Url) {
                        NSDictionary *videoModelDict = [self dictionaryFromJsonString:[dic objectForKey:@"videoModel"]];
                        VEVideoInfoModel *videoInfoModel = [[VEVideoInfoModel alloc] initWithDictionary:videoModelDict error:nil];
                        videoModel = [[VEVideoModel alloc] initWithDictionary:dic error:nil];
                        videoModel.videoInfoModel = videoInfoModel;
                    }

                    if (videoModel) {
                        if ([VEDataManager getSubtitleSourceType] == VESubtitleSourceType_Url) {
                            NSDictionary *subtitleModelDict = [self dictionaryFromJsonString:[dic objectForKey:@"subtitleModel"]];
                            videoModel.subtitleInfoDict = [VEDataManager subtitleDictionaryFromSubtitleArray:subtitleModelDict];
                        }
                        [medias addObject:videoModel];
                    }
                }
            }
            if (result) {
                result(medias);
            }
        } failure:^(NSString * _Nonnull errorMessage) {
            if (onError) {
                onError(errorMessage);
            }
        }];
    });
}

+ (void)dataForScene:(VESceneType)type range:(NSRange)range result:(void(^)(NSArray<VEVideoModel *> *))result {
    [VEDataManager dataForScene:type range:range result:result onError:nil];
}

+ (VERequestPlaySourceType)getRequestSourceType {
    VESettingModel *model = [[VESettingManager universalManager] settingForKey:VESettingKeyUniversalPlaySourceType];
    return (VERequestPlaySourceType)[model.currentValue integerValue];
}

+ (VESubtitleSourceType)getSubtitleSourceType {
    VESettingModel *model = [[VESettingManager universalManager] settingForKey:VESettingKeySubtitleSourceType];
    return (VESubtitleSourceType)[model.currentValue integerValue];
}

+ (NSDictionary *)dictionaryFromJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }

    NSError *error;
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dictionay = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&error];
    if(error) {
        return nil;
    }
    return dictionay;
}

+ (NSDictionary *)subtitleDictionaryFromSubtitleArray:(NSArray *)subtitleArray {
    if (!subtitleArray || subtitleArray.count == 0) {
        return nil;
    }
    NSMutableArray *retArray = [NSMutableArray array];
    for (NSDictionary *subInfoDic in subtitleArray) {
        NSMutableDictionary *retDic = [NSMutableDictionary dictionary];
        [retDic setObject:[subInfoDic objectForKey:@"Format"] forKey:kTTVideoEngineSubModelFormatKey];
        [retDic setObject:[subInfoDic objectForKey:@"SubtitleId"] forKey:kTTVideoEngineSubModelSubtitleIdKey];
        [retDic setObject:[subInfoDic objectForKey:@"LanguageId"] forKey:kTTVideoEngineSubModelLangIdKey];
        [retDic setObject:[subInfoDic objectForKey:@"Language"] forKey:kTTVideoEngineSubModelLanguageKey];
        NSString *subtitleUrl = [subInfoDic objectForKey:@"SubtitleUrl"];
        [retDic setObject:subtitleUrl forKey:kTTVideoEngineSubModelURLKey];
        [retDic setObject:[VEDataManager generateSubtitleCacheKey:subtitleUrl] forKey:kTTVideoEngineSubModelCacheKey];
        [retArray addObject:retDic];
    }
    NSMutableDictionary *retSubInfoDic = [NSMutableDictionary dictionary];
    [retSubInfoDic setObject:[retArray copy] forKey:@"list"];
    return [retSubInfoDic copy];
}

+ (NSString *)generateSubtitleCacheKey:(NSString *)url {
    NSString *md5String = [VEDataManager generateVolcCDNUrlTypeCCacheKey:url];
    if (!md5String) {
        md5String = [VEDataManager generateVolcCDNUrlTypeACacheKey:url];
    }
    if (!md5String) {
        return @"";
    }
    return [NSString stringWithFormat:@"%@_sub", md5String];
}

+ (NSString *)generateVolcCDNUrlTypeACacheKey:(NSString *)urlStr {
    NSURL *httpUrl = [NSURL URLWithString:urlStr];
    if (!httpUrl) {
        return nil;
    }

    NSMutableString *pathToHash = [NSMutableString string];
    if (httpUrl.scheme) {
        [pathToHash appendString:httpUrl.scheme];
        [pathToHash appendString:@"://"];
    }
    if (httpUrl.host) {
        [pathToHash appendString:httpUrl.host];
    }
    if (httpUrl.port) {
        [pathToHash appendFormat:@":%@", httpUrl.port];
    }
    if (httpUrl.path) {
        [pathToHash appendString:httpUrl.path];
    }

    return [pathToHash btd_md5String];
}

+ (NSString *)generateVolcCDNUrlTypeCCacheKey:(NSString *)urlStr {
    NSURL *url = [NSURL URLWithString:urlStr];
    if (url == nil) {
        return nil;
    }

    NSArray *pathSegments = [url pathComponents];
    if ([pathSegments count] < 3) {
        return nil;
    }

    NSString *signaturePath = pathSegments[1];
    NSString *expireTimePath = pathSegments[2];

    if ([signaturePath length] == 0) {
        return nil;
    }
    if ([expireTimePath length] == 0 || [expireTimePath length] != 8) {
        return nil;
    }

    unsigned long long expireTime = 0;
    NSScanner *scanner = [NSScanner scannerWithString:expireTimePath];
    [scanner setScanLocation:0];
    if (![scanner scanHexLongLong:&expireTime]) {
        return nil;
    }

    NSMutableString *sb = [NSMutableString string];
    for (NSInteger i = 3; i < [pathSegments count]; i++) {
        [sb appendString:pathSegments[i]];
    }

    return [sb btd_md5String];
}

+ (NSInteger)getMatchedSubtitleId:(TTVideoEngineSubDecInfoModel *)subtitleInfoModel {
    if (!subtitleInfoModel) {
        return 0;
    }

    NSInteger subtitleId = 0;
    for (id<TTVideoEngineSubProtocol> sub in subtitleInfoModel.subModels) {
        if (sub.languageId == [[[VESettingManager universalManager] settingForKey:VESettingKeySubtitleDefaultLang].currentValue integerValue]) {
            subtitleId = sub.subtitleId;
            NSLog(@"found subtitle id: %ld, language id: %ld, cache key: %@", subtitleId, sub.languageId, sub.cacheKey);
            break;
        }
    }
    if (subtitleId == 0) {
        subtitleId = subtitleInfoModel.subModels.firstObject.subtitleId;
        NSLog(@"use first subtitle id: %ld, language id: %ld, cache key: %@", subtitleId, subtitleInfoModel.subModels.firstObject.languageId, subtitleInfoModel.subModels.firstObject.cacheKey);
    }

    return subtitleId;
}

+ (NSDictionary *)buildSubtitleModels:(NSArray<VEVideoModel *> *)videoModels {
    NSMutableDictionary *models = nil;
    if ([VEDataManager getSubtitleSourceType] == VEPlayerKitSubtitleSourceAuthToken) {
        models = [NSMutableDictionary dictionary];
        [videoModels enumerateObjectsUsingBlock:^(VEVideoModel * _Nonnull videoModel, NSUInteger idx, BOOL * _Nonnull stop) {
            if (videoModel.subtitleAuthToken) {
                [models setObject: videoModel.subtitleAuthToken forKey:videoModel.videoId];
            }
        }];
    } else if ([VEDataManager getSubtitleSourceType] == VEPlayerKitSubtitleSourceDirectUrl) {
        models = [NSMutableDictionary dictionary];
        [videoModels enumerateObjectsUsingBlock:^(VEVideoModel * _Nonnull videoModel, NSUInteger idx, BOOL * _Nonnull stop) {
            if (videoModel.subtitleInfoDict) {
                TTVideoEngineSubDecInfoModel *subtitleInfoModel = [[TTVideoEngineSubDecInfoModel alloc] initWithDictionary:videoModel.subtitleInfoDict];
                NSInteger subtitleId = [VEDataManager getMatchedSubtitleId:subtitleInfoModel];
                NSDictionary *subInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                         @(subtitleId),         @"id",
                                         subtitleInfoModel,     @"model",
                                         nil];
                if ([VEDataManager getRequestSourceType] == VERequestPlaySourceType_Vid) {
                    [models setObject:subInfo forKey:videoModel.videoId];
                } else if ([VEDataManager getRequestSourceType] == VERequestPlaySourceType_Url) {
                    NSString *url = nil;
                    VEVideoItemModel *videoItem = [videoModel.videoInfoModel.urlList lastObject];
                    if (videoItem) {
                        url = videoItem.playUrl;
                    }
                    [models setObject:subInfo forKey:url.btd_md5String];
                }
            }
        }];
    }
    return [models copy];
}

@end

