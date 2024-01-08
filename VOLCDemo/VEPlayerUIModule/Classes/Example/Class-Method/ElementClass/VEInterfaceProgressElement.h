//
//  VEInterfaceProgressElement.h
//  VEPlayerUIModule
//
//  Created by real on 2022/1/7.
//

#import "VEInterfaceElementDescriptionImp.h"
#import "VEInterfaceElementProtocol.h"

extern NSString *const progressViewId;

extern NSString *const progressGestureId;

@interface VEInterfaceProgressElement : NSObject <VEInterfaceElementProtocol>

+ (VEInterfaceElementDescriptionImp *)progressView;

+ (VEInterfaceElementDescriptionImp *)progressGesture;

@end
