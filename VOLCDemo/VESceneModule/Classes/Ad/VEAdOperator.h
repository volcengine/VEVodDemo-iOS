//
//  VEAdsProvider.h
//  VESceneModule
//
//  Created by litao.he on 2024/11/6.
//

#import <Foundation/Foundation.h>
#import "VEPageViewController.h"

@protocol VEAdManagerDelegate;

@interface VEAdOperator : NSObject

- (NSInteger)insertAdsItems:(NSMutableArray<id> *)mediaModels fromIndex:(NSInteger)startIndex;

@property (nonatomic, weak) id<VEAdManagerDelegate> delegate;

@end
