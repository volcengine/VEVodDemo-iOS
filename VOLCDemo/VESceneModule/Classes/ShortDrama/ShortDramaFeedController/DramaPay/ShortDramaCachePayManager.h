//
//  ShortDramaCachePayManager.h
//  VEPlayModule
//
//  Created by zyw on 2024/7/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ShortDramaCachePayManager : NSObject

+ (ShortDramaCachePayManager *)shareInstance;

- (BOOL)isPaidDrama:(NSString *)dramaId;

- (void)cachePaidDrama:(NSString *)dramaId;

@end

NS_ASSUME_NONNULL_END
