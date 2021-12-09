//
//  VEPlayerSliderControlView.m
//  VOLCDemo
//
//  Created by wangzhiyong on 2021/5/31.
//  Copyright © 2021 ByteDance. All rights reserved.
//

#import "VEPlayerSliderControlView.h"

NSInteger const kSliderHeight = 3;
NSInteger const kThumbViewWidth = 14;

@interface VEPlayerSliderControlView ()

@property (nonatomic, strong) UIView *thumbView;
@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UIView *trackProgressView;
@property (nonatomic, strong) UIView *cacheProgressView;

@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;

@property (nonatomic, readwrite) CGFloat progress;
@property (nonatomic, readwrite) CGFloat cacheProgress;

@property (nonatomic, readwrite, getter=isInteractive) BOOL interactive;

@end


@implementation VEPlayerSliderControlView {
    CGFloat _progressBeforeDragging;
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"bounds"];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self _buildViewHierarchy];
        [self _buildBindings];
        [self _buildGestures];
    }
    return self;
}


#pragma mark - UI

- (void)layoutSubviews {
    [super layoutSubviews];
    [self _updateLayout];
}

- (void)_buildBindings {
    [self addObserver:self forKeyPath:@"bounds" options:NSKeyValueObservingOptionOld context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"bounds"]) {
        [self _updateLayout];
        [self _updateCacheProgress];
        [self _updateTrackProgress];
    }
}

- (void)_buildViewHierarchy {
    [self addSubview:self.backgroundView];
    [self addSubview:self.thumbView];
    [self.backgroundView addSubview:self.cacheProgressView];
    [self.backgroundView addSubview:self.trackProgressView];
}

- (void)_buildGestures {
    [self addGestureRecognizer:self.panGesture];
}

- (void)_updateLayout {
    CGRect frame;
    frame.size.width = self.frame.size.width;
    frame.size.height = kSliderHeight;
    frame.origin.x = self.frame.size.width/2 - frame.size.width/2;
    frame.origin.y = self.frame.size.height/2 - frame.size.height/2;
    self.backgroundView.frame = frame;
    
    self.trackProgressView.frame = CGRectMake(self.trackProgressView.frame.origin.x, self.trackProgressView.frame.origin.y, self.trackProgressView.frame.size.width, self.backgroundView.frame.size.height);
    self.cacheProgressView.frame = CGRectMake(self.cacheProgressView.frame.origin.x, self.cacheProgressView.frame.origin.y, self.cacheProgressView.frame.size.width, self.backgroundView.frame.size.height);

    self.thumbView.center = CGPointMake(self.thumbView.center.x, self.backgroundView.center.y);
}

- (void)_updateCacheProgress {
    CGRect frame = self.cacheProgressView.frame;
    frame.size.width = self.backgroundView.frame.size.width * self.cacheProgress;
    self.cacheProgressView.frame = frame;
}

- (void)_updateTrackProgress {
    CGRect frame = self.trackProgressView.frame;
    frame.size.width = self.backgroundView.frame.size.width * self.progress;
    self.trackProgressView.frame = frame;
    [self _updateThumbPosition];
}

- (void)_updateThumbPosition {
    CGFloat minCenterX = kThumbViewWidth / 2;
    CGFloat maxCenterX = self.backgroundView.frame.size.width - kThumbViewWidth / 2;
    self.thumbView.center = CGPointMake([self _maxProgressWidth] * self.progress + minCenterX, self.thumbView.center.y);
    self.thumbView.center = CGPointMake(MIN(maxCenterX, MAX(minCenterX, self.thumbView.center.x)), self.thumbView.center.y);
}

- (CGFloat)_maxProgressWidth {
    return self.backgroundView.frame.size.width - kThumbViewWidth;
}

#pragma mark Public

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated {
    progress = MIN(1, MAX(0, progress));
    self.progress = progress;
    [UIView animateWithDuration:animated ? 0.3 : 0.0 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        [self _updateTrackProgress];
    } completion:nil];
}

- (void)setCacheProgress:(CGFloat)progress animated:(BOOL)animated {
    progress = MIN(1, MAX(0, progress));
    self.cacheProgress = progress;
    [UIView animateWithDuration:animated ? 0.3 : 0.0 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        [self _updateCacheProgress];
    } completion:nil];
}


#pragma mark Private

- (void)_handleGestureRecognizer:(UIPanGestureRecognizer *)pan {
    UIGestureRecognizerState state = pan.state;
    CGPoint translate = [pan translationInView:self];
    
    switch (state) {
        case UIGestureRecognizerStateBegan: {
            self.interactive = YES;
            _progressBeforeDragging = self.progress;
            [UIView animateWithDuration:0.3 animations:^{
                self.thumbView.transform = CGAffineTransformMakeScale(1.3, 1.3);
            }];
            if (self.delegate && [self.delegate respondsToSelector:@selector(sliderWillDragingProgress:)]) {
                [self.delegate sliderWillDragingProgress:self.progress];
            }
        }
            break;
        case UIGestureRecognizerStateChanged: {
            CGFloat progressDelta = translate.x / [self _maxProgressWidth];
            CGFloat newProgress = _progressBeforeDragging + progressDelta;
            [self setProgress:newProgress animated:NO];
            if (self.delegate && [self.delegate respondsToSelector:@selector(sliderProgressValueChanged:)]) {
                [self.delegate sliderProgressValueChanged:newProgress];
            }
        }
            break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateFailed: {
            [UIView animateWithDuration:0.3 animations:^{
                self.thumbView.transform = CGAffineTransformIdentity;
            }];
            if (self.delegate && [self.delegate respondsToSelector:@selector(sliderDidSeekToProgress:)]) {
                [self.delegate sliderDidSeekToProgress:self.progress];
            }
            self.interactive = NO;
        }
            break;
        default:
            break;
    }
}


#pragma mark lazy load

- (UIView *)thumbView {
    if (!_thumbView) {
        _thumbView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kThumbViewWidth, kThumbViewWidth)];
        _thumbView.layer.cornerRadius = kThumbViewWidth / 2;
        _thumbView.backgroundColor = [UIColor whiteColor];
        _thumbView.layer.shadowOffset = CGSizeMake(0, 2);
        _thumbView.layer.shadowOpacity = 0.4;
        _thumbView.layer.shadowRadius = 1;
        UIBezierPath *shadowPath = [UIBezierPath bezierPathWithOvalInRect:_thumbView.bounds];
        _thumbView.layer.shadowPath = shadowPath.CGPath;
        _thumbView.userInteractionEnabled = NO;
    }
    return _thumbView;
}

- (UIView *)backgroundView {
    if (!_backgroundView) {
        _backgroundView = [[UIView alloc] init];
        _backgroundView.layer.cornerRadius = kSliderHeight / 2;
        _backgroundView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.1];
    }
    return _backgroundView;
}

- (UIView *)trackProgressView {
    if (!_trackProgressView) {
        _trackProgressView = [[UIView alloc] init];
        _trackProgressView.backgroundColor = [UIColor redColor];
        _trackProgressView.layer.cornerRadius = kSliderHeight / 2;
    }
    return _trackProgressView;
}

- (UIView *)cacheProgressView {
    if (!_cacheProgressView) {
        _cacheProgressView = [[UIView alloc] init];
        _cacheProgressView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.5];
        _cacheProgressView.layer.cornerRadius = kSliderHeight / 2;
    }
    return _cacheProgressView;
}

- (UIPanGestureRecognizer *)panGesture {
    if (!_panGesture) {
        _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_handleGestureRecognizer:)];
    }
    return _panGesture;
}

@end
