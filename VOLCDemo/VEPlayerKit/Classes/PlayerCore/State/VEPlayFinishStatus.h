//
//  VEPlayFinishStatus.h
//  VEPlayerKit
//

#import <Foundation/Foundation.h>
#import "VEVideoPlaybackDefine.h"

NS_ASSUME_NONNULL_BEGIN


@interface VEPlayFinishStatus : NSObject

@property (nonatomic, assign) VEVideoPlayFinishStatusType finishState;
@property (nonatomic, strong) NSError * _Nullable error;

- (BOOL)playerFinishedSuccess;

@end

NS_ASSUME_NONNULL_END
