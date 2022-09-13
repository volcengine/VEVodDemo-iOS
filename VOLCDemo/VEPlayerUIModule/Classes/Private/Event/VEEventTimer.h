//
//  VEEventTimer.h
//  VEPlayerUIModule
//
//  Created by real on 2021/11/23.
//

@interface VEEventTimer : NSObject

+ (instancetype)universalTimer;

+ (void)destroyUnit;

- (void)addTarget:(id)target action:(SEL)selector loopInterval:(NSInteger)ms; // millisecond

- (void)removeTarget:(id)target ofAction:(SEL)selector;

@end
