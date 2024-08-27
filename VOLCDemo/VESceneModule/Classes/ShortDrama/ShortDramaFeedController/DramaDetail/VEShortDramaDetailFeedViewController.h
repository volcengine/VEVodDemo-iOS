//
//  VEShortDramaDetailFeedViewController.h
//  VEPlayModule
//

#import <UIKit/UIKit.h>
#import "VEViewController.h"

NS_ASSUME_NONNULL_BEGIN

@class VEDramaVideoInfoModel;
@class VEDramaInfoModel;

@protocol VEShortDramaDetailFeedViewControllerDelegate <NSObject>

- (void)shortDramaDetailFeedViewWillback:(VEDramaVideoInfoModel *)dramaVideoInfo;

- (void)shortDramaDetailFeedViewWillPlayNextDrama:(VEDramaVideoInfoModel *)nextDramaVideoInfo;

@end

@protocol VEShortDramaDetailFeedViewControllerDataSource <NSObject>

- (NSString *)nextRecommondDramaIdForDramaDetailFeedPlay:(NSString *)currentDramaId;

@end

@interface VEShortDramaDetailFeedViewController : VEViewController

@property (nonatomic, weak) id<VEShortDramaDetailFeedViewControllerDelegate> delegate;

@property (nonatomic, weak) id<VEShortDramaDetailFeedViewControllerDataSource> dataSource;

@property (nonatomic, assign) BOOL autoPlayNextDaram;

- (instancetype)initWtihDramaVideoInfo:(VEDramaVideoInfoModel *)dramaVideoInfo;

- (instancetype)initWithDramaInfo:(VEDramaInfoModel *)dramaInfo;

@end

NS_ASSUME_NONNULL_END
