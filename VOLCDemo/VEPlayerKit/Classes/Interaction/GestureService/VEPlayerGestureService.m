//
//  VEPlayerGestureService.m
//  VEPlayerKit
//

#import "VEPlayerGestureService.h"
#import "VEPlayerGestureWrapper.h"
#import "VEPlayerGestureDisableHandler.h"

@interface VEPlayerGestureService() <UIGestureRecognizerDelegate>

@property (nonatomic, strong) VEPlayerGestureWrapper *singleTapGestureWrapper;
@property (nonatomic, strong) VEPlayerGestureWrapper *doubleTapGestureWrapper;
@property (nonatomic, strong) VEPlayerGestureWrapper *panGestureWrapper;
@property (nonatomic, strong) VEPlayerGestureWrapper *longPressGestureWrapper;
@property (nonatomic, strong) VEPlayerGestureWrapper *pinchGestureWrapper;

@end

@implementation VEPlayerGestureService

- (void)setGestureView:(UIView *)gestureView {
    if(_gestureView == gestureView) {
        return;
    }
    if (_gestureView != nil && _gestureView != gestureView) {
        [self removeGestureView:_gestureView];
    }
    _gestureView = gestureView;
    [gestureView addGestureRecognizer:self.singleTapGestureWrapper.gestureRecognizer];
    [gestureView addGestureRecognizer:self.doubleTapGestureWrapper.gestureRecognizer];
    [gestureView addGestureRecognizer:self.panGestureWrapper.gestureRecognizer];
    [gestureView addGestureRecognizer:self.longPressGestureWrapper.gestureRecognizer];
    [gestureView addGestureRecognizer:self.pinchGestureWrapper.gestureRecognizer];
    [self.singleTapGestureWrapper.gestureRecognizer requireGestureRecognizerToFail:self.doubleTapGestureWrapper.gestureRecognizer];
    self.singleTapGestureWrapper.gestureRecognizer.delaysTouchesBegan = YES;
}

- (void)removeGestureView:(UIView *)gestureView {
    [gestureView removeGestureRecognizer:self.singleTapGestureWrapper.gestureRecognizer];
    [gestureView removeGestureRecognizer:self.doubleTapGestureWrapper.gestureRecognizer];
    [gestureView removeGestureRecognizer:self.panGestureWrapper.gestureRecognizer];
    [gestureView removeGestureRecognizer:self.longPressGestureWrapper.gestureRecognizer];
    [gestureView removeGestureRecognizer:self.pinchGestureWrapper.gestureRecognizer];
}

#pragma mark - Public Mehtod
- (void)addGestureHandler:(id<VEPlayerGestureHandlerProtocol>)handler forType:(VEGestureType)gestureType {
    if (gestureType & VEGestureType_SingleTap) {
        [self.singleTapGestureWrapper addGestureHandler:handler];
    }
    if (gestureType & VEGestureType_DoubleTap) {
        [self.doubleTapGestureWrapper addGestureHandler:handler];
    }
    if (gestureType & VEGestureType_Pan) {
        [self.panGestureWrapper addGestureHandler:handler];
    }
    if (gestureType & VEGestureType_LongPress) {
        [self.longPressGestureWrapper addGestureHandler:handler];
    }
    if (gestureType & VEGestureType_Pinch) {
        [self.pinchGestureWrapper addGestureHandler:handler];
    }
}

- (void)removeGestureHandler:(id<VEPlayerGestureHandlerProtocol>)handler forType:(VEGestureType)gestureType {
    if (gestureType & VEGestureType_SingleTap) {
        [_singleTapGestureWrapper removeGestureHandler:handler];
    }
    if (gestureType & VEGestureType_DoubleTap) {
        [_doubleTapGestureWrapper removeGestureHandler:handler];
    }
    if (gestureType & VEGestureType_Pan) {
        [_panGestureWrapper removeGestureHandler:handler];
    }
    if (gestureType & VEGestureType_LongPress) {
        [_longPressGestureWrapper removeGestureHandler:handler];
    }
    if (gestureType & VEGestureType_Pinch) {
        [_pinchGestureWrapper removeGestureHandler:handler];
    }
}

- (void)removeGestureHandler:(id<VEPlayerGestureHandlerProtocol>)handler {
    [self removeGestureHandler:handler forType:VEGestureType_All];
}

- (id<VEPlayerGestureHandlerProtocol>)disableGestureType:(VEGestureType)gestureType scene:(NSString *)scene {
    NSAssert(scene.length > 0, @"disableGestureType scene is nil ！！！");
    id<VEPlayerGestureHandlerProtocol> disableHandler = [[VEPlayerGestureDisableHandler alloc] initWithGestureType:gestureType scene:scene];
    [self addGestureHandler:disableHandler forType:gestureType];
    return disableHandler;
}

#pragma mark - Setter & Getter
- (VEPlayerGestureWrapper *)singleTapGestureWrapper {
    if (!_singleTapGestureWrapper) {
        _singleTapGestureWrapper = [[VEPlayerGestureWrapper alloc] initWithGestureRecognizer:[[UITapGestureRecognizer alloc] init] gestureType:VEGestureType_SingleTap];
    }
    return _singleTapGestureWrapper;
}

- (VEPlayerGestureWrapper *)doubleTapGestureWrapper {
    if (!_doubleTapGestureWrapper) {
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] init];
        gesture.numberOfTapsRequired = 2;
        _doubleTapGestureWrapper = [[VEPlayerGestureWrapper alloc] initWithGestureRecognizer:gesture gestureType:VEGestureType_DoubleTap];
    }
    return _doubleTapGestureWrapper;
}

- (VEPlayerGestureWrapper *)panGestureWrapper {
    if (!_panGestureWrapper) {
        UIPanGestureRecognizer *gesture = [[UIPanGestureRecognizer alloc] init];
        gesture.delaysTouchesBegan = NO;
        gesture.delaysTouchesEnded = NO;
        _panGestureWrapper = [[VEPlayerGestureWrapper alloc] initWithGestureRecognizer:gesture gestureType:VEGestureType_Pan];
    }
    return _panGestureWrapper;
}

- (VEPlayerGestureWrapper *)longPressGestureWrapper {
    if (!_longPressGestureWrapper) {
        UILongPressGestureRecognizer *gesture = [[UILongPressGestureRecognizer alloc] init];
        gesture.numberOfTouchesRequired = 1;
        gesture.minimumPressDuration = 0.5;
        _longPressGestureWrapper = [[VEPlayerGestureWrapper alloc] initWithGestureRecognizer:gesture gestureType:VEGestureType_LongPress];
    }
    return _longPressGestureWrapper;
}

- (VEPlayerGestureWrapper *)pinchGestureWrapper {
    if (!_pinchGestureWrapper) {
        UIPinchGestureRecognizer *gesture = [[UIPinchGestureRecognizer alloc] init];
        _pinchGestureWrapper = [[VEPlayerGestureWrapper alloc] initWithGestureRecognizer:gesture gestureType:VEGestureType_Pinch];
    }
    return _pinchGestureWrapper;
}

@end
