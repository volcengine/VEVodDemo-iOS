//
//  VEDramaVideoInfoModel.h
//  VEPlayModule
//

#import <Foundation/Foundation.h>
#import "VEDramaEpisodeInfoModel.h"
#import <JSONModel/JSONModel.h>
#import "TTVideoEngineSourceCategory.h"

NS_ASSUME_NONNULL_BEGIN

@interface VEDramaVideoInfoModel : JSONModel

@property (nonatomic, nullable, copy) NSString *title;
@property (nonatomic, nullable, copy) NSString *videoId;
@property (nonatomic, nullable, copy) NSString *coverUrl;
@property (nonatomic, assign) CGFloat duration;
@property (nonatomic, nullable, copy) NSString *playAuthToken;
@property (nonatomic, nullable, copy) NSString *subtitleAuthToken;
@property (nonatomic, strong) VEDramaEpisodeInfoModel *dramaEpisodeInfo;

// client property
@property (nonatomic, assign) CGFloat startTime;

+ (id<TTVideoEngineMediaSource>_Nullable)toVideoEngineSource:(VEDramaVideoInfoModel *_Nullable)dramaVideoModel;

@end

NS_ASSUME_NONNULL_END
