//
//  ShortDramaCachePayManager.m
//  VEPlayModule
//
//  Created by zyw on 2024/7/24.
//

#import "ShortDramaCachePayManager.h"

@interface ShortDramaCachePayManager ()

@property (nonatomic, assign) BOOL openPayTest;
@property (nonatomic, strong) NSMutableDictionary *cahcePaidDramaDic;

@end

@implementation ShortDramaCachePayManager

+ (ShortDramaCachePayManager *)shareInstance {
    static ShortDramaCachePayManager *dramaPayManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (dramaPayManager == nil) {
            dramaPayManager = [[ShortDramaCachePayManager alloc] init];
        }
    });
    return dramaPayManager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _openPayTest = YES;
        _cahcePaidDramaDic = [NSMutableDictionary dictionary];
    }
    return self;
}

- (BOOL)isPaidDrama:(NSString *)dramaId {
    if (dramaId && self.openPayTest) {
        return [[self.cahcePaidDramaDic objectForKey:dramaId] boolValue];
    }
    return YES;
}

- (void)cachePaidDrama:(NSString *)dramaId {
    if (dramaId) {
        [self.cahcePaidDramaDic setObject:@(YES) forKey:dramaId];
    }
}

@end
