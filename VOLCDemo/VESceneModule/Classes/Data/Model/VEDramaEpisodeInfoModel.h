//
//  VEDramaEpisodeInfoModel.h
//  VEPlayModule
//

#import <Foundation/Foundation.h>
#import "VEDramaInfoModel.h"
#import <JSONModel/JSONModel.h>

NS_ASSUME_NONNULL_BEGIN

@interface VEDramaEpisodeInfoModel : JSONModel

@property (nonatomic, assign) NSInteger episodeNumber;
@property (nonatomic, copy) NSString *episodeDesc;
@property (nonatomic, strong) VEDramaInfoModel *dramaInfo;

@end

NS_ASSUME_NONNULL_END
