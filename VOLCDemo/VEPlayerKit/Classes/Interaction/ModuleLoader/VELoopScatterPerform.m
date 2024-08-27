//
//  VELoopScatterPerform.m
//  VEPlayerKit.common
//

#import "VELoopScatterPerform.h"

@interface VELoopScatterPerform()

@property (nonatomic, strong) NSMutableArray *loadQueue;

@property (nonatomic, strong) NSMutableArray *unloadQueue;

@property (nonatomic, assign) BOOL isPerforming;

@end

@implementation VELoopScatterPerform

#pragma mark - Life Cycle

- (instancetype)init {
    self = [super init];
    if (self) {
        _loadCountPerTime = 1;
        _loadQueue = [NSMutableArray array];
        _unloadQueue = [NSMutableArray array];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    }
    return self;
}

- (NSInteger)loadCountPerTime {
    return MAX(1, _loadCountPerTime);
}

#pragma mark - Public Mehtod
- (void)loadObjects:(NSArray *)objects {
    [self.unloadQueue removeObjectsInArray:objects];
    [self.loadQueue addObjectsFromArray:objects];
    [self performTaskIfNeeded];
}

- (void)unloadObjects:(NSArray *)objects {
    [self.loadQueue removeObjectsInArray:objects];
    [self.unloadQueue addObjectsFromArray:objects];
    [self performTaskIfNeeded];
}

- (void)removeLoadObjects:(NSArray *)objects {
    [self.loadQueue removeObjectsInArray:objects];
}

- (void)invalidate {
    self.performBlock = nil;
    [self cancelPerformTaskIfNeeded];
}

#pragma mark - Event Action
- (void)appDidBecomeActive:(NSNotification *)note {
    [self performTaskIfNeeded];
}

- (void)appDidEnterBackground:(NSNotification *)note {
    [self cancelPerformTaskIfNeeded];
}

#pragma mark - Private Mehtod
- (void)performTaskIfNeeded {
    if (self.isPerforming) {
        return;
    }
    BOOL shouldRun = [UIApplication sharedApplication].applicationState == UIApplicationStateActive && (self.loadQueue.count > 0 || self.unloadQueue.count > 0);
    if (shouldRun) {
        self.isPerforming = YES;
        [self performSelector:@selector(loadModuleInLoop) withObject:self afterDelay:0 inModes:@[NSDefaultRunLoopMode]];
    }
}

- (void)cancelPerformTaskIfNeeded {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    self.isPerforming = NO;
}

- (void)loadModuleInLoop {
    NSArray *objects = nil;
    BOOL load = NO;
    if (self.loadQueue.count > 0) {
        load = YES;
        if (self.loadQueue.count > self.loadCountPerTime) {
            objects = [self.loadQueue subarrayWithRange:NSMakeRange(0, self.loadCountPerTime)];
            [self.loadQueue removeObjectsInRange:NSMakeRange(0, self.loadCountPerTime)];
        } else {
            objects = [self.loadQueue copy];
            [self.loadQueue removeAllObjects];
        }
    } else if (self.unloadQueue.count > 0) {
        load = NO;
        if (self.unloadQueue.count > self.loadCountPerTime) {
            objects = [self.unloadQueue subarrayWithRange:NSMakeRange(0, self.loadCountPerTime)];
            [self.unloadQueue removeObjectsInRange:NSMakeRange(0, self.loadCountPerTime)];
        } else {
            objects = [self.unloadQueue copy];
            [self.unloadQueue removeAllObjects];
        }
    }
    if (objects && self.performBlock) {
        self.performBlock(objects, load);
    }
    self.isPerforming = NO;
    [self performTaskIfNeeded];
}

@end
