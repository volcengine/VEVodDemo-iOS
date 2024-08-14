//
//  ShortDramaSpeedTipView.m
//  VEPlayModule
//
//  Created by zyw on 2024/7/16.
//

#import "ShortDramaSpeedTipView.h"
#import <Masonry/Masonry.h>

@interface ShortDramaSpeedTipView ()

@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation ShortDramaSpeedTipView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self configuratoinCustomView];
    }
    return self;
}

- (void)configuratoinCustomView {
    self.layer.cornerRadius = 8;
    self.layer.masksToBounds = YES;
    self.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.15];
    
    [self addSubview:self.iconImageView];
    [self addSubview:self.titleLabel];
    
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).with.offset(16);
        make.centerY.equalTo(self);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.iconImageView.mas_right).with.offset(3);
        make.right.equalTo(self).with.offset(-16);
        make.centerY.equalTo(self);
    }];
}

#pragma mark - Public

- (void)showSpeedView:(NSString *)tip {
    [self.iconImageView startAnimating];
    self.titleLabel.text = tip;
    [UIView animateWithDuration:0.5f animations:^{
        self.alpha = 1.0;
    }];
}

- (void)hiddenSpeedView {
    [self.iconImageView stopAnimating];
    [UIView animateWithDuration:0.5f animations:^{
        self.alpha = 0;
    }];
}

#pragma mark - Getter

- (UIImageView *)iconImageView {
    if (_iconImageView == nil) {
        NSArray *imageArray = @[[UIImage imageNamed:@"icon_speed_0"], [UIImage imageNamed:@"icon_speed_1"]];
        _iconImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_speed_0"]];
        _iconImageView.animationImages = imageArray;
        _iconImageView.contentMode = UIViewContentModeScaleAspectFit;
        _iconImageView.animationRepeatCount = 0;
        _iconImageView.animationDuration = .5f;
    }
    return _iconImageView;
}

- (UILabel *)titleLabel {
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:13];
        _titleLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.9];
    }
    return _titleLabel;
}

@end
