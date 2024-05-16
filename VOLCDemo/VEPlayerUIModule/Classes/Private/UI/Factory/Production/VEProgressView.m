//
//  VEProgressView.m
//  VEPlayerUIModule
//
//  Created by real on 2021/11/18.
//

#import "VEProgressView.h"
#import <Masonry/Masonry.h>
#import "UIView+VEElementDescripition.h"
#import "VEInterfaceElementDescription.h"
#import "VEProgressSlider.h"
#import "VEEventConst.h"

@interface VEProgressView () <VEProgressSliderDelegate>

@property (nonatomic, strong) UILabel *totalValueLabel; // protrait

@property (nonatomic, strong) UILabel *currentValueLabel; // protrait

@property (nonatomic, strong) UILabel *allValueLabel; // landscape

@property (nonatomic, assign) BOOL autoBackStartPoint;

@property (nonatomic, strong) VEProgressSlider *progressSlider;

@property (nonatomic, copy) void (^valueChanged)(CGFloat);

@end

@implementation VEProgressView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initializeElements];
        [self registEvents];
    }
    return self;
}

- (void)initializeElements {
    [self addSubview:self.totalValueLabel];
    [self addSubview:self.currentValueLabel];
    [self addSubview:self.allValueLabel];
    [self addSubview:self.progressSlider];
    self.currentOrientation = UIInterfaceOrientationPortrait;
}

- (void)layoutElements {
    if (self.currentOrientation == UIInterfaceOrientationLandscapeRight) {
        self.totalValueLabel.hidden = YES;
        self.currentValueLabel.hidden = YES;
        self.allValueLabel.hidden = NO;
        [self.progressSlider mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.centerY.equalTo(self);
            make.height.equalTo(@25.0);
        }];
        [self.allValueLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.progressSlider.mas_top);
            make.leading.equalTo(self.progressSlider.mas_leading).offset(12.0);
            make.top.trailing.equalTo(self);
        }];
    } else {
        self.totalValueLabel.hidden = NO;
        self.currentValueLabel.hidden = NO;
        self.allValueLabel.hidden = YES;
        [self.currentValueLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self);
            make.centerY.equalTo(self);
            make.width.equalTo(@55.0);
            make.height.equalTo(@25.0);
        }];
        [self.totalValueLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.trailing.equalTo(self);
            make.centerY.equalTo(self);
            make.width.equalTo(@55.0);
            make.height.equalTo(@25.0);
        }];
        [self.progressSlider mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self.currentValueLabel.mas_trailing);
            make.trailing.equalTo(self.totalValueLabel.mas_leading);
            make.centerY.equalTo(self);
            make.height.equalTo(@50.0);
        }];
    }
}

- (void)registEvents {
    [[VEEventMessageBus universalBus] registEvent:VEPlayEventProgressValueIncrease withAction:@selector(sliderValueIncrease:) ofTarget:self];
}


#pragma mark ----- Action

- (void)sliderValueIncrease:(id)param {
    if ([param isKindOfClass:[NSDictionary class]]) {
        NSDictionary *paramDic = (NSDictionary *)param;
        id value = paramDic.allValues.firstObject;
        if ([value isKindOfClass:[NSNumber class]]) {
            CGFloat increaseValue = [(NSNumber *)value floatValue];
            self.progressSlider.progressValue += increaseValue;
            NSString *currentValueForDisplay = [self intervalForDisplay:(self.progressSlider.progressValue * self.totalValue)];
            NSString *totalValueForDisplay = [self intervalForDisplay:self.totalValue];
            self.currentValueLabel.text = [NSString stringWithFormat:@"%@", currentValueForDisplay];
            self.allValueLabel.text = [NSString stringWithFormat:@"%@ / %@", currentValueForDisplay, totalValueForDisplay];
            [self progressManualChanged:self.progressSlider.progressValue];
        }
    }
}


#pragma mark ----- Setter

- (void)setCurrentOrientation:(UIInterfaceOrientation)currentOrientation {
    if (_currentOrientation != currentOrientation) {
        _currentOrientation = currentOrientation;
        [self layoutElements];
        self.currentValue = (self.progressSlider.progressValue * self.totalValue);
        self.bufferValue = (self.progressSlider.bufferValue * self.totalValue);
    }
}

- (void)setCurrentValue:(NSTimeInterval)currentValue {
    if (self.autoBackStartPoint && currentValue >= self.totalValue) {
        currentValue = 0.0;
    }
    currentValue = MAX(0.0, MIN(currentValue, self.totalValue));
    _currentValue = currentValue;
    NSString *currentValueForDisplay = [self intervalForDisplay:currentValue];
    NSString *totalValueForDisplay = [self intervalForDisplay:self.totalValue];
    self.currentValueLabel.text = [NSString stringWithFormat:@"%@", currentValueForDisplay];
    self.allValueLabel.text = [NSString stringWithFormat:@"%@ / %@", currentValueForDisplay, totalValueForDisplay];
    CGFloat rate = currentValue / self.totalValue;
    self.progressSlider.progressValue = rate;
}

