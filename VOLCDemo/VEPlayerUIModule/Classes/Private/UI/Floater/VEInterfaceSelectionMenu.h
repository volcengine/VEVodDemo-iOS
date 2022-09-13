//
//  VEInterfaceSelectionMenu.h
//  VEPlayerUIModule
//
//  Created by real on 2021/10/09.
//

#import "VEInterfaceFloater.h"

@interface VEInterfaceDisplayItem : NSObject

@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) NSString *icon;

@property (nonatomic, strong) NSString *itemAction;

@property (nonatomic, strong) id actionParam;

@end

@interface VEInterfaceSelectionMenu : UIView <VEInterfaceFloaterPresentProtocol>

@property (nonatomic, strong) NSMutableArray<VEInterfaceDisplayItem *> *items;

@end



