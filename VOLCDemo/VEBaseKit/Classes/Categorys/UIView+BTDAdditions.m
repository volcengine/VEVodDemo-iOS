//
//  UIView+BTDAdditions.m
//

#import "UIView+BTDAdditions.h"
#import "NSObject+BTDAdditions.h"
#import <objc/runtime.h>

@implementation UIView (BTDAdditions)

- (CGFloat)btd_x
{
    return self.frame.origin.x;
}

- (void)setBtd_x:(CGFloat)btd_x
{
    CGRect rect = self.frame;
    rect.origin.x = btd_x;
    self.frame = rect;
}

- (CGFloat)btd_y
{
    return self.frame.origin.y;
}

- (void)setBtd_y:(CGFloat)btd_y
{
    CGRect rect = self.frame;
    rect.origin.y = btd_y;
    self.frame = rect;
}

- (CGFloat)btd_centerX
{
    return self.center.x;
}

- (void)setBtd_centerX:(CGFloat)btd_centerX
{
    CGPoint center = self.center;
    center.x = btd_centerX;
    self.center = center;
}

- (CGFloat)btd_centerY
{
    return self.center.y;
}

- (void)setBtd_centerY:(CGFloat)btd_centerY
{
    CGPoint center = self.center;
    center.y = btd_centerY;
    self.center = center;
}

- (CGFloat)btd_width
{
    return self.frame.size.width;
}

- (void)setBtd_width:(CGFloat)btd_width
{
    CGRect rect = self.frame;
    rect.size.width = btd_width;
    self.frame = rect;
}

- (CGFloat)btd_height
{
    return self.frame.size.height;
}

- (void)setBtd_height:(CGFloat)btd_height
{
    CGRect rect = self.frame;
    rect.size.height = btd_height;
    self.frame = rect;
}

- (CGSize)btd_size {
    return self.frame.size;
}

- (void)setBtd_size:(CGSize)btd_size {
    CGRect rect = self.frame;
    rect.size = btd_size;
    self.frame = rect;
}

- (UIImage *)btd_snapshotImage
{
    
    UIGraphicsImageRendererFormat *rendererFormat = [[UIGraphicsImageRendererFormat alloc] init];
    rendererFormat.opaque = self.opaque;
    rendererFormat.scale = 0;
    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:self.bounds.size format:rendererFormat];
    UIImage *snap = [renderer imageWithActions:^(UIGraphicsImageRendererContext * _Nonnull rendererContext) {
        [self.layer renderInContext:rendererContext.CGContext];
    }];
    return snap;
}

- (void)btd_setLayerShadow:(UIColor*)color offset:(CGSize)offset radius:(CGFloat)radius
{
    self.layer.shadowColor = color.CGColor;
    self.layer.shadowOffset = offset;
    self.layer.shadowRadius = radius;
    self.layer.shadowOpacity = 1;
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = [UIScreen mainScreen].scale;
}

- (void)btd_removeAllSubviews
{
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

- (UIViewController *)btd_viewController
{
    for (UIView *view = self; view; view = view.superview) {
        UIResponder *nextResponder = [view nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)nextResponder;
        }
    }
    return nil;
}

- (void)setBtd_left:(CGFloat)btd_left {
    CGRect frame = self.frame;
    frame.origin.x = btd_left;
    self.frame = frame;
}

- (CGFloat)btd_left {
    return self.frame.origin.x;
}

- (void)setBtd_right:(CGFloat)btd_right {
    CGRect frame = self.frame;
    frame.origin.x = btd_right - frame.size.width;
    self.frame = frame;
}

- (CGFloat)btd_right {
    return self.frame.origin.x + self.frame.size.width;
}

- (void)setBtd_top:(CGFloat)btd_top {
    CGRect frame = self.frame;
    frame.origin.y = btd_top;
    self.frame = frame;
}

- (CGFloat)btd_top {
    return self.frame.origin.y;
}

- (void)setBtd_bottom:(CGFloat)btd_bottom {
    CGRect frame = self.frame;
    frame.origin.y = btd_bottom - frame.size.height;
    self.frame = frame;
}

- (CGFloat)btd_bottom {
    return self.frame.origin.y + self.frame.size.height;
}

- (CGFloat)btd_screenX {
    CGFloat x = 0.0f;
    for (UIView* view = self; view; view = view.superview) {
        x += view.btd_left;
    }
    return x;
}

- (CGFloat)btd_screenY {
    CGFloat y = 0.0f;
    for (UIView* view = self; view; view = view.superview) {
        y += view.btd_top;
    }
    return y;
}

- (UIEdgeInsets)btd_safeAreaInsets {
    // iOS 13 SDK禁止访问statusBar的私有方法，直接使用系统的替代
    if (@available(iOS 13.0, *)) {
        return self.safeAreaInsets;
    }
    UIEdgeInsets safeInset = UIEdgeInsetsZero;
    if (@available(iOS 11.0, *)) {
        safeInset = self.safeAreaInsets;
    }
    CGRect viewFrameInWindow = [self convertRect:self.bounds toView:nil];
    UIView *statusBarView = [[UIApplication sharedApplication] valueForKey:@"statusBar"];
    if ((viewFrameInWindow.origin.y < 40 && ![UIApplication sharedApplication].statusBarHidden) || statusBarView.btd_height <= 0 ){
        if (safeInset.top <= 0){
            safeInset.top = [UIApplication sharedApplication].statusBarFrame.size.height - viewFrameInWindow.origin.y;
        }
        if (safeInset.top <= 0){
            safeInset.top = 20 - viewFrameInWindow.origin.y;
        }
    }
    return safeInset;
}

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self btd_swizzleInstanceMethod:@selector(pointInside:withEvent:) with:@selector(_btd_pointInside:withEvent:)];
    });
}

- (BOOL)_btd_pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    if (UIEdgeInsetsEqualToEdgeInsets(self.btd_hitTestEdgeInsets, UIEdgeInsetsZero)) {
        return [self _btd_pointInside:point withEvent:event];
    }
    CGRect hitFrame = UIEdgeInsetsInsetRect(self.bounds, self.btd_hitTestEdgeInsets);
    return CGRectContainsPoint(hitFrame, point);
}

- (void)setBtd_hitTestEdgeInsets:(UIEdgeInsets)btd_hitTestEdgeInsets {
    NSValue *value = [NSValue valueWithUIEdgeInsets:btd_hitTestEdgeInsets];
    objc_setAssociatedObject(self, @selector(btd_hitTestEdgeInsets), value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIEdgeInsets)btd_hitTestEdgeInsets {
    NSValue *value = objc_getAssociatedObject(self, _cmd);
    if (value) {
        return [value UIEdgeInsetsValue];
    }
    return UIEdgeInsetsZero;
}

- (void)btd_eachSubview:(void (^)(UIView *subview))block {
    if (block == nil) {
        return;
    }
    [self.subviews enumerateObjectsUsingBlock:^(UIView *subview, NSUInteger idx, BOOL *stop) {
        block(subview);
    }];
}

- (void)btd_addRoundedCorners:(UIRectCorner)corners withRadius:(CGFloat)radius {
    UIBezierPath *rounded = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:corners cornerRadii:CGSizeMake(radius, radius)];
    CAShapeLayer *shape = [[CAShapeLayer alloc] init];
    [shape setPath:rounded.CGPath];
    self.layer.mask = shape;
}

@end
