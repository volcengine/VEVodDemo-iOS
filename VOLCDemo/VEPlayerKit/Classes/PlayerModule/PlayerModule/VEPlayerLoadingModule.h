//
//  VEPlayerLoadingModule.h
//  VEPlayerKit
//

#import "VEPlayerBaseModule.h"

NS_ASSUME_NONNULL_BEGIN

@protocol TTVPlayerLoadingViewProtocol;

@interface VEPlayerLoadingModule : VEPlayerBaseModule

@property (nonatomic, strong, readonly, nullable) UIView<TTVPlayerLoadingViewProtocol> *loadingView;

- (UIView<TTVPlayerLoadingViewProtocol> *)createLoadingView;

@end

NS_ASSUME_NONNULL_END
