//
//  VEFrameScatterPerform.m
//  VEPlayerKit.common
//

#import "VEFrameScatterPerform.h"

@interface VEFrameScatterPerform()

@property (nonatomic, strong) NSMutableArray *loadQueue;

@property (nonatomic, strong) NSMutableArray *unloadQueue;

@property (nonatomic, strong) CADisplayLink *displayLink;

@end

@implementation VEFrameScatterPerform

#pragma mark - Life Cycle
- (void)dealloc {
    if (_displayLink) {
        [_displayLink invalidate];
        _displayLink = nil;
    }
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _framesPerSecond = 60;
        _loadCountPerTime = 1;
        _enable = NO;
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

- (void)setEnable:(BOOL)enable {
    if (_enable != enable) {
        _enable = enable;
        [self updateDisplayLinkState];
    }
}

#pragma mark - Public Mehtod
- (void)loadObjects:(NSArray *)objects {
    [self.unloadQueue removeObjectsInArray:objects];
    [self.loadQueue addObjectsFromArray:objects];
    [self updateDisplayLinkState];
}

- (void)unloadObjects:(NSArray *)objects {
    [self.loadQueue removeObjectsInArray:objects];
    [self.unloadQueue addObjectsFromArray:objects];
    [self updateDisplayLinkState];
}

- (void)removeLoadObjects:(NSArray *)objects {
    [self.loadQueue removeObjectsInArray:objects];
}

- (void)invalidate {
    if (_displayLink) {
        [_displayLink invalidate];
        _displayLink = nil;
    }
    self.performBlock = nil;
}

#pragma mark - Event Action
- (void)appDidBecomeActive:(NSNotification *)note {
    [self updateDisplayLinkState];
}

- (void)appDidEnterBackground:(NSNotification *)note {
    [self updateDisplayLinkState];
}

#pragma mark - Private Mehtod
- (void)updateDisplayLinkState {
    BOOL shouldRun = self.enable && [UIApplication sharedApplication].applicationState == UIApplicationStateActive && (self.loadQueue.count > 0 || self.unloadQueue.count > 0);
    if (shouldRun) {
        self.displayLink.paused = NO;
    } else {
        _displayLink.paused = YES;
    }
}

- (void)displayLinkSelector {
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
    [self updateDisplayLinkState];
}

#pragma mark - Setter & Getter
- (CADisplayLink *)displayLink {
    if (!_displayLink) {
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkSelector)];
        _displayLink.preferredFramesPerSecond = _framesPerSecond;
        [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
        _displayLink.paused = YES;
    }
    return _displayLink;
}

@end
