//
//  VEPlayerSubtitleView.m
//

#import "VEPlayerSubtitleView.h"
#import <Masonry/Masonry.h>

@interface VEPlayerSubtitleView ()

@property (nonatomic, strong) UILabel *subtitleLabel;
@property (nonatomic, strong) UILabel *subtitleLabelOutline;

@end

@implementation VEPlayerSubtitleView

- (instancetype)init {
    self = [super init];
    if (self) {
        _fontSize = 20;
        _textColor = [UIColor whiteColor];
        _strokeColor = [UIColor blackColor];
        [self configuratoinCustomView];
    }
    return self;
}

#pragma mark - UI

- (void)configuratoinCustomView {
    self.backgroundColor = [UIColor clearColor];

    [self addSubview:self.subtitleLabelOutline];
    [self insertSubview:self.subtitleLabel aboveSubview:self.subtitleLabelOutline];

    [self.subtitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self);
        make.trailing.equalTo(self);
        make.bottom.equalTo(self).offset(0);
        make.height.mas_greaterThanOrEqualTo(@25);
    }];

    [self.subtitleLabelOutline mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.bottom.equalTo(self.subtitleLabel);
    }];
}

#pragma mark - Setter

- (void)setFontSize:(CGFloat)fontSize {
    _fontSize = fontSize;
    self.subtitleLabel.font = [UIFont systemFontOfSize:fontSize];
}

- (void)setTextColor:(UIColor *)textColor {
    _textColor = textColor;
    self.subtitleLabel.textColor = textColor;
}

#pragma mark - lazy load

- (UILabel *)subtitleLabel {
    if (_subtitleLabel == nil) {
        _subtitleLabel = [[UILabel alloc] init];
        _subtitleLabel.textAlignment = NSTextAlignmentCenter;
        _subtitleLabel.numberOfLines = 0;
        _subtitleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _subtitleLabel.textColor = self.textColor;
        _subtitleLabel.backgroundColor = [UIColor clearColor];
        _subtitleLabel.font = [UIFont systemFontOfSize:self.fontSize];
        _subtitleLabel.text = @"";
    }
    return _subtitleLabel;
}

- (UILabel *)subtitleLabelOutline {
    if (_subtitleLabelOutline == nil) {
        _subtitleLabelOutline = [[UILabel alloc] init];
        _subtitleLabelOutline.textAlignment = NSTextAlignmentCenter;
        _subtitleLabelOutline.numberOfLines = 0;
        _subtitleLabelOutline.lineBreakMode = NSLineBreakByWordWrapping;
        _subtitleLabelOutline.backgroundColor = [UIColor clearColor];
        _subtitleLabelOutline.font = [UIFont systemFontOfSize:self.fontSize];
        _subtitleLabelOutline.text = @"";
    }
    return _subtitleLabelOutline;
}

- (void)setSubtitle:(NSString *)subtitle {
    self.subtitleLabel.text = subtitle;
    self.subtitleLabelOutline.attributedText = [VEPlayerSubtitleView outlineText:subtitle fontSize:self.fontSize foregroundColor:self.textColor strokeColor:self.strokeColor strokeWidth:3.0 shadowColor:self.strokeColor shadowOffset:CGSizeMake(1, 1)];
}

+ (NSAttributedString *)outlineText:(NSString *)text
                            fontSize:(CGFloat)fontSize
                   foregroundColor:(UIColor *)foregroundColor
                     strokeColor:(UIColor *)strokeColor
                    strokeWidth:(CGFloat)strokeWidth
                      shadowColor:(UIColor *)shadowColor
                     shadowOffset:(CGSize)shadowOffset {
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowColor = shadowColor;
    shadow.shadowOffset = shadowOffset;
    shadow.shadowBlurRadius = 1.0;

    NSDictionary *attributes = @{
        NSStrokeColorAttributeName: strokeColor ?: [UIColor whiteColor],
        NSForegroundColorAttributeName: foregroundColor ?: [UIColor blackColor],
        NSStrokeWidthAttributeName: @(strokeWidth),
        NSFontAttributeName: [UIFont systemFontOfSize:fontSize],
        NSShadowAttributeName: shadow
    };

    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:text attributes:attributes];
    return attributedText;
}

@end
