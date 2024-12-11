//
//  VEAdsInfoModel.m
//  VESceneModule
//
//  Created by litao.he on 2024/11/7.
//

#import "VEAdInfoModel.h"

@implementation VEAdInfoModel

- (instancetype)initByUniqueId:(NSString* _Nonnull)uniqueId {
    self = [super init];
    if (self) {
        _uniqueId = uniqueId;
    }
    return self;
}

@end
