//
//  VEInterfaceBridge.h
//  VEPlayerUIModule
//
//  Created by real on 2021/9/15.
//

@protocol VEPlayInfoProtocol <NSObject>

@required
- (NSInteger)currentPlaybackState;
 
- (NSTimeInterval)duration;

- (NSTimeInterval)playableDuration;

- (NSString *)title;
    
- (BOOL)loopPlayOpen;

- (CGFloat)currentPlaySpeed;

- (NSString *)currentPlaySpeedForDisplay;

- (NSArray *)playSpeedSet;

- (NSInteger)currentResolution;

- (NSArray *)resolutionSet;

- (NSString *)currentResolutionForDisplay;

- (CGFloat)currentVolume;

- (CGFloat)currentBrightness;

@end

@interface VEInterfaceBridge : NSObject <VEPlayInfoProtocol>

+ (instancetype)bridge;

+ (void)destroyUnit;

@end
