//
//  NSObject+ToElementDescription.h
//  VEPlayerUIModule
//
//  Created by real on 2022/1/7.
//

#import "VEInterfaceElementDescriptionImp.h"

@interface NSObject (ToElementDescription)

- (VEInterfaceElementDescriptionImp *)elementDescription;

- (UIView *)viewOfElementIdentifier:(NSString *)identifier inGroup:(NSSet<UIView *> *)viewGroup;

@end

