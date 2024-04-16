//
//  VEDramaInfoModel.h
//  VEPlayModule
//

#import <Foundation/Foundation.h>
#import <JSONModel/JSONModel.h>

NS_ASSUME_NONNULL_BEGIN

@interface VEDramaInfoModel : JSONModel

@property (nonatomic, copy) NSString *dramaId;
@property (nonatomic, copy) NSString *dramaTitle;
@property (nonatomic, copy) NSString *dramaDes;
@property (nonatomic, copy) NSString *coverUrl;
@property (nonatomic, copy) NSString *authorId;

@property (nonatomic, assign) NSInteger latestEpisodeNumber;
@property (nonatomic, assign) NSInteger totalEpisodeNumber;

@end

NS_ASSUME_NONNULL_END
