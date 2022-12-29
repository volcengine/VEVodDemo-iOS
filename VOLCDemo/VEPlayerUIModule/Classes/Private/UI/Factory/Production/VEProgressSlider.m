//
//  VEProgressSlider.m
//  VEPlayerUIModule
//
//  Created by real on 2021/11/18.
//

#import "VEProgressSlider.h"
#import "VEEventMessageBus.h"
#import "Masonry.h"

const CGFloat thumbWidth = 24.0;

NSString *const VEPlayProgressSliderGestureEnable = @"VEPlayProgressSliderGestureEnable";

@interface VEProgressSlider ()

@property (nonatomic, strong) UIView *backView;

@property (nonatomic, strong) UIView *bufferView;

@property (nonatomic, strong) UIView *progressView;

@property (nonatomic, strong) UIImageView *thumbView;

@property (nonatomic, assign) BOOL touching;

@property (nonatomic, assign) CGPoint beginPoint;

@property (nonatomic, assign) CGFloat beginValue;

@property (nonatomic, assign) BOOL touchDetective;

@end

@implementation VEProgressSlider

- (instancetype)init {
    self = [super init];
    if (self) {
        [self layoutSublayers];
    }
    return self;
}

- (void)layoutSublayers {
    [self addSubview:self.backView];
    [self.backView addSubview:self.bufferView];
    [self.backView addSubview:self.progressView];
    [self addSubview:self.thumbView];
    
    [self.backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(thumbWidth / 2.0);
        make.trailing.equalTo(self).offset(-(thumbWidth / 2.0));
        make.centerY.equalTo(self);
        make.height.equalTo(@2);
    }];
    
    [self.bufferView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.bottom.equalTo(self.backView);
        make.width.equalTo(@0);
    }];
    
    [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.bottom.equalTo(self.backView);
        make.width.equalTo(@0);
    }];
    
    [self.thumbView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.progressView.mas_trailing);
        make.centerY.equalTo(self);
        make.size.equalTo(@(CGSizeMake(thumbWidth, thumbWidth)));
    }];
}

#pragma mark ----- Function

- (void)setProgressValue:(CGFloat)progressValue {
    //    if (self.touching) return;
    progressValue = MAX(0.0, MIN(1.0, progressValue));
    _progressValue = progressValue;
    [self layoutIfNeeded];
    CGFloat totalWidth = self.backView.frame.size.width ?: 0.0;
    [self.progressView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.leading.top.bottom.equalTo(self.backView);
        make.width.equalTo(@(progressValue * totalWidth));
    }];
}

- (void)setBufferValue:(CGFloat)bufferValue {
    bufferValue = MAX(0.0, MIN(1.0, bufferValue));
    _bufferValue = bufferValue;
    [self layoutIfNeeded];
    CGFloat totalWidth = self.backView.frame.size.width ?: 0.0;
    [self.bufferView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.leading.top.bottom.equalTo(self.backView);
        make.width.equalTo(@(bufferValue * totalWidth));
    }];
}

- (void)setThumbImage:(UIImage *)image {
    self.thumbView.image = [UIImage imageNamed:@"ve_longvideo_slidedragbar"];
}

- (void)setProgressColor:(UIColor *)color {
    self.progressView.backgroundColor = color;
}

- (void)setProgressBackgroundColor:(UIColor *)color {
    self.backView.backgroundColor = color;
}

- (void)setProgressBufferColor:(UIColor *)color {
    self.bufferView.backgroundColor = color;
}


#pragma mark ----- Lazy Load

- (UIView *)backView {
    if (!_backView) {
        _backView = [UIView new];
        _backView.backgroundColor = [UIColor whiteColor];
        _backView.clipsToBounds = YES;
        _backView.layer.cornerRadius = 1.0;
    }
    return _backView;
}

- (UIView *)bufferView {
    if (!_bufferView) {
        _bufferView = [UIView new];
        _bufferView.backgroundColor = [UIColor lightGrayColor];
    }
    return _bufferView;
}

- (UIView *)progressView {
    if (!_progressView) {
        _progressView = [UIView new];
        _progressView.backgroundColor = [UIColor blueColor];
    }
    return _progressView;
}

- (UIImageView *)thumbView {
    if (!_thumbView) {
        _thumbView = [UIImageView new];
        _thumbView.image = [UIImage imageNamed:@"ve_longvideo_slidedragbar"];
    }
    return _thumbView;
}


#pragma mark ----- UIResponder

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGPoint touchPoint = [[touches anyObject] locationInView:self];
    self.beginPoint = touchPoint;
    self.touching = NO;
    self.beginValue = 0.0;
    
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGPoint touchPoint = [[touches anyObject] locationInView:self];
    CGFloat movedX = touchPoint.x - self.beginPoint.x;
    if (!self.touching && (ABS(movedX) > 13)) {
        self.touching = YES;
        self.beginValue = movedX;
    }
    [self checkEventByMovedX:movedX];
    self.touchDetective = YES;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGPoint touchPoint = [[touches anyObject] locationInView:self];
    CGFloat movedX = touchPoint.x - self.beginPoint.x;
    if (CGPointEqualToPoint(self.beginPoint, touchPoint)) {
        [self singleTapEventByMovedX:touchPoint.x];
        return;
    }
    [self checkEventByMovedX:movedX];
    self.touching = NO;
    self.touchDetective = NO;
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.touching = NO;
    self.touchDetective = NO;
}

- (void)singleTapEventByMovedX:(CGFloat)movedX {
    movedX -= (thumbWidth / 2.0);
    CGFloat totalWidth = self.backView.frame.size.width ?: 0.0;
    self.progressValue = (movedX / totalWidth);
    if ([self.delegate respondsToSelector:@selector(progressManualChanged:)]) {
        [self.delegate progressManualChanged:self.progressValue];
    }
}

- (void)checkEventByMovedX:(CGFloat)movedX {
    if (self.touching) {
        CGFloat changeValue = (movedX - self.beginValue) / (100 * 2);
        self.beginValue = movedX;
        self.progressValue += changeValue;
        if ([self.delegate respondsToSelector:@selector(progressManualChanged:)]) {
            [self.delegate progressManualChanged:self.progressValue];
        }
    }
}


#pragma mark ----- Hit Test

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    CGRect bounds = self.bounds;
    CGFloat increase = 30.0;
    bounds.size.height += increase;
    bounds.origin.y -= (increase / 2.0);
    return CGRectContainsPoint(bounds, point);
}

- (void)setTouchDetective:(BOOL)touchDetective {
    _touchDetective = touchDetective;
    [[VEEventMessageBus universalBus] postEvent:VEPlayProgressSliderGestureEnable withObject:@(touchDetective) rightNow:YES];
}

@end
