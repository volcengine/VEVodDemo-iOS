//
//  VEPlayerContextDI.m
//  VEPlayerKit
//

#import "VEPlayerContextDI.h"
#import "VEPlayerContextStorage.h"
#import "BTDMacros.h"

@interface VEPlayerContextDI ()

@property (nonatomic, weak) id owner;

@property (nonatomic, copy) NSString *ownerServiceKey;

@property (nonatomic, strong) VEPlayerContextStorage *diStorage;

@end

@implementation VEPlayerContextDI

- (void)bindOwner:(id)owner withProtocol:(Protocol *)protocol {
    self.owner = owner;
    if (protocol) {
        self.ownerServiceKey = NSStringFromProtocol(protocol);
    } else {
        self.ownerServiceKey = nil;
    }
}

- (id)serviceForKey:(NSString *)key {
    if (BTD_isEmptyString(key)) {
        NSAssert(NO, @"player context di key is null");
        return nil;
    }
    BTDAssertMainThread();
    if ([NSThread isMainThread]) {
        if (self.owner && [self.ownerServiceKey isEqualToString:key]) {
            return self.owner;
        }
        return [self.diStorage objectForKey:key];
    } else {
        return nil;
    }
}

- (id)serviceForKey:(NSString *)key creator:(VEPlayerContextObjectCreator)creator {
    if (BTD_isEmptyString(key)) {
        NSAssert(NO, @"player context di key is null");
        return nil;
    }
    BTDAssertMainThread();
    if ([NSThread isMainThread]) {
        return [self.diStorage objectForKey:key creator:creator];
    } else {
        return nil;
    }
}

- (void)setService:(id)object forKey:(NSString *)key {
    if (BTD_isEmptyString(key)) {
        NSAssert(NO, @"player context di key is null");
        return;
    }
    BTDAssertMainThread();
    VEPlayerContextRunOnMainThread(^{
        [self.diStorage setObject:object forKey:key];
    });
}

- (void)removeServiceForKey:(NSString *)key {
    if (BTD_isEmptyString(key)) {
        NSAssert(NO, @"player context di key is null");
        return;
    }
    BTDAssertMainThread();
    VEPlayerContextRunOnMainThread(^{
        [self.diStorage removeObjectForKey:key];
    });
}

#pragma mark - Setter & Getter
- (VEPlayerContextStorage *)diStorage {
    if (!_diStorage) {
        _diStorage = [[VEPlayerContextStorage alloc] init];
    }
    return _diStorage;
}

@end
