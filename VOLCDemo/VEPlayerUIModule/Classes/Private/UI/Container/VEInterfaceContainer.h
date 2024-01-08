//
//  VEInterfaceContainer.h
//  VEPlayerUIModule
//
//  Created by real on 2021/9/18.
//

@protocol VEInterfaceElementDataSource;
@protocol VEInterfaceElementDescription;

@interface VEInterfaceContainer : UIView

- (instancetype)initWithScene:(id<VEInterfaceElementDataSource>)scene;

@end
