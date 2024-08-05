//
//  ShortDramaSeriesView.h
//  JSONModel
//

#import <UIKit/UIKit.h>

@class VEDramaVideoInfoModel;

NS_ASSUME_NONNULL_BEGIN

#define ShortDramaSeriesViewHeight 48

@protocol ShortDramaSeriesViewDelegate <NSObject>

- (void)onClickSeriesViewCallback;

@end

@interface ShortDramaSeriesView : UIView

@property (nonatomic, weak) id<ShortDramaSeriesViewDelegate> delegate;

- (void)reloadData:(VEDramaVideoInfoModel *)dramaVideoInfo;

@end

NS_ASSUME_NONNULL_END
