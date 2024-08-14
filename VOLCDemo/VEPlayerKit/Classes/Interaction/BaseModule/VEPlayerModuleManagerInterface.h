//
//  VEPlayerModuleManagerInterface.h
//  VEPlayerKit
//

#import <Foundation/Foundation.h>
#import "VEPlayerBaseModuleProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@protocol VEPlayerModuleManagerInterface <NSObject>

- (void)addModule:(id<VEPlayerBaseModuleProtocol>)module;

- (void)removeModule:(id<VEPlayerBaseModuleProtocol>)module;

- (void)addModules:(NSArray<id<VEPlayerBaseModuleProtocol>> *)modules;

- (void)removeModules:(NSArray<id<VEPlayerBaseModuleProtocol>> *)modules;

- (void)addModuleByClzz:(Class)clzz;

- (void)addModulesByClzzArray:(NSArray<Class> *)clzzArray;

- (void)removeModuleByClzz:(Class)clzz;

- (void)removeAllModules;

- (void)setupData:(id)data;

@end

NS_ASSUME_NONNULL_END
