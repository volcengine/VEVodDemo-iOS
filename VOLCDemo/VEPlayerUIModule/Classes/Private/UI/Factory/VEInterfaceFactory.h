//
//  VEInterfaceFactory.h
//  VEPlayerUIModule
//
//  Created by real on 2021/9/18.
//

@protocol VEInterfaceElementDataSource;
@protocol VEInterfaceElementDescription;
@protocol VEInterfaceCustomView;

@protocol VEInterfaceFactoryProduction <VEInterfaceCustomView>

@end

@interface VEInterfaceFactory : NSObject

+ (UIView *)sceneOfMaterial:(id<VEInterfaceElementDataSource>)scene;

+ (UIView *)elementOfMaterial:(id<VEInterfaceElementDescription>)element;

@end