- (void)setBufferValue:(NSTimeInterval)bufferValue {
    bufferValue = MAX(0.0, MIN(bufferValue, self.totalValue));
    _bufferValue = bufferValue;
    CGFloat rate = bufferValue / self.totalValue;
    self.progressSlider.bufferValue = rate;
}

- (void)setTotalValue:(NSTimeInterval)totalValue {
    _totalValue = totalValue;
    self.totalValueLabel.text = [NSString stringWithFormat:@"%@", [self intervalForDisplay:totalValue]];
}


#pragma mark ----- Lazy Load

- (UILabel *)totalValueLabel {
    if (!_totalValueLabel) {
        _totalValueLabel = [UILabel new];
        _totalValueLabel.textAlignment = NSTextAlignmentLeft;
        _totalValueLabel.font = [UIFont boldSystemFontOfSize:11.0];
        _totalValueLabel.textColor = [UIColor whiteColor];
    }
    return _totalValueLabel;
}

- (UILabel *)currentValueLabel {
    if (!_currentValueLabel) {
        _currentValueLabel = [UILabel new];
        _currentValueLabel.textAlignment = NSTextAlignmentRight;
        _currentValueLabel.font = [UIFont boldSystemFontOfSize:11.0];
        _currentValueLabel.textColor = [UIColor whiteColor];
    }
    return _currentValueLabel;
}

- (UILabel *)allValueLabel {
    if (!_allValueLabel) {
        _allValueLabel = [UILabel new];
        _allValueLabel.textAlignment = NSTextAlignmentLeft;
        _allValueLabel.font = [UIFont boldSystemFontOfSize:11.0];
        _allValueLabel.textColor = [UIColor whiteColor];
    }
    return _allValueLabel;
}

- (VEProgressSlider *)progressSlider {
    if (!_progressSlider) {
        _progressSlider = [VEProgressSlider new];
        _progressSlider.delegate = self;
        _progressSlider.progressValue = 0.0;
        [_progressSlider setProgressColor:[UIColor colorWithWhite:1.0 alpha:0.8]];
        [_progressSlider setProgressBufferColor:[UIColor colorWithWhite:1.0 alpha:0.32]];
        [_progressSlider setProgressBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.16]];
        [_progressSlider setThumbImage:[UIImage imageNamed:@"video_slide_dragbar"]];
    }
    return _progressSlider;
}

- (void)progressManualChanged:(CGFloat)value {
    NSString *currentValueForDisplay = [self intervalForDisplay:(self.progressSlider.progressValue * self.totalValue)];
    NSString *totalValueForDisplay = [self intervalForDisplay:self.totalValue];
    self.currentValueLabel.text = [NSString stringWithFormat:@"%@", currentValueForDisplay];
    self.allValueLabel.text = [NSString stringWithFormat:@"%@ / %@", currentValueForDisplay, totalValueForDisplay];
    if (self.valueChanged) {
        self.valueChanged(value);
    }
}


#pragma mark ----- Tool

- (NSString *)intervalForDisplay:(NSTimeInterval)interval {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.locale = [NSLocale systemLocale];
    formatter.calendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    if (interval > 3601) {
        [formatter setDateFormat:@"HH:mm:ss"];
    } else {
        [formatter setDateFormat:@"mm:ss"];
    }
    [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:interval];
    NSString *dateString = [formatter stringFromDate:date];
    return dateString;
}


#pragma mark ----- VEInterfaceFactoryProduction

- (void)elementViewAction {
    self.valueChanged = ^(CGFloat sliderValue) {
        NSTimeInterval destination = [[VEEventPoster currentPoster] duration] * sliderValue * 1.000;
        [[VEEventMessageBus universalBus] postEvent:VEPlayEventSeek withObject:@(destination) rightNow:YES];
    };
}

- (void)elementViewEventNotify:(id)param {
    if ([param isKindOfClass:[NSDictionary class]]) {
        NSDictionary *paramDic = (NSDictionary *)param;
        if (self.elementDescription.elementNotify) {
            self.elementDescription.elementNotify(self, [[paramDic allKeys] firstObject], [[paramDic allValues] firstObject]);
        }
    }
}

- (BOOL)isEnableZone:(CGPoint)point {
    if (self.hidden) {
        return NO;
    }
    if (CGRectContainsPoint(self.frame, point)) {
        return YES;
    }
    return NO;
}

@end
