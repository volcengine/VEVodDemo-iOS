//
//  VEInterfaceVisual.h
//  VEPlayerUIModule
//
//  Created by real on 2021/9/24.
//

@protocol VEInterfaceElementDataSource;
@protocol VEInterfaceElementDescription;

@interface VEInterfaceVisual : UIView

- (instancetype)initWithScene:(id<VEInterfaceElementDataSource>)scene;

@end
