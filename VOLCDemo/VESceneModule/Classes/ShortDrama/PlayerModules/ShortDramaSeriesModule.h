//
//  ShortDramaSeriesModule.h
//  VEPlayModule
//
//  Created by zyw on 2024/7/16.
//

#import <Foundation/Foundation.h>
#import "VEPlayerBaseModule.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ShortDramaSeriesModuleDelegate <NSObject>

- (void)onClickSeriesViewCallback;

@end

@interface ShortDramaSeriesModule : VEPlayerBaseModule

@property (nonatomic, weak) id<ShortDramaSeriesModuleDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
