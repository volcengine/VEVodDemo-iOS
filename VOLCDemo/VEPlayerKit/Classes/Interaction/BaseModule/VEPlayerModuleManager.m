//
//  VEPlayerModuleManager.m
//  VEPlayerKit
//

#import "VEPlayerModuleManager.h"
#import "VEPlayerContext.h"
#import "VEPlayerBaseModule.h"
#import "VEDelegateMultiplexer.h"
#import "NSDictionary+BTDAdditions.h"
#import "NSArray+BTDAdditions.h"
#import "BTDMacros.h"
#import "VEPlayerContextKeyDefine.h"

@interface VEPlayerModuleManager ()

@property (nonatomic, weak) VEPlayerContext *playerContext;

@property (nonatomic, strong) VEDelegateMultiplexer *viewLifeCycleDelegate;

@property (nonatomic, strong) NSMutableDictionary<NSString *, id<VEPlayerBaseModuleProtocol>> *playerModulesDictionary;

@property (nonatomic, assign) BOOL isViewLoaded;

@property (nonatomic, assign) BOOL hasControlTemplate;

@property (nonatomic, strong) id data;

@end

@implementation VEPlayerModuleManager

#pragma mark - Life cycle
- (instancetype)initWithPlayerContext:(VEPlayerContext *)playerContext {
    if (self = [super init]) {
        _playerContext = playerContext;
    }
    return self;
}

#pragma mark - Public Mehtod
- (void)addModules:(NSArray<id<VEPlayerBaseModuleProtocol>> *)moduleObjects {
    if (BTD_isEmptyArray(moduleObjects)) {
        return;
    }
    [[[moduleObjects btd_map:^id _Nullable(id<VEPlayerBaseModuleProtocol> module) {
        if ([module conformsToProtocol:@protocol(VEPlayerBaseModuleProtocol)]) {
            module.context = self.playerContext;
            return module;
        }
        return nil;
    }] btd_map:^id _Nullable(id<VEPlayerBaseModuleProtocol> module) {
        NSString *key = NSStringFromClass(module.class);
        if (!module || BTD_isEmptyString(key)) {
            return nil;
        }
        if (self.data) {
            module.data = self.data;
        }
        [self.playerModulesDictionary btd_setObject:module forKey:key];
        [self.viewLifeCycleDelegate addDelegate:module];
        [module moduleDidLoad];
        return module;
    }] enumerateObjectsUsingBlock:^(NSObject<VEPlayerBaseModuleProtocol> *module, NSUInteger idx, BOOL * _Nonnull stop) {
        if (self.isViewLoaded && [module respondsToSelector:@selector(viewDidLoad)]) {
            [module viewDidLoad];
        }
        if (self.hasControlTemplate && [module respondsToSelector:@selector(controlViewTemplateDidUpdate)]) {
            [module controlViewTemplateDidUpdate];
        }
    }];
}

- (void)addModuleByClzz:(Class)clzz {
    NSString *key = [self getPlayerModuleKeyByClzz:clzz];
    if (BTD_isEmptyString(key)) {
        return;
    }
    id<VEPlayerBaseModuleProtocol> module = [[clzz alloc] init];
    [self addModule:module forKey:key];
}

- (void)addModule:(id<VEPlayerBaseModuleProtocol>)module {
    NSString *key = [self getPlayerModuleKeyByClzz:module.class];
    if (BTD_isEmptyString(key)) {
        return;
    }
    [self addModule:module forKey:key];
}

- (void)removeModule:(id<VEPlayerBaseModuleProtocol>)module {
    if ([module isKindOfClass:VEPlayerBaseModule.class] && ![(VEPlayerBaseModule *)module isLoaded]) {
        return;
    }
    NSString *key = [self getPlayerModuleKeyByClzz:module.class];
    if (BTD_isEmptyString(key)) {
        return;
    }
    [self removeModule:module forKey:key];
}

- (void)removeModules:(NSArray<id<VEPlayerBaseModuleProtocol>> *)modules {
    if (BTD_isEmptyArray(modules)) {
        return;
    }
    for (id<VEPlayerBaseModuleProtocol> module in modules) {
        if ([module conformsToProtocol:@protocol(VEPlayerBaseModuleProtocol)]) {
            NSString *key = NSStringFromClass(module.class);
            self.playerModulesDictionary[key] = nil;
            [self.viewLifeCycleDelegate removeDelegate:module];
            [module moduleDidUnLoad];
            module.context = nil;
        }
    }
}

- (void)removeModuleByClzz:(Class)clzz {
    NSString *key = [self getPlayerModuleKeyByClzz:clzz];
    if (BTD_isEmptyString(key)) {
        return;
    }
    [self removeModule:nil forKey:key];
}

- (void)removeAllModules {
    for (NSString *key in [self.playerModulesDictionary allKeys]) {
        id<VEPlayerBaseModuleProtocol> baseModule = [self.playerModulesDictionary objectForKey:key];
        if (baseModule) {
            [self removeModule:baseModule forKey:key];
        }
    }
    [_playerModulesDictionary removeAllObjects];
    self.viewLifeCycleDelegate = nil;
}

