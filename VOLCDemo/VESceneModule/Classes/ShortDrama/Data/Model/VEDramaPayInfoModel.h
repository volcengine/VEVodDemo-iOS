//
//  VEDramaPayInfoModel.h
//  VEPlayModule
//
//  Created by zyw on 2024/7/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, VEDramaPayStatus) {
    VEDramaPayStatus_Unpaid,
    VEDramaPayStatus_Paying,
    VEDramaPayStatus_Paid,
};

@interface VEDramaPayInfoModel : NSObject

@property (nonatomic, assign) VEDramaPayStatus payStatus;
@property (nonatomic, assign) NSInteger price; // Unit: Cent

- (BOOL)isPaid;

@end

NS_ASSUME_NONNULL_END
