//
//  VOLCVideoModel.m
//  VOLCDemo
//
//  Created by wangzhiyong on 2021/5/24.
//  Copyright © 2021 ByteDance. All rights reserved.
//

#import "VOLCVideoModel.h"

@implementation VOLCVideoModel

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

@end
