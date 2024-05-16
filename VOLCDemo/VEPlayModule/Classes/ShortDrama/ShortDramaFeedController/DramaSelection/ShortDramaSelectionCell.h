//
//  ShortDramaSelectionCell.h
//  VEPlayModule
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class VEDramaVideoInfoModel;

@interface ShortDramaSelectionCell : UICollectionViewCell

@property (nonatomic, strong) VEDramaVideoInfoModel *dramaVideoInfo;
@property (nonatomic, strong) VEDramaVideoInfoModel *curPlayDramaVideoInfo;

@end

NS_ASSUME_NONNULL_END
