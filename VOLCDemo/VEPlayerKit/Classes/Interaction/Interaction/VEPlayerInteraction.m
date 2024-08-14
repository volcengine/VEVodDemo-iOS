//
//  VEPlayerInteraction.m
//  VEPlayerKit
//

#import "VEPlayerInteraction.h"
#import "VEPlayerContext.h"
#import "VEPlayerModuleManager.h"
#import "VEPlayerGestureService.h"
#import "VEPlayerViewService.h"

@interface VEPlayerInteraction ()

@property (nonatomic, weak) VEPlayerContext *context;

@property (nonatomic, strong) VEPlayerModuleManager *playerModuleManager;

@property (nonatomic, strong) VEPlayerViewService *playerViewService;

@property (nonatomic, strong) VEPlayerGestureService *gestureService;

@end

@implementation VEPlayerInteraction

#pragma mark - Class Method
#pragma mark - Life cycle

- (instancetype)initWithContext:(VEPlayerContext *)context {
    self = [super init];
    if (self) {
        _context = context;
        _playerModuleManager = [[VEPlayerModuleManager alloc] initWithPlayerContext:context];
        VEPlayerContextDIBind(_playerModuleManager, VEPlayerModuleManagerInterface, self.context);
        
        _gestureService = [[VEPlayerGestureService alloc] init];
        VEPlayerContextDIBind(_gestureService, VEPlayerGestureServiceInterface, self.context);
        
        _playerViewService = [[VEPlayerViewService alloc] init];
        _playerViewService.moduleManager = _playerModuleManager;
        VEPlayerContextDIBind(_playerViewService, VEPlayerActionViewInterface, self.context);
    }
    return self;
}

#pragma mark - Public Mehtod

#pragma mark - VEPlayerInteractionPlayerProtocol Mehtod
#pragma mark --VEPlayerViewLifeCycleProtocol Mehtod

- (void)viewDidLoad {
    NSAssert(self.playerVCView != nil, @"playerVCView is nil.");
    self.playerViewService.actionView.frame = self.playerVCView.bounds;
    self.playerViewService.actionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.playerVCView addSubview:self.playerViewService.actionView];
    self.gestureService.gestureView = self.playerViewService.actionView;
    self.playerViewService.playerContainerView = self.playerContainerView;
    
    [self.playerModuleManager viewDidLoad];
}

- (void)controlViewTemplateDidUpdate {
    [self.playerModuleManager controlViewTemplateDidUpdate];
}

#pragma mark --VEPlayerModuleManagerInterface Mehtod
- (void)addModule:(id<VEPlayerBaseModuleProtocol>)module {
    [self.playerModuleManager addModule:module];
}

- (void)addModuleByClzz:(nonnull Class)clzz {
    [self.playerModuleManager addModuleByClzz:clzz];
}

- (void)addModules:(NSArray<id<VEPlayerBaseModuleProtocol>> *)modules {
    [self.playerModuleManager addModules:modules];
}

- (void)removeModules:(NSArray<id<VEPlayerBaseModuleProtocol>> *)modules {
    [self.playerModuleManager removeModules:modules];
}

- (void)addModulesByClzzArray:(nonnull NSArray<Class> *)clzzArray {
    [self.playerModuleManager addModulesByClzzArray:clzzArray];
}

- (void)removeAllModules {
    [self.playerModuleManager removeAllModules];
}

- (void)removeModule:(id<VEPlayerBaseModuleProtocol>)module {
    [self.playerModuleManager removeModule:module];
}

- (void)removeModuleByClzz:(nonnull Class)clzz {
    [self.playerModuleManager removeModuleByClzz:clzz];
}

- (void)setupData:(nonnull id)data {
    [self.playerModuleManager setupData:data];
}

@end
