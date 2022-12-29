//
//  UIView+VEElementDescripition.m
//  VEPlayerUIModule
//
//  Created by real on 2021/09/30.
//

#import "UIView+VEElementDescripition.h"
#import "VEInterfaceElementDescription.h"
#import <objc/message.h>

@implementation UIView (VEElementDescripition)

- (void)setElementDescription:(id<VEInterfaceElementDescription>)elementDescription {
    objc_setAssociatedObject(self, @selector(elementDescription), elementDescription, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id<VEInterfaceElementDescription>)elementDescription {
    return objc_getAssociatedObject(self, _cmd);
}

- (NSString *)elementID {
    return [self.elementDescription elementID];
}

@end
