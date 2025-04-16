//
//  VEVideoPlayerConfigurationFactory.h
//  VOLCDemo
//
//  Created by litao.he on 2025/3/7.
//

#import <Foundation/Foundation.h>
#import "VEVideoPlayerConfiguration.h"

NS_ASSUME_NONNULL_BEGIN

@interface VEVideoPlayerConfigurationFactory : NSObject

+ (VEVideoPlayerConfiguration *)getConfiguration;

@end

NS_ASSUME_NONNULL_END

