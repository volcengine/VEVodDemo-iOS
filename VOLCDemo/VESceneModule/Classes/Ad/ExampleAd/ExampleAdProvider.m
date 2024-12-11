//
//  ExampleAdProvider.m
//  VESceneModule
//
//  Created by litao.he on 2024/11/12.
//

#import "ExampleAdProvider.h"
#import "VEDataManager.h"
#import "VESettingManager.h"

@interface ExampleAdProvider()

@property (nonatomic, strong) NSMutableArray<VEVideoModel *> *adModels;
@property (atomic, assign) BOOL isLoadingData;
@property (nonatomic, assign) NSInteger startIndex;
@property (atomic, assign) BOOL dataLoaded;

@end

@implementation ExampleAdProvider

+ (instancetype)sharedInstance {
    static ExampleAdProvider *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (void)loadAdModels {
    if (!self.dataLoaded) {
        [self loadData:NO completion:^(NSMutableArray<VEVideoModel *> *) {
            self.dataLoaded = YES;
        }];
    }
}

- (NSMutableArray<VEVideoModel *> *)getAdModels {
    if (self.isLoadingData) {
        return nil;
    }
    return self.adModels;
}

- (void)getAdModels:(BOOL)isLoadMore completion:(void (^)(NSMutableArray<VEVideoModel *> *))completion{
    [self loadData:isLoadMore completion:completion];
}

#pragma mark ----- Data
- (void)loadData:(BOOL)isLoadMore completion:(void (^)(NSMutableArray<VEVideoModel *> *))completion {
    if (self.isLoadingData) {
        return;
    }
    self.isLoadingData = YES;

    VESettingModel *preload = [[VESettingManager universalManager] settingForKey:VESettingKeyAdPreloadCount];
    NSInteger adsPreloadCount = [[preload currentValue] integerValue];

    [VEDataManager dataForScene:VESceneTypeShortVideo range:NSMakeRange(self.startIndex, adsPreloadCount) result:^(NSArray<VEVideoModel *> *adModels) {
        if (adModels && adModels.count) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (isLoadMore) {
                    [self.adModels addObjectsFromArray:adModels];
                } else {
                    self.adModels = [adModels mutableCopy];
                }
                self.startIndex = self.adModels.count;
                self.isLoadingData = NO;
                if (completion) {
                    completion(self.adModels);
                }
            });
        } else {
            self.isLoadingData = NO;
        }
    } onError:^(NSString *errorMessage) {
        self.isLoadingData = NO;
    }];
}

@end
