//
//  VEPlayerBaseModuleLoader.m
//  VEPlayerKit
//

#import "VEPlayerBaseModuleLoader.h"
#import "VEPlayerModuleManagerInterface.h"
#import "VEFrameScatterPerform.h"
#import "VELoopScatterPerform.h"
#import "NSArray+BTDAdditions.h"
#import "BTDMacros.h"

@interface VEPlayerBaseModuleLoader ()

@property (nonatomic, weak) id<VEPlayerModuleManagerInterface> moduleManager;

@property (nonatomic, strong) id<VEScatterPerformProtocol> scatterPerform;

@end

@implementation VEPlayerBaseModuleLoader
VEPlayerContextDILink(moduleManager, VEPlayerModuleManagerInterface, self.context);

#pragma mark - Life Cycle
- (instancetype)init {
    self = [super init];
    if (self) {
        _scatterPerform = [[VELoopScatterPerform alloc] init];
        [self configScatter];
    }
    return self;
}

- (instancetype)initWithFrameScatter:(NSInteger)framesPerSecond {
    self = [super init];
    if (self) {
        VEFrameScatterPerform *scatter = [[VEFrameScatterPerform alloc] init];
        scatter.framesPerSecond = framesPerSecond;
        _scatterPerform = scatter;
        [self configScatter];
    }
    return self;
}

- (void)moduleDidLoad {
    [super moduleDidLoad];
    NSArray *coreModules = [[self getCoreModules] copy];
    if (coreModules.count > 0) {
        [self.moduleManager addModules:coreModules];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.scatterPerform loadObjects:[self getAsyncLoadModules]];
}

- (void)moduleDidUnLoad {
    [super moduleDidUnLoad];
    [self.scatterPerform invalidate];
}

#pragma mark - Getter & Setter
- (NSInteger)loadCountPerTime {
    return self.scatterPerform.loadCountPerTime;
}

- (void)setLoadCountPerTime:(NSInteger)loadCountPerTime {
    self.scatterPerform.loadCountPerTime = loadCountPerTime;
}

- (BOOL)enableScatter {
    return self.scatterPerform.enable;
}

- (void)setEnableScatter:(BOOL)enableScatter {
    self.scatterPerform.enable = enableScatter;
}

#pragma mark - Override Method
- (NSArray<id<VEPlayerBaseModuleProtocol>> *)getCoreModules {
    return @[];
}

- (NSArray<id<VEPlayerBaseModuleProtocol>> *)getAsyncLoadModules {
    return @[];
}

#pragma mark - Public Mehtod
- (void)addModule:(id<VEPlayerBaseModuleProtocol>)module {
    if (module) {
        [self.moduleManager addModule:module];
    }
}

- (void)addModules:(NSArray<id<VEPlayerBaseModuleProtocol>> *)modules {
    [self.moduleManager addModules:modules];
}

- (void)asyncAddModule:(id<VEPlayerBaseModuleProtocol>)module {
    if (module) {
        [self.scatterPerform loadObjects:@[module]];
    }
}

- (void)asyncAddModules:(NSArray<id<VEPlayerBaseModuleProtocol>> *)modules {
    [self.scatterPerform loadObjects:modules];
}

- (void)removeModule:(id<VEPlayerBaseModuleProtocol>)module {
    if (module) {
        [self.moduleManager removeModule:module];
        if (self.removeModuleFix) {
            [self.scatterPerform removeLoadObjects:@[module]]; // 延迟队列也应该同步移除
        } else {
            [self.scatterPerform unloadObjects:@[module]];
        }
    }
}

- (void)removeModules:(NSArray<id<VEPlayerBaseModuleProtocol>> *)modules {
    [self.moduleManager removeModules:modules];
    if (self.removeModuleFix) {
        [self.scatterPerform removeLoadObjects:modules]; // 延迟队列也应该同步移除
    } else {
        [self.scatterPerform unloadObjects:modules];
    }
}

- (void)asyncRemoveModule:(id<VEPlayerBaseModuleProtocol>)module {
    if (module) {
        [self.scatterPerform unloadObjects:@[module]];
    }
}

- (void)asyncRemoveModules:(NSArray<id<VEPlayerBaseModuleProtocol>> *)modules {
    [self.scatterPerform unloadObjects:modules];
}

#pragma mark - Private Mehtod
- (void)configScatter {
    @weakify(self);
    _scatterPerform.performBlock = ^(NSArray *objects, BOOL load) {
        @strongify(self);
        objects = [objects btd_filter:^BOOL(id  _Nonnull obj) {
            if ([obj isKindOfClass:[VEPlayerBaseModule class]]) {
                return ((VEPlayerBaseModule *)obj).isLoaded != load;
            }
            return YES;
        }];
        if (BTD_isEmptyArray(objects)) {
            return;
        }
        if (load) {
            [self addModules:objects];
        } else {
            [self removeModules:objects];
        }
    };
}

@end
