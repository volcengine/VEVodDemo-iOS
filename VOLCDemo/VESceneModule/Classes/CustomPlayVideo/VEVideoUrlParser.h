//
//  VEVideoUrlParser.h
//  VideoPlaybackEdit
//
//  Created by bytedance on 2023/11/2.
//

#import <Foundation/Foundation.h>
#import "VEVideoModel.h"


@interface VEVideoUrlParser : NSObject

+ (NSArray<VEVideoModel *> *)parseUrl:(NSString *)urlString;

@end


