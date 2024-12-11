//
//  VEAdsInfoModel.h
//  VESceneModule
//
//  Created by litao.he on 2024/11/7.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VEAdInfoModel : NSObject

@property (nonatomic, strong, nonnull, readonly) NSString* uniqueId;

- (instancetype)initByUniqueId:(NSString* _Nonnull)uniqueId;

@end

NS_ASSUME_NONNULL_END
