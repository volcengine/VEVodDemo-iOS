//
//  ShortDramaDetailPlayerModuleLoader.h
//  ModularPlayerDemo
//

#import <Foundation/Foundation.h>
#import "VEPlayerBaseModuleLoader.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ShortDramaDetailPlayerModuleLoaderDelegate <NSObject>

- (void)onClickDramaSelectionCallback;

@end

@interface ShortDramaDetailPlayerModuleLoader : VEPlayerBaseModuleLoader

@property (nonatomic, weak) id<ShortDramaDetailPlayerModuleLoaderDelegate> delegate;

- (void)setSubtitle:(NSString *)subtitle;

@end

NS_ASSUME_NONNULL_END
