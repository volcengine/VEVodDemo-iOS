//
//  ExampleAdPlayerModuleLoader.m
//  VESceneModule
//
//  Created by litao.he on 2024/11/7.
//

#import "ExampleAdPlayerModuleLoader.h"
#import "VEPlayerLoadingModule.h"
#import "ExampleAdPlayButtonModule.h"
#import "ExampleAdLabelModule.h"
#import "ExampleAdDetailModule.h"

@interface ExampleAdPlayerModuleLoader()

@property(nonatomic, assign) NSInteger hostSceneType;

@end

@implementation ExampleAdPlayerModuleLoader

- (instancetype)initWithSceneType:(NSInteger)sceneType {
    self = [super init];
    if (self) {
        self.hostSceneType = sceneType;
    }
    return self;
}

- (NSArray<id<VEPlayerBaseModuleProtocol>> *)getCoreModules {
    NSMutableArray *coreModules = [NSMutableArray array];
    [coreModules addObject:[VEPlayerLoadingModule new]];
    [coreModules addObject:[ExampleAdPlayButtonModule new]];
    if (self.hostSceneType == 1) {
        [coreModules addObject:[ExampleAdLabelModule new]];
    }
    [coreModules addObject:[ExampleAdDetailModule new]];

    return coreModules;
}

@end
