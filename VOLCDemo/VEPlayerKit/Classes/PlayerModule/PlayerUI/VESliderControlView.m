//
//  VESliderControlView.m
//  VEPlayerUIModule
//

#import "VESliderControlView.h"
#import <Masonry/Masonry.h>

@interface VESliderControlView () {
    NSTimer *_timer;
}

@property (nonatomic, strong) UIView *backView;
@property (nonatomic, strong) UIView *bufferView;
@property (nonatomic, strong) UIView *progressView;

@property (nonatomic, strong) UIImageView *thumbView;

@property (nonatomic, assign) BOOL touching;
@property (nonatomic, assign) CGPoint beginPoint;
@property (nonatomic, assign) CGFloat beginValue;

@end

@implementation VESliderControlView

- (instancetype)initWithContentMode:(VESliderControlViewContentMode)contentMode {
    self = [super init];
    if (self) {
        _thumbHeight = 4;
        _thumbOffset = 12;
        _sliderCoefficient = 3;
        _contentMode = contentMode;
        _thumbImage = [UIImage imageNamed:@"icon_dot"];
        _thumbTouchImage = [UIImage imageNamed:@"icon_dot_big"];
        [self configuratoinCustomView];
    }
    return self;
}

#pragma mark - UI

- (void)configuratoinCustomView {
    [self addSubview:self.backView];
    [self.backView addSubview:self.bufferView];
    [self.backView addSubview:self.progressView];
    [self addSubview:self.thumbView];
    
    [self.backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(self.thumbOffset);
        make.trailing.equalTo(self).offset(-(self.thumbOffset));
        switch (self.contentMode) {
            case VESliderControlViewContentModeCenter:
                make.centerY.equalTo(self);
                break;
            case VESliderControlViewContentModeTop:
                make.top.equalTo(self);
                break;
            case VESliderControlViewContentModeBottom:
                make.bottom.equalTo(self);
                break;
            default:
                break;
        }
        make.height.equalTo(@(self.thumbHeight));
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
        switch (self.contentMode) {
            case VESliderControlViewContentModeCenter:
                make.centerY.equalTo(self);
                break;
            case VESliderControlViewContentModeTop:
                make.top.equalTo(self).with.offset(-((self.thumbImage.size.height - self.thumbHeight) / 2.0));;
                break;
            case VESliderControlViewContentModeBottom:
                make.bottom.equalTo(self).with.offset((self.thumbImage.size.height - self.thumbHeight) / 2.0);
                break;
            default:
                break;
        }
        make.size.equalTo(@(CGSizeMake(self.thumbImage.size.width, self.thumbImage.size.height)));
    }];
}

#pragma mark - private

- (void)_progressWillChangeStart {
    if (self.delegate && [self.delegate respondsToSelector:@selector(progressBeginSlideChange:)]) {
        [self.delegate progressBeginSlideChange:self];
    }
}

- (void)_progressValueChanging:(CGFloat)value {
    if (self.delegate && [self.delegate respondsToSelector:@selector(progressSliding:value:)]) {
        [self.delegate progressSliding:self value:value];
    }
}

- (void)_progressValueChanged:(CGFloat)value {
    if (self.delegate && [self.delegate respondsToSelector:@selector(progressDidEndSlide:value:)]) {
        [self.delegate progressDidEndSlide:self value:value];
    }
}

- (void)_progressSlideCancel {
    if (self.delegate && [self.delegate respondsToSelector:@selector(progressSlideCancel:)]) {
        [self.delegate progressSlideCancel:self];
    }
}

- (void)_progressScaleLayout:(BOOL)slidering {
    [UIView animateWithDuration:.3f animations:^{
        CGFloat retThumbHeight;
        CGFloat retThumbImageHeight;
        CGFloat retThumbImageWidth;
        if (slidering) {
            retThumbHeight = self.thumbHeight * 3;
            retThumbImageWidth = self.thumbTouchImage.size.width;
            retThumbImageHeight = self.thumbTouchImage.size.height;
            [self.thumbView setImage:self.thumbTouchImage];
        } else {
            retThumbHeight = self.thumbHeight;
            retThumbImageWidth = self.thumbImage.size.width;
            retThumbImageHeight = self.thumbImage.size.height;
            [self.thumbView setImage:self.thumbImage];
        }
        [self.backView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@(retThumbHeight));
        }];
        [self.thumbView mas_updateConstraints:^(MASConstraintMaker *make) {
            switch (self.contentMode) {
                case VESliderControlViewContentModeCenter:
                    make.centerY.equalTo(self);
                    break;
                case VESliderControlViewContentModeTop:
                    make.top.equalTo(self).with.offset(-((retThumbImageHeight - retThumbHeight) / 2.0));;
                    break;
                case VESliderControlViewContentModeBottom:
                    make.bottom.equalTo(self).with.offset((retThumbImageHeight - retThumbHeight) / 2.0);
                    break;
                default:
                    break;
            }
            make.size.equalTo(@(CGSizeMake(retThumbImageWidth, retThumbImageHeight)));
        }];
        
        self.backView.layer.cornerRadius = retThumbHeight / 2.0f;
        [self layoutIfNeeded];
    }];
}

