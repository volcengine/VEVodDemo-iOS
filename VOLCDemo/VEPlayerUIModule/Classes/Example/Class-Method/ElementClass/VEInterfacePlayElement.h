//
//  VEInterfacePlayElement.h
//  VEPlayerUIModule
//
//  Created by real on 2021/12/28.
//

#import "VEInterfaceElementDescriptionImp.h"
#import "VEInterfaceElementProtocol.h"

extern NSString *const playButtonId;

extern NSString *const playGestureId;

@interface VEInterfacePlayElement : NSObject <VEInterfaceElementProtocol>

+ (VEInterfaceElementDescriptionImp *)playButton;

+ (VEInterfaceElementDescriptionImp *)playGesture;

@end


