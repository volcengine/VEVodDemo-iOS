//
//  VEDramaDataManager.h
//  VEPlayModule
//

#import <Foundation/Foundation.h>
#import "VEDramaInfoModel.h"
#import "VEDramaVideoInfoModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^RequestDataComplate)(id _Nullable responseData, NSString * _Nullable errorMsg);

@interface VEDramaDataManager : NSObject

+ (void)requestDramaList:(NSInteger)offset pageSize:(NSInteger)pageSize result:(RequestDataComplate)complate;

+ (void)requestDramaRecommondList:(NSInteger)offset pageSize:(NSInteger)pageSize result:(RequestDataComplate)complate;

+ (void)requestDramaEpisodeList:(NSString *)dramaId offset:(NSInteger)offset pageSize:(NSInteger)pageSize result:(RequestDataComplate)complate;

@end

NS_ASSUME_NONNULL_END
