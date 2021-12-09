//
//  VEVideoModel.m
//  VOLCDemo
//
//  Created by wangzhiyong on 2021/5/24.
//  Copyright © 2021 ByteDance. All rights reserved.
//

#import "VEVideoModel.h"
#import "VEVideoPlayerViewController+Resolution.h"
#import "NSString+VE.h"
#import "VEUserGlobalConfiguration.h"

@implementation VEVideoModel

- (instancetype)initWithJsonDictionary:(NSDictionary *)jsonDictionary {
    self = [super init];
    if (self) {
        if (jsonDictionary) {
            _videoId = [jsonDictionary objectForKey:@"vid"];
            _title = [jsonDictionary objectForKey:@"caption"];
            _coverUrl = [jsonDictionary objectForKey:@"coverUrl"];
            _playAuthToken = [jsonDictionary objectForKey:@"playAuthToken"];
            _duration = [jsonDictionary objectForKey:@"duration"];
        }
    }
    return self;
}

+ (TTVideoEngineVidSource *)videoEngineVidSource:(VEVideoModel *)videoModel {
    TTVideoEngineEncodeType codec = [[VEUserGlobalConfiguration sharedInstance] isH265Enabled] ? TTVideoEngineh265 : TTVideoEngineH264;
    TTVideoEngineVidSource *source = [[TTVideoEngineVidSource alloc] initWithVid:videoModel.videoId playAuthToken:videoModel.playAuthToken resolution:[VEVideoPlayerViewController getPlayerCurrentResolution] encodeType:codec isDash:NO isHLS:NO];
    source.title = videoModel.title;
    source.cover = videoModel.coverUrl;
    return source;
}

+ (TTVideoEngineUrlSource *)videoEngineUrlSource:(VEVideoModel *)videoModel {
    TTVideoEngineUrlSource *source = [[TTVideoEngineUrlSource alloc] initWithUrl:videoModel.playUrl cacheKey:videoModel.playUrl.vloc_md5String videoId:videoModel.videoId];
    source.title = videoModel.title;
    source.cover = videoModel.coverUrl;
    return source;
}

+ (TTVideoEngineMultiEncodingUrlSource *)videoEngineCodecUrlSource:(VEVideoModel *)videoModel {
    TTVideoEngineMultiEncodingUrlSource *codecUrlSource = [[TTVideoEngineMultiEncodingUrlSource alloc] initWithVideoId:videoModel.videoId];
    [codecUrlSource addUrl:videoModel.playUrl forCodec:TTVideoEngineH264 withCacheKey:videoModel.playUrl.vloc_md5String andVideoId:videoModel.videoId andDecryptionKey:nil];
    [codecUrlSource addUrl:videoModel.h265PlayUrl forCodec:TTVideoEngineh265 withCacheKey:videoModel.h265PlayUrl.vloc_md5String andVideoId:videoModel.videoId andDecryptionKey:nil];
    codecUrlSource.title = videoModel.title;
    codecUrlSource.cover = videoModel.coverUrl;
    return codecUrlSource;
}

@end
