//
//  VEPlayerLoadingModule.h
//  VEPlayerKit
//

#import "VEPlayerBaseModule.h"

NS_ASSUME_NONNULL_BEGIN

@protocol VEPlayerLoadingViewProtocol;

@interface VEPlayerLoadingModule : VEPlayerBaseModule

@property (nonatomic, strong, readonly, nullable) UIView<VEPlayerLoadingViewProtocol> *loadingView;

- (UIView<VEPlayerLoadingViewProtocol> *)createLoadingView;

@end

NS_ASSUME_NONNULL_END
