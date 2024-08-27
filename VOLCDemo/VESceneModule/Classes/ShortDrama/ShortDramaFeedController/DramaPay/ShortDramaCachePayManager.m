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

- (BOOL)isPaidDrama:(NSString *)dramaId episodeNumber:(NSInteger)episodeNumber {
    if (dramaId && self.openPayTest) {
        NSDictionary *dic = [self.cahcePaidDramaDic objectForKey:dramaId];
        if (dic) {
            bool ret = [[dic objectForKey:@(episodeNumber)] boolValue];
            return ret;
        }
    }
    return NO;
}

- (void)cachePaidDrama:(NSString *)dramaId episodeNumber:(NSInteger)episodeNumber {
    @synchronized (self) {
        if (dramaId) {
            NSDictionary *dic = [self.cahcePaidDramaDic objectForKey:dramaId];
            if (dic) {
                bool ret = [[dic objectForKey:@(episodeNumber)] boolValue];
                if (!ret) {
                    NSMutableDictionary *tempDic = [NSMutableDictionary dictionaryWithDictionary:dic];
                    [tempDic setObject:@(YES) forKey:@(episodeNumber)];
                    [self.cahcePaidDramaDic setObject:tempDic.copy forKey:dramaId];
                }
            } else {
                dic = @{ dramaId: @{ @(episodeNumber) : @(YES) } };
                self.cahcePaidDramaDic = [dic mutableCopy];
            }
        }
    }
}

@end
