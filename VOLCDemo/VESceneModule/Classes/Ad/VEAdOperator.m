//
//  VEAdsProvider.m
//  VESceneModule
//
//  Created by litao.he on 2024/11/6.
//

#import "VEAdOperator.h"
#import "VEAdCellController.h"
#import "VEAdManagerDelegate.h"
#import "VEAdActionResponderDelegate.h"
#import "VEAdInfoModel.h"
#import "VESettingManager.h"

@implementation VEAdOperator

- (NSInteger)insertAdsItems:(NSMutableArray<id> *)mediaModels fromIndex:(NSInteger)startIndex {
    if (!mediaModels || self.delegate == nil || ![self.delegate respondsToSelector:@selector(getNextAdUniqueId)]) {
        return 0;
    }
    VESettingModel *interval = [[VESettingManager universalManager] settingForKey:VESettingKeyAdInterval];
    NSInteger adsInterval = [[interval currentValue] integerValue];
    if (adsInterval < 2) {
        adsInterval = 2;
    }
    NSInteger remainVideoCount = adsInterval;
    NSInteger insertedCount = 0;
    for (NSInteger i = 0; i < [mediaModels count]; i++) {
        id model = mediaModels[i];
        if ([model isKindOfClass:[VEAdInfoModel class]]) {
            remainVideoCount = adsInterval;
        } else {
            if (remainVideoCount == 0) {
                remainVideoCount = adsInterval;
                if (i >= startIndex) {
                    NSString* adId = [self.delegate getNextAdUniqueId];
                    if (!adId) {
                        break;
                    }
                    [mediaModels insertObject:[[VEAdInfoModel alloc] initByUniqueId:adId] atIndex:i];
                    insertedCount += 1;
                }
            } else {
                remainVideoCount -= 1;
            }
        }
    }
    return insertedCount;
}

@end
