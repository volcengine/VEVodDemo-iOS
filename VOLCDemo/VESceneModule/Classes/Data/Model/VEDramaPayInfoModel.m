//
//  VEDramaPayInfoModel.m
//  VEPlayModule
//
//  Created by zyw on 2024/7/23.
//

#import "VEDramaPayInfoModel.h"

@implementation VEDramaPayInfoModel

- (instancetype)init {
    self = [super init];
    if (self) {
        _payStatus = VEDramaPayStatus_Paid;
        _price = 990;
    }
    return self;
}

- (BOOL)isPaid {
    return _payStatus == VEDramaPayStatus_Paid;
}

@end