- (id<VEPlayerBaseModuleProtocol>)moduleByClzz:(Class)clzz {
    NSString *key = [self getPlayerModuleKeyByClzz:clzz];
    if (BTD_isEmptyString(key)) {
        return nil;
    }
    return [_playerModulesDictionary btd_objectForKey:key default:nil];
}

- (NSArray<id<VEPlayerBaseModuleProtocol>> *)allModules {
    return _playerModulesDictionary.allValues;
}

- (void)addModulesByClzzArray:(NSArray<Class> *)clzzArray {
    if (BTD_isEmptyArray(clzzArray)) {
        return;
    }
    [[[clzzArray btd_map:^id _Nullable(Class  _Nonnull clazz) {
        id<VEPlayerBaseModuleProtocol> module = [[clazz alloc] init];
        if ([module conformsToProtocol:@protocol(VEPlayerBaseModuleProtocol)]) {
            module.context = self.playerContext;
            return module;
        } else {
            return nil;
        }
    }] btd_map:^id _Nullable(id<VEPlayerBaseModuleProtocol>  _Nonnull module) {
        NSString *key = NSStringFromClass(module.class);
        if (!module || BTD_isEmptyString(key)) {
            return nil;
        }
        if (self.data) {
            module.data = self.data;
        }
        [self.playerModulesDictionary btd_setObject:module forKey:key];
        [self.viewLifeCycleDelegate addDelegate:module];
        [module moduleDidLoad];
        return module;
    }] enumerateObjectsUsingBlock:^(id<VEPlayerBaseModuleProtocol> _Nonnull module, NSUInteger idx, BOOL * _Nonnull stop) {
        if (self.isViewLoaded && [module respondsToSelector:@selector(viewDidLoad)]) {
            [module viewDidLoad];
        }
        if (self.hasControlTemplate && [module respondsToSelector:@selector(controlViewTemplateDidUpdate)]) {
            [module controlViewTemplateDidUpdate];
        }
    }];
}

- (void)setupData:(id)data {
    self.data = data;
    [self.playerModulesDictionary.allValues enumerateObjectsUsingBlock:^(id<VEPlayerBaseModuleProtocol>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.data = data;
    }];
}

#pragma mark - Protocol Mehtod
#pragma mark -- VEPlayerViewLifeCycleProtocol Delegate

- (void)viewDidLoad {
    self.isViewLoaded = YES;
    [((id<VEPlayerBaseModuleProtocol>)self.viewLifeCycleDelegate) viewDidLoad];
}

- (void)controlViewTemplateDidUpdate {
    self.hasControlTemplate = YES;
    [((id<VEPlayerBaseModuleProtocol>)self.viewLifeCycleDelegate) controlViewTemplateDidUpdate];
    [self.playerContext post:nil forKey:VEPlayerContextKeyControlTemplateChanged];
}
#pragma mark - Private Mehtod
- (NSString *)getPlayerModuleKeyByClzz:(Class)clzz {
    NSString *key = NSStringFromClass(clzz);
    if (BTD_isEmptyString(key)) {
        return nil;
    } else {
        return key;
    }
}

- (void)addModule:(id<VEPlayerBaseModuleProtocol>)module forKey:(NSString *)key {
    if (!module || ![module conformsToProtocol:@protocol(VEPlayerBaseModuleProtocol)] || BTD_isEmptyString(key)) {
        return;
    }
    if (self.data) {
        module.data = self.data;
    }
    [self.playerModulesDictionary btd_setObject:module forKey:key];
    module.context = self.playerContext;
    [self.viewLifeCycleDelegate addDelegate:module];
    [module moduleDidLoad];
    if (self.isViewLoaded && [module respondsToSelector:@selector(viewDidLoad)]) {
        [module viewDidLoad];
    }
    if (self.hasControlTemplate && [module respondsToSelector:@selector(controlViewTemplateDidUpdate)]) {
        [module controlViewTemplateDidUpdate];
    }
}

- (void)removeModule:(id<VEPlayerBaseModuleProtocol>)module forKey:(NSString *)key {
    module = module ? module : [_playerModulesDictionary btd_objectForKey:key default:nil];
    [_playerModulesDictionary removeObjectForKey:key];
    [_viewLifeCycleDelegate removeDelegate:module];
    [module moduleDidUnLoad];
}

#pragma mark - Setter & Getter

- (NSMutableDictionary<NSString *,id<VEPlayerBaseModuleProtocol> > *)playerModulesDictionary {
    if (!_playerModulesDictionary) {
        _playerModulesDictionary = [NSMutableDictionary dictionary];
    }
    return _playerModulesDictionary;
}

- (VEDelegateMultiplexer *)viewLifeCycleDelegate {
    if (!_viewLifeCycleDelegate) {
        _viewLifeCycleDelegate = [[VEDelegateMultiplexer alloc] initWithProtocol:@protocol(VEPlayerBaseModuleProtocol)];
    }
    return _viewLifeCycleDelegate;
}

@end
