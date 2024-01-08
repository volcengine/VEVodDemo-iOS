//
//  VEEventMessageBus.m
//  VEPlayerUIModule
//
//  Created by real on 2021/9/7.
//

#import "VEEventMessageBus.h"

@interface VEEventMessageBus ()

@property (nonatomic, strong) NSMutableDictionary *targetActionMaps;

@property (nonatomic, strong) dispatch_queue_t concurrentTaskQ;

@property (nonatomic, weak) dispatch_queue_t seriesTaskQ;

@end

@implementation VEEventMessageBus

static id sharedInstance = nil;
+ (instancetype)universalBus {
    if (!sharedInstance) {
        sharedInstance = [[self alloc] init];
    }
    return sharedInstance;
}


#pragma mark ----- Variable Getter & Setter

- (dispatch_queue_t)seriesTaskQ {
    return dispatch_get_main_queue();
}

- (dispatch_queue_t)concurrentTaskQ {
    return nil;
}

- (NSMutableDictionary *)targetActionMaps {
    if (!_targetActionMaps) {
        _targetActionMaps = [NSMutableDictionary dictionary];
    }
    return _targetActionMaps;
}

#pragma mark ----- Function

- (void)postEvent:(NSString *)eventKey withObject:(id)object rightNow:(BOOL)now {
    [self __postEvent:eventKey withObject:object rightNow:now];
}

- (void)registEvent:(NSString *)eventKey withAction:(SEL)selector ofTarget:(id)target {
    [self __registEvent:eventKey withAction:selector ofTarget:target inArea:self.targetActionMaps];
}


#pragma mark ----- Universal Method

- (void)__postEvent:(NSString *)eventKey withObject:(id)object rightNow:(BOOL)now {
    if (now) {
        // dispatch main q
    } else {
        // concurrent q
    }
    [self __checkEvent:eventKey withObject:object inArea:self.targetActionMaps];
}

- (void)__checkEvent:(NSString *)eventKey withObject:(id)object inArea:(NSDictionary *)maps {
    NSArray *targetActions = [maps objectForKey:eventKey];
    if ([targetActions isKindOfClass:[NSArray class]]) {
        for (NSDictionary *aTargetAction in targetActions) {
            NSString *selectorName = aTargetAction.allKeys.firstObject;
            id target = aTargetAction.allValues.firstObject;
            SEL sel = NSSelectorFromString(selectorName);
            if ([target respondsToSelector:sel]) {
                @autoreleasepool {
                    IMP imp = [target methodForSelector:sel];
                    void (*func)(id, SEL, id) = (void *)imp;
                    if (!object) object = @"";
                    func(target, sel, @{eventKey: object});
                }
            }
        }
    }
}

- (void)__registEvent:(NSString *)eventKey withAction:(SEL)selector ofTarget:(id)target inArea:(NSMutableDictionary *)maps {
    __weak id avatarTarget = target;
    NSDictionary *aTargetAction = @{NSStringFromSelector(selector) : avatarTarget};
    NSMutableArray *targetActions = [maps objectForKey:eventKey];
    if (![targetActions isKindOfClass:[NSMutableArray class]]) {
        targetActions = [NSMutableArray array];
        [maps setObject:targetActions forKey:eventKey];
    }
    [targetActions addObject:aTargetAction];
}

+ (void)destroyUnit {
    @autoreleasepool {
        NSMutableDictionary *actionMaps = [sharedInstance valueForKeyPath:@"targetActionMaps"];
        [actionMaps removeAllObjects];
        sharedInstance = nil;
    }
}

@end
