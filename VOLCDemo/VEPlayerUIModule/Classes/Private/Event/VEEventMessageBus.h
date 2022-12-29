//
//  VEEventMessageBus.h
//  VEPlayerUIModule
//
//  Created by real on 2021/9/7.
//

@import Foundation;

@interface VEEventMessageBus : NSObject

+ (instancetype)universalBus;

+ (void)destroyUnit;

- (void)postEvent:(NSString *)eventKey withObject:(id)object rightNow:(BOOL)now;

- (void)registEvent:(NSString *)eventKey withAction:(SEL)selector ofTarget:(id)target;

@end
