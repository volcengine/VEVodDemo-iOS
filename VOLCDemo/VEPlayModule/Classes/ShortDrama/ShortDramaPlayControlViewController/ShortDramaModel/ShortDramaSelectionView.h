//
//  ShortDramaSelectionView.h
//  VEPlayModule
//

#import <UIKit/UIKit.h>
#import "VideoPlayerControlItemInterface.h"

NS_ASSUME_NONNULL_BEGIN

#define ShortDramaSelectionViewHeight 40

@protocol ShortDramaSelectionViewDelegate <NSObject>

- (void)onClickDramaSelectionCallback;

@end

@interface ShortDramaSelectionView : UIView <VideoPlayerControlItemInterface>

@property (nonatomic, weak) id<ShortDramaSelectionViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
