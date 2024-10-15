//
//  ShortDramaIntroduceView.h
//  JSONModel
//

#import <UIKit/UIKit.h>

@class VEDramaVideoInfoModel;

NS_ASSUME_NONNULL_BEGIN

#define ShortDramaIntroduceViewHeight 70

@interface ShortDramaIntroduceView : UIView

- (void)showView:(BOOL)show;

- (void)reloadData:(VEDramaVideoInfoModel *)dramaVideoInfo;

@end

NS_ASSUME_NONNULL_END
