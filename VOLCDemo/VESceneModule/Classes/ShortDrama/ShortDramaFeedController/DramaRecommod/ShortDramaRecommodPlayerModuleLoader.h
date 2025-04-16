//
//  ShortDramaRecommodPlayerModuleLoader.h
//  VEPlayModule
//
//  Created by zyw on 2024/7/16.
//

#import <UIKit/UIKit.h>
#import "VEPlayerBaseModuleLoader.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ShortDramaRecommodPlayerModuleLoaderDelegate <NSObject>

- (void)onClickSeriesViewCallback;

@end

@interface ShortDramaRecommodPlayerModuleLoader : VEPlayerBaseModuleLoader

@property (nonatomic, weak) id<ShortDramaRecommodPlayerModuleLoaderDelegate> delegate;

- (void)setSubtitle:(NSString *)subtitle;

@end

NS_ASSUME_NONNULL_END
