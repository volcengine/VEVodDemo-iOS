//
//  ShortDramaRecordStartTimeModule.m
//  VEPlayModule
//
//  Created by zyw on 2024/7/15.
//

#import "ShortDramaRecordStartTimeModule.h"
#import "VEPlayerContextKeyDefine.h"
#import <Masonry/Masonry.h>
#import "VEDramaVideoInfoModel.h"
#import "VEVideoPlayback.h"
#import "VELRUCache.h"

NSString * const VEPlayerContextKeyDramaSceneWillSwitch = @"VEPlayerContextKeyDramaSceneWillSwitch";
NSString * const VEPlayerContextKeyDramaWillPlay = @"VEPlayerContextKeyDramaWillPlay";

@interface ShortDramaRecordStartTimeModule ()

@property (nonatomic, weak) id<VEVideoPlayback> playerInterface;
@property (nonatomic, weak) VEDramaVideoInfoModel *dramaVideoInfo;
@property (nonatomic, assign) BOOL isPlayed;

@end

@implementation ShortDramaRecordStartTimeModule

VEPlayerContextDILink(playerInterface, VEVideoPlayback, self.context);

#pragma mark - Life Cycle

- (void)moduleDidLoad {
    [super moduleDidLoad];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    @weakify(self);
    [self.context addKey:VEPlayerContextKeyShortDramaDataModelChanged withObserver:self handler:^(VEDramaVideoInfoModel *dramaVideoInfo, NSString *key) {
        @strongify(self);
        self.dramaVideoInfo = dramaVideoInfo;
    }];
    [self.context addKeys:@[VEPlayerContextKeyBeforePlayAction, VEPlayerContextKeyDramaWillPlay] withObserver:self handler:^(id  _Nullable object, NSString * _Nullable key) {
        @strongify(self);
        [self setPlayerStartTime];
    }];
    [self.context addKeys:@[VEPlayerContextKeyStopAction, VEPlayerContextKeyPlaybackDidFinish, VEPlayerContextKeyPauseAction, VEPlayerContextKeyDramaSceneWillSwitch] withObserver:self handler:^(id  _Nullable object, NSString *key) {
        @strongify(self);
        [self recordStartTime];
    }];
}

- (void)controlViewTemplateDidUpdate {
    [super controlViewTemplateDidUpdate];
}

- (void)moduleDidUnLoad {
    [super moduleDidUnLoad];
}

#pragma mark - private

- (void)recordStartTime {
    NSTimeInterval curTime = self.playerInterface.currentPlaybackTime;
    NSTimeInterval duration = self.playerInterface.duration;
    NSTimeInterval startTime = 0;
    if (curTime && duration && (duration - curTime > 5.0)) {
        startTime = curTime;
    }
    
    // 内存级缓存，业务可以根据实际情况修改源码，例如做云端缓存等
    NSString *cacheKey = [NSString stringWithFormat:@"%@_%@", self.dramaVideoInfo.dramaEpisodeInfo.dramaInfo.dramaId, @(self.dramaVideoInfo.dramaEpisodeInfo.episodeNumber)];
    [[VELRUCache shareInstance] setValue:@(startTime) forKey:cacheKey];
}

- (void)setPlayerStartTime {
    if (!self.isPlayed) {
        self.isPlayed = YES;
        NSString *cacheKey = [NSString stringWithFormat:@"%@_%@", self.dramaVideoInfo.dramaEpisodeInfo.dramaInfo.dramaId, @(self.dramaVideoInfo.dramaEpisodeInfo.episodeNumber)];
        NSTimeInterval startTime = [[[VELRUCache shareInstance] getValueForKey:cacheKey] doubleValue];
        if (startTime > 0.0) {
            self.playerInterface.startTime = startTime;
        }
    }
}

@end
