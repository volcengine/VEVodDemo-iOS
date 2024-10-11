//
//  ShortDramaSelectionView.h
//  VEPlayModule
//

#import <UIKit/UIKit.h>

@class VEDramaVideoInfoModel;

NS_ASSUME_NONNULL_BEGIN

#define ShortDramaSelectionViewHeight 40

@protocol ShortDramaSelectionViewDelegate <NSObject>

- (void)onClickDramaSelectionCallback;

@end

@interface ShortDramaSelectionView : UIView

@property (nonatomic, weak) id<ShortDramaSelectionViewDelegate> delegate;

- (void)showView:(BOOL)show;

- (void)reloadData:(VEDramaVideoInfoModel *)dramaVideoInfo;

@end

NS_ASSUME_NONNULL_END
