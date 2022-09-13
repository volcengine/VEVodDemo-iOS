//
//  VEInterfaceSensor.h
//  VEPlayerUIModule
//
//  Created by real on 2021/9/25.
//

@protocol VEInterfaceElementDataSource;
@protocol VEInterfaceElementDescription;

@interface VEInterfaceSensor : UIView

- (instancetype)initWithScene:(id<VEInterfaceElementDataSource>)scene;

@end
