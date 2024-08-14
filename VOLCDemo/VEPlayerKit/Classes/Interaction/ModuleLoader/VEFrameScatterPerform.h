//
//  VEFrameScatterPerform.h
//  VEPlayerKit.common
//


#import <Foundation/Foundation.h>
#import "VEScatterPerformProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface VEFrameScatterPerform : NSObject <VEScatterPerformProtocol>

@property (nonatomic, assign) NSInteger framesPerSecond;
@property (nonatomic, assign) NSInteger loadCountPerTime;

@property (nonatomic, copy, nullable) void(^performBlock)(NSArray *objects, BOOL load);
@property (nonatomic, assign) BOOL enable;

- (void)loadObjects:(NSArray *)objects;

- (void)unloadObjects:(NSArray *)objects;

- (void)invalidate;

@end

NS_ASSUME_NONNULL_END
