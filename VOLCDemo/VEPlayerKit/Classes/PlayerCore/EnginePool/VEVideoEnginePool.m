//
//  VEVideoEnginePool.m
//  Pods
//
//  Created by zyw on 2024/7/16.
//

#import "VEVideoEnginePool.h"
#import "BTDMacros.h"

@interface VEVideoEnginePool ()

@property (nonatomic, strong) NSLock *lock;
@property (nonatomic, strong) NSMapTable<NSString *, TTVideoEngine *> *videoEngines;;

@end

@implementation VEVideoEnginePool

+ (VEVideoEnginePool *)shareInstance {
    static VEVideoEnginePool *enginePoolShareInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (enginePoolShareInstance == nil) {
            enginePoolShareInstance = [[VEVideoEnginePool alloc] init];
        }
    });
    return enginePoolShareInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.lock = [[NSLock alloc] init];
        self.videoEngines = [NSMapTable weakToWeakObjectsMapTable];
    }
    return self;
}

- (void)createVideoEngine:(id<TTVideoEngineMediaSource> _Nonnull)mediaSource needPrerenderEngine:(BOOL)needPrerender block:(VEEnginePoolBlock)block {
    [self.lock lock];
    if (mediaSource.uniqueId == nil || mediaSource.uniqueId.length == 0) {
        NSAssert(mediaSource.uniqueId, @"source uniqueId is nil");
        
        BTDLog(@"EnginePool: %@ ===== init video engine play", mediaSource.uniqueId);
        TTVideoEngine *videoEngine = [[TTVideoEngine alloc] init];
        [self.videoEngines setObject:videoEngine forKey:mediaSource.uniqueId];
        BTD_BLOCK_INVOKE(block, videoEngine, VECreateEngineFrom_Init);
    } else {
        TTVideoEngine *prerenderVideoEngine = nil;
        if (needPrerender) {
            prerenderVideoEngine = [TTVideoEngine getPreRenderVideoEngineWithVideoSource:mediaSource];
        }
        if (prerenderVideoEngine) {
            BTDLog(@"EnginePool: %@ ===== use pre render video engine play", mediaSource.uniqueId);
            [self.videoEngines setObject:prerenderVideoEngine forKey:mediaSource.uniqueId];
            BTD_BLOCK_INVOKE(block, prerenderVideoEngine, VECreateEngineFrom_Prerender);
        } else {
            TTVideoEngine *videoEngine = [self.videoEngines objectForKey:mediaSource.uniqueId];
            if (videoEngine == nil) {
                BTDLog(@"EnginePool: %@ ===== init video engine play", mediaSource.uniqueId);
                videoEngine = [[TTVideoEngine alloc] init];
                [self.videoEngines setObject:videoEngine forKey:mediaSource.uniqueId];
                BTD_BLOCK_INVOKE(block, videoEngine, VECreateEngineFrom_Init);
                
            } else {
                BTDLog(@"EnginePool: %@ ===== use cahce video engine play", mediaSource.uniqueId);
                [self.videoEngines setObject:videoEngine forKey:mediaSource.uniqueId];
                BTD_BLOCK_INVOKE(block, videoEngine, VECreateEngineFrom_Cache);
            }
        }
    }
    BTDLog(@"EnginePool: %@ ===== engine count %@", mediaSource.uniqueId, @(self.videoEngines.count));
    [self.lock unlock];
}

- (void)removeVideoEngine:(id<TTVideoEngineMediaSource> _Nonnull)mediaSource {
    [self.lock lock];
    if (mediaSource.uniqueId) {
        [self.videoEngines removeObjectForKey:mediaSource.uniqueId];
    }
    [self.lock unlock];
}

@end
