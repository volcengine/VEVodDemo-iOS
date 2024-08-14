//
//  VEVideoEnginePool.h
//  Pods
//
//  Created by zyw on 2024/7/16.
//

#import <Foundation/Foundation.h>
#import <TTSDKFramework/TTSDKFramework.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, VECreateEngineFrom) {
    VECreateEngineFrom_Init,
    VECreateEngineFrom_Cache,
    VECreateEngineFrom_Prerender,
};

typedef void(^VEEnginePoolBlock)(TTVideoEngine * _Nullable engine, VECreateEngineFrom engineFrom);

@interface VEVideoEnginePool : NSObject

+ (VEVideoEnginePool *)shareInstance;

- (void)createVideoEngine:(id<TTVideoEngineMediaSource> _Nonnull)mediaSource needPrerenderEngine:(BOOL)needPrerender block:(VEEnginePoolBlock)block;

- (void)removeVideoEngine:(id<TTVideoEngineMediaSource> _Nonnull)mediaSource;
@end

NS_ASSUME_NONNULL_END
