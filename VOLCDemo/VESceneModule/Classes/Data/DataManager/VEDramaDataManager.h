//
//  VEDramaDataManager.h
//  VEPlayModule
//

#import <Foundation/Foundation.h>
#import "VEDramaInfoModel.h"
#import "VEDramaVideoInfoModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^RequestDataComplete)(id _Nullable responseData, NSString * _Nullable errorMsg);

@interface VEDramaDataManager : NSObject

+ (void)requestDramaList:(NSInteger)offset pageSize:(NSInteger)pageSize result:(RequestDataComplete)complete;

+ (void)requestDramaRecommondList:(NSInteger)offset pageSize:(NSInteger)pageSize result:(RequestDataComplete)complete;

+ (void)requestDramaEpisodeList:(NSString *)dramaId episodeNumber:(NSInteger)episodeNumber offset:(NSInteger)offset pageSize:(NSInteger)pageSize result:(RequestDataComplete)complete;

@end

NS_ASSUME_NONNULL_END
