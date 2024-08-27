//
//  VEPlayerGestureWrapper.m
//  VEPlayerKit
//


#import "VEPlayerGestureWrapper.h"
#import "VEPlayerGestureHandlerProtocol.h"

@interface VEPlayerGestureWrapper() <UIGestureRecognizerDelegate>

@property (nonatomic, strong) NSHashTable<id<VEPlayerGestureHandlerProtocol>> *gestureHandlers;

@property (nonatomic, weak) id<VEPlayerGestureHandlerProtocol> activeHandler;

@end

@implementation VEPlayerGestureWrapper

#pragma mark - Life Cycle
- (instancetype)initWithGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer gestureType:(VEGestureType)gestureType {
    self = [super init];
    if (self) {
        _gestureRecognizer = gestureRecognizer;
        _gestureType = gestureType;
        [_gestureRecognizer addTarget:self action:@selector(onGestureRecognizerAction:)];
        _gestureRecognizer.delegate = self;
    }
    return self;
}

#pragma mark - Public Mehtod
- (void)addGestureHandler:(id<VEPlayerGestureHandlerProtocol>)handler {
    if (handler) {
        [self.gestureHandlers addObject:handler];
    }
}

- (void)removeGestureHandler:(id<VEPlayerGestureHandlerProtocol>)handler {
    if (handler && _gestureHandlers) {
        [_gestureHandlers removeObject:handler];
    }
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (self.gestureType == VEGestureType_DoubleTap && [touch.view isKindOfClass:[UIControl class]]) {
        return NO;
    }
    NSArray<id<VEPlayerGestureHandlerProtocol>> *gestureHandlers = [[_gestureHandlers allObjects] copy];
    if (!gestureHandlers || gestureHandlers.count == 0) {
        return NO;
    }
    BOOL shouldReceive = YES;
    CGPoint location = [touch locationInView:touch.view];
    for (id<VEPlayerGestureHandlerProtocol> handler in gestureHandlers) {
        if ([handler respondsToSelector:@selector(gestureRecognizerShouldDisable:gestureType:location:)]) {
            BOOL shouldDisable = [handler gestureRecognizerShouldDisable:gestureRecognizer gestureType:self.gestureType location:location];
            if (shouldDisable) {
                shouldReceive = NO;
                break;
            }
        }
    }
    if (@available(iOS 16.0, *)) {
        // FIX: iOS 16 player is in full screen, the pinch gesture on the right half of the screen may not work.
        if (shouldReceive && self.gestureType == VEGestureType_Pinch) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (gestureRecognizer.numberOfTouches == 2) {
                    gestureRecognizer.state = UIGestureRecognizerStateBegan;
                }
            });
        }
    }
    return shouldReceive;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    NSArray<id<VEPlayerGestureHandlerProtocol>> *gestureHandlers = [[_gestureHandlers allObjects] copy];
    if (!gestureHandlers || gestureHandlers.count == 0) {
        return NO;
    }
    id<VEPlayerGestureHandlerProtocol> activeHandler = nil;
    NSInteger activeHandlerPriority = NSIntegerMin;
    for (id<VEPlayerGestureHandlerProtocol> handler in gestureHandlers) {
        if ([handler respondsToSelector:@selector(gestureRecognizerShouldBegin:gestureType:)]) {
            BOOL shouldBegin = [handler gestureRecognizerShouldBegin:gestureRecognizer gestureType:self.gestureType];
            if (!shouldBegin) {
                continue;
            }
        }
        NSInteger priority = 0;
        if ([handler respondsToSelector:@selector(handlerPriorityForGestureType:)]) {
            priority = [handler handlerPriorityForGestureType:self.gestureType];
        }
        if (activeHandler && activeHandlerPriority == priority) {
            NSAssert(NO, @"gesture response priorities cannot be the same, please clarify their priorities：%@--%@", NSStringFromClass([activeHandler class]), NSStringFromClass([handler class]));
        }
        if (!activeHandler || priority > activeHandlerPriority) {
            activeHandler = handler;
            activeHandlerPriority = priority;
        }
    }
    self.activeHandler = activeHandler;
    return activeHandler != nil;
}

#pragma mark - Event Action
- (void)onGestureRecognizerAction:(UIGestureRecognizer *)gestureRecognizer {
    if ([self.activeHandler respondsToSelector:@selector(handleGestureRecognizer:gestureType:)]) {
        [self.activeHandler handleGestureRecognizer:gestureRecognizer gestureType:self.gestureType];
    }
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded ||
        gestureRecognizer.state == UIGestureRecognizerStateCancelled ||
        gestureRecognizer.state == UIGestureRecognizerStateFailed) {
        self.activeHandler = nil;
    }
}

#pragma mark - Setter & Getter
- (NSHashTable<id<VEPlayerGestureHandlerProtocol>> *)gestureHandlers {
    if (!_gestureHandlers) {
        _gestureHandlers = [NSHashTable weakObjectsHashTable];
    }
    return _gestureHandlers;
}

@end
