//
//  VEPlayerBackModule.h
//  VEPlayerKit
//
//  Created by zys on 2025/10/17.
//

#import "VEPlayerBaseModule.h"

NS_ASSUME_NONNULL_BEGIN

@interface VEPlayerBackModule : VEPlayerBaseModule

- (instancetype)initWithCurVC:(UIViewController *)vc;

@property (nonatomic, weak) UIViewController *curVC;

@end

NS_ASSUME_NONNULL_END
