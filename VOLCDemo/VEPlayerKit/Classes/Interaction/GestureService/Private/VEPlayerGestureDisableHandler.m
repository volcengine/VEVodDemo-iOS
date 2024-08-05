//
//  VEPlayerGestureDisableHandler.m
//  VEPlayerKit
//


#import "VEPlayerGestureDisableHandler.h"

@implementation VEPlayerGestureDisableHandler

- (instancetype)initWithGestureType:(VEGestureType)gestureType scene:(nonnull NSString *)scene {
    self = [super init];
    if (self) {
        _gestureType = gestureType;
        _scene = scene;
    }
    return self;
}

#pragma mark - VEPlayerGestureHandlerProtocol
- (BOOL)gestureRecognizerShouldDisable:(UIGestureRecognizer *)gestureRecognizer gestureType:(VEGestureType)gestureType location:(CGPoint)location {
    if (self.gestureType & gestureType) {
        return YES;
    }
    return NO;
}

@end
