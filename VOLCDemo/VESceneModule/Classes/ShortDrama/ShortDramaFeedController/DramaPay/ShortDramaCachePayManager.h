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

@property (nonatomic, assign, readonly) BOOL openPayTest;

- (BOOL)isPaidDrama:(NSString *)dramaId episodeNumber:(NSInteger)episodeNumber;

- (void)cachePaidDrama:(NSString *)dramaId episodeNumber:(NSInteger)episodeNumber;

@end

NS_ASSUME_NONNULL_END
