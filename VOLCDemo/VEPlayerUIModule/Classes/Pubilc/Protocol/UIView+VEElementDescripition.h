//
//  UIView+VEElementDescripition.h
//  VEPlayerUIModule
//
//  Created by real on 2021/09/30.
//

@protocol VEInterfaceElementDescription;

@interface UIView (VEElementDescripition)

// If you use protocol 'VEInterfaceElementDescription' created a element(__kind of UIView), then you can get the element description of you previous input in UIView's propertys.
@property (nonatomic, strong) id<VEInterfaceElementDescription> elementDescription;
// To fast get elementID of property 'elementDescription', elementID == elementDescription.elementID;
@property (nonatomic, strong, readonly) NSString *elementID;

@end
