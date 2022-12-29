//
//  VEInterfaceFloater.h
//  VEPlayerUIModule
//
//  Created by real on 2021/11/1.
//

@protocol VEInterfaceElementDataSource;
@protocol VEInterfaceElementDescription;

@protocol VEInterfaceFloaterPresentProtocol <NSObject>

- (CGRect)enableZone;

- (void)show:(BOOL)show;

@end

@interface VEInterfaceFloater : UIControl

- (instancetype)initWithScene:(id<VEInterfaceElementDataSource>)scene;

@end
