//
//  VEDramaVideoInfoModel.h
//  VEPlayModule
//

#import <Foundation/Foundation.h>
#import "VEDramaEpisodeInfoModel.h"
#import "VEDramaPayInfoModel.h"
#import <JSONModel/JSONModel.h>
#import "TTVideoEngineSourceCategory.h"

NS_ASSUME_NONNULL_BEGIN

@interface VEDramaItemModel : JSONModel

@property (nonatomic, nullable, copy) NSString *playUrl;

@property (nonatomic, nullable, copy) NSString *fileId;

@end


@interface VEDramaVideoModel : JSONModel

@property (nonatomic, nullable, strong) NSArray<VEDramaItemModel *> *urlList;

@end

@interface VEDramaVideoInfoModel : JSONModel

@property (nonatomic, nullable, copy) NSString *title;
@property (nonatomic, nullable, copy) NSString *videoId;
@property (nonatomic, nullable, copy) NSString *coverUrl;
@property (nonatomic, assign) CGFloat duration;
@property (nonatomic, nullable, copy) NSString *playAuthToken;
@property (nonatomic, nullable, copy) NSString *subtitleAuthToken;
@property (nonatomic, strong) VEDramaEpisodeInfoModel *dramaEpisodeInfo;
@property (nonatomic, strong) VEDramaPayInfoModel *payInfo;
@property (nonatomic, nullable, strong) NSDictionary *subtitleInfoDict;
@property (nonatomic, nullable, strong) VEDramaVideoModel *videoModel;

// client property
@property (nonatomic, assign) CGFloat startTime;

+ (id<TTVideoEngineMediaSource>_Nullable)toVideoEngineSource:(VEDramaVideoInfoModel *_Nullable)dramaVideoModel;
+ (id<TTVideoEngineMediaSource>_Nullable)toVideoEngineSource:(VEDramaVideoInfoModel *_Nullable)dramaVideoModel forPreloadStrategy:(BOOL)forPreloadStrategy;

@end

NS_ASSUME_NONNULL_END
