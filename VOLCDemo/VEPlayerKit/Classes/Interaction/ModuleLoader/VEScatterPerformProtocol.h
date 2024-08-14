//
//  VEScatterPerformProtocol.h
//  VEPlayerKit
//

#ifndef VEScatterPerformProtocol_h
#define VEScatterPerformProtocol_h

NS_ASSUME_NONNULL_BEGIN

@protocol VEScatterPerformProtocol <NSObject>

/// The number of modules to load at once, default is 1
@property (nonatomic, assign) NSInteger loadCountPerTime;

@property (nonatomic, copy, nullable) void(^performBlock)(NSArray *objects, BOOL load);
/// enable , default no
@property (nonatomic, assign) BOOL enable;

- (void)loadObjects:(NSArray *)objects;

- (void)unloadObjects:(NSArray *)objects;

- (void)removeLoadObjects:(NSArray *)objects;

- (void)invalidate;

@end

NS_ASSUME_NONNULL_END

#endif /* VEScatterPerformProtocol_h */
