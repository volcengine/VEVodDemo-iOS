//
//  VEPlayerSeekProgressView.h
//  VEPlayModule
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol VEPlayerSeekProgressViewProtocol <NSObject>

- (void)showView:(BOOL)show;

- (void)updateProgress:(NSInteger)playbackTime duration:(NSInteger)duration;

@end

@interface VEPlayerSeekProgressView : UIView <VEPlayerSeekProgressViewProtocol>


@end

NS_ASSUME_NONNULL_END
