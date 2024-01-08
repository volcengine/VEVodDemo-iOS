//
//  VEInterfaceFactory.m
//  VEPlayerUIModule
//
//  Created by real on 2021/9/18.
//

#import "VEInterfaceFactory.h"
#import "VEEventConst.h"
#import "VEInterfaceProtocol.h"
#import "VEInterfaceElementDescription.h"
#import "UIView+VEElementDescripition.h"
#import "VEInterfaceContainer.h"
#import "VEActionButton+Private.h"
#import "VEProgressView+Private.h"
#import "VEDisplayLabel+Private.h"

@implementation VEInterfaceFactory

+ (UIView *)sceneOfMaterial:(id<VEInterfaceElementDataSource>)scene {
    return [self buildingScene:scene];
}

+ (UIView *)elementOfMaterial:(id<VEInterfaceElementDescription>)element {
    return [self creatingElement:element];
}


#pragma mark ----- Scene

+ (UIView *)buildingScene:(id<VEInterfaceElementDataSource>)obj {
    if ([obj conformsToProtocol:@protocol(VEInterfaceElementDataSource)]) {
        VEInterfaceContainer *interfaceContainer = [[VEInterfaceContainer alloc] initWithScene:obj];
        return interfaceContainer;
    }
    return nil;
}


#pragma mark ----- Element

+ (UIView *)creatingElement:(id<VEInterfaceElementDescription>)obj {
    if ([obj conformsToProtocol:@protocol(VEInterfaceElementDescription)]) {
        switch (obj.type) {
            case VEInterfaceElementTypeProgressView : {
                return [self createProgressView:obj];
            }
                break;
            case VEInterfaceElementTypeButton : {
                return [self createButton:obj];
            }
                break;
            case VEInterfaceElementTypeLabel : {
                return [self createLabel:obj];
            }
                break;
            case VEInterfaceElementTypeMenuNormalCell : {
                
            }
                break;
            case VEInterfaceElementTypeMenuSwitcherCell : {
                
            }
                break;
            case VEInterfaceElementTypeCustomView :
            default: {
                [self loadCustomView:obj];
            }
                break;
        }
    }
    return nil;
}


#pragma mark ----- Common

+ (void)loadElementAction:(UIView<VEInterfaceCustomView> *)elementView {
    if ([elementView respondsToSelector:@selector(elementViewAction)]) {
        [elementView elementViewAction];
    }
    if (elementView.elementDescription.elementNotify) {
        NSString *mayNotiKey = elementView.elementDescription.elementNotify(elementView, @"", @"");
        void (^keyBlock) (NSString *) = ^(NSString *key) {
            if ([key isKindOfClass:[NSString class]]) {
                SEL selector = @selector(elementViewEventNotify:);
                if ([elementView respondsToSelector:selector]) {
                    [[VEEventMessageBus universalBus] registEvent:key withAction:selector ofTarget:elementView];
                }
            }
        };
        if ([mayNotiKey isKindOfClass:[NSArray class]]) {
            NSArray *mayNotiKeys = (NSArray *)mayNotiKey;
            for (NSString *key in mayNotiKeys) {
                keyBlock(key);
            }
        } else {
            keyBlock(mayNotiKey);
        }
    }
}

#pragma mark ----- VEActionButton

+ (UIView *)createButton:(id<VEInterfaceElementDescription>)obj {
    VEActionButton *button = [VEActionButton buttonWithType:UIButtonTypeCustom];
    button.elementDescription = obj;
    if (obj.elementDisplay) obj.elementDisplay(button);
    [self loadElementAction:button];
    return button;
}


#pragma mark ----- VEProgressView

+ (UIView *)createProgressView:(id<VEInterfaceElementDescription>)obj {
    VEProgressView *progressView = [VEProgressView new];
    progressView.elementDescription = obj;
    [progressView setAutoBackStartPoint:YES];
    [self loadElementAction:progressView];
    return progressView;
}


#pragma mark ----- VEDisplayLabel

+ (UIView *)createLabel:(id<VEInterfaceElementDescription>)obj {
    VEDisplayLabel *label = [VEDisplayLabel new];
    label.textAlignment = NSTextAlignmentLeft;
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:15.0];
    if (obj.elementDisplay) obj.elementDisplay(label);
    label.elementDescription = obj;
    [self loadElementAction:label];
    return label;
}


#pragma mark ----- CustomView

+ (UIView *)loadCustomView:(id<VEInterfaceElementDescription>)obj {
    UIView<VEInterfaceCustomView> *customView = [obj customView];
    if ([customView isKindOfClass:[UIView class]]) {
        [self loadElementAction:customView];
    }
    return customView;
}

@end
