//
//  ShortDramaSeriesView.h
//  JSONModel
//

#import <UIKit/UIKit.h>
#import "VideoPlayerControlItemInterface.h"

NS_ASSUME_NONNULL_BEGIN

#define ShortDramaSeriesViewHeight 48

@protocol ShortDramaSeriesViewDelegate <NSObject>

- (void)onClickDramaCallback;

@end

@interface ShortDramaSeriesView : UIView <VideoPlayerControlItemInterface>

@property (nonatomic, weak) id<ShortDramaSeriesViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