#pragma mark ----- public

- (void)setProgressValue:(CGFloat)progressValue {
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
    self.thumbView.image = image;

    [self.thumbView mas_updateConstraints:^(MASConstraintMaker *make) {
        switch (self.contentMode) {
            case VESliderControlViewContentModeCenter:
                make.centerY.equalTo(self);
                break;
            case VESliderControlViewContentModeTop:
                make.top.equalTo(self).with.offset(-((self.thumbImage.size.height - self.thumbHeight) / 2.0));;
                break;
            case VESliderControlViewContentModeBottom:
                make.bottom.equalTo(self).with.offset((self.thumbImage.size.height - self.thumbHeight) / 2.0);
                break;
            default:
                break;
        }
        make.size.equalTo(@(CGSizeMake(self.thumbImage.size.width, self.thumbImage.size.height)));
    }];
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

#pragma mark ----- UIResponder

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGPoint touchPoint = [[touches anyObject] locationInView:self];
    self.beginPoint = touchPoint;
    self.touching = NO;
    self.beginValue = 0.0;
    [self _progressScaleLayout:YES];
    [self _progressWillChangeStart];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGPoint touchPoint = [[touches anyObject] locationInView:self];
    CGFloat movedX = touchPoint.x - self.beginPoint.x;
    if (!self.touching && (ABS(movedX) > 13)) {
        self.touching = YES;
        self.beginValue = movedX;
    }
    [self checkEventByMovedX:movedX movedEnd:NO];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGPoint touchPoint = [[touches anyObject] locationInView:self];
    CGFloat movedX = touchPoint.x - self.beginPoint.x;
    if (CGPointEqualToPoint(self.beginPoint, touchPoint)) {
        [self singleTapEventByMovedX:touchPoint.x];
        [self _progressScaleLayout:NO];
        return;
    }
    [self checkEventByMovedX:movedX movedEnd:YES];
    self.touching = NO;
    [self _progressScaleLayout:NO];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.touching = NO;
    [self _progressSlideCancel];
    [self _progressScaleLayout:NO];
}

- (void)singleTapEventByMovedX:(CGFloat)movedX {
    movedX -= self.thumbOffset;
    CGFloat totalWidth = self.backView.frame.size.width ?: 0.0;
    self.progressValue = (movedX / totalWidth);
    [self _progressValueChanged:self.progressValue];
}

- (void)checkEventByMovedX:(CGFloat)movedX movedEnd:(BOOL)isEnd {
    if (self.touching) {
        CGFloat changeValue = (movedX - self.beginValue) / (100 * self.sliderCoefficient);
        self.beginValue = movedX;
        self.progressValue += changeValue;
        if (isEnd) {
            [self _progressValueChanged:self.progressValue];
        } else {
            [self _progressValueChanging:self.progressValue];
        }
    } else {
        [self _progressSlideCancel];
    }
}

#pragma mark ----- Hit Test

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    CGRect bounds = self.bounds;
    bounds = CGRectInset(bounds, -0.5 * self.extendTouchSize.width, -0.5 * self.extendTouchSize.height);
    return CGRectContainsPoint(bounds, point);
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    return NO;
}

#pragma mark ----- Lazy Load

- (UIView *)backView {
    if (!_backView) {
        _backView = [UIView new];
        _backView.backgroundColor = [UIColor whiteColor];
        _backView.clipsToBounds = YES;
        _backView.layer.cornerRadius = self.thumbHeight / 2.0f;
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
        _thumbView = [[UIImageView alloc] initWithImage:self.thumbImage];
    }
    return _thumbView;
}

@end
