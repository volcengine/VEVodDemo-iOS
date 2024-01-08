//
//  VEProgressView+Private.h
//  VEPlayerUIModule
//
//  Created by real on 2021/11/18.
//

#import "VEProgressView.h"
@protocol VEInterfaceFactoryProduction;

@interface VEProgressView () <VEInterfaceFactoryProduction>

- (void)setAutoBackStartPoint:(BOOL)autoBackStartPoint;

@end
