//
//  VEInterfaceElementDescription.h
//  VEPlayerUIModule
//
//  Created by real on 2021/9/24.
//

/**
 * This file helps you to create a element which is a brick in whole scene.
 * The protocol 'VEInterfaceElementDescription' describes the characteristics of element.
 * If you want to create a custom view, the view should implement the protocol 'VEInterfaceCustomView'.
 **/

#import "VEPlayProtocol.h"

typedef enum : NSUInteger {
    VEInterfaceElementTypeMenu = 1000, // anchor
    VEInterfaceElementTypeMenuNormalCell,
    VEInterfaceElementTypeMenuSwitcherCell,
    
    VEInterfaceElementTypeGesture = 2000, // anchor
    VEInterfaceElementTypeGestureSingleTap,
    VEInterfaceElementTypeGestureDoubleTap,
    VEInterfaceElementTypeGestureHorizontalPan,
    VEInterfaceElementTypeGestureLeftVerticalPan,
    VEInterfaceElementTypeGestureRightVerticalPan,
    
    VEInterfaceElementTypeVisual = 3000, // anchor
    VEInterfaceElementTypeCustomView,
    VEInterfaceElementTypeProgressView,
    VEInterfaceElementTypeButton,
    VEInterfaceElementTypeLabel,
} VEInterfaceElementType;

@protocol VEInterfaceCustomView <NSObject>

- (void)elementViewAction;

- (void)elementViewEventNotify:(id)obj;

- (BOOL)isEnableZone:(CGPoint)point;

@end

@protocol VEInterfaceElementDescription <NSObject>

@required
// Described element identifier.
@property (nonatomic, copy) NSString *elementID;
// Described which type element is.
@property (nonatomic, assign) VEInterfaceElementType type;

@optional
// If this element is customized, customView must be given.
@property (nonatomic, weak) __kindof UIView<VEInterfaceCustomView> *customView;

/**
 * The element action, if provided, the action will be invoked when element view touched.
 * Presently, the element view touch can be interpreted like UIControlEventTouchUpInside & UIControlEventValueChanged.
 * The block parameter will be element view / gesture.
 * You should give an action key as your return value.
 * You can search all the action key in 'VEEventPoster.h'.
 */
@property (nonatomic, copy) id (^elementAction)(id);

/**
 * The element notify, if provided, the notify will be invoked when action of returned value going on.
 * The block first parameter will be element view / gesture, the others are notify detail params.
 * You should give at least one key as your return value if you want receive this action's notification.
 * The return value should be NSString means a key, or NSArray means mutli keys.
 */
@property (nonatomic, copy) id (^elementNotify)(id, NSString *,id);

/**
 * The element display, if provided, the element appearance will be set when creating.
 * The block parameter will be element view.
 */
@property (nonatomic, copy) void (^elementDisplay)(__kindof UIView *);

/**
 * The element will layout, if provided, the notify will be invoked when element view should layout.
 * The block first parameter will be element view, second is the same level view, the other is super view.
 */
@property (nonatomic, copy) void (^elementWillLayout)(UIView *, NSSet<UIView *> *, UIView *);

@end
