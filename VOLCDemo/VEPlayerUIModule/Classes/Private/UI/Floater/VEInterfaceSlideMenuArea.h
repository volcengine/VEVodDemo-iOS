//
//  VEInterfaceSlideMenuArea.h
//  VEPlayerUIModule
//
//  Created by real on 2021/9/24.
//

#import "VEInterfaceArea.h"
#import "VEInterfaceFloater.h"
@class VEInterfaceElementDescription;

@interface VEInterfaceSlideMenuArea : VEInterfaceArea <VEInterfaceFloaterPresentProtocol>

- (void)fillElements:(NSArray<VEInterfaceElementDescription *> *)elements;

@end
