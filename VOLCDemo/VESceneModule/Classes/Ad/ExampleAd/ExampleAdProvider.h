//
//  ExampleAdProvider.h
//  VESceneModule
//
//  Created by litao.he on 2024/11/12.
//

#import <Foundation/Foundation.h>
#import "VEVideoModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ExampleAdProvider : NSObject

+ (instancetype)sharedInstance;

- (void)loadAdModels;

- (NSMutableArray<VEVideoModel *> *)getAdModels;

- (void)getAdModels:(BOOL)isLoadMore completion:(void (^)(NSMutableArray<VEVideoModel *> *))completion;

@end

NS_ASSUME_NONNULL_END
