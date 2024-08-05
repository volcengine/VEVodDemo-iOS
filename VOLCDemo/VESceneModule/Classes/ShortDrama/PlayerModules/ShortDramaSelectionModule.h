//
//  ShortDramaSelectionModule.h
//  VEPlayModule
//
//  Created by zyw on 2024/7/15.
//

#import <Foundation/Foundation.h>
#import "VEPlayerBaseModule.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ShortDramaSelectionModuleDelegate <NSObject>

- (void)onClickDramaSelectionCallback;

@end

@interface ShortDramaSelectionModule : VEPlayerBaseModule

@property (nonatomic, weak) id<ShortDramaSelectionModuleDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
