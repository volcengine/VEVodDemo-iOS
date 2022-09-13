//
//  VEInterfaceArea.h
//  VEPlayerUIModule
//
//  Created by real on 2021/9/18.
//

#import "UIView+VEElementDescripition.h"
@protocol VEInterfaceElementDescription;

@interface VEInterfaceArea : UIView

@property (nonatomic, assign) NSInteger zIndex;

- (instancetype)initWithElements:(NSArray<id<VEInterfaceElementDescription>> *)elements;

- (BOOL)isEnableZone:(CGPoint)point;

- (void)invalidateLayout;

// deprecated

- (void)screenAction;

- (void)show:(BOOL)show animated:(BOOL)animated;

@end
