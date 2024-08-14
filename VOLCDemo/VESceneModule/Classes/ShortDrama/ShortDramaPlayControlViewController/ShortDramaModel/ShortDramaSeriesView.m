//
//  ShortDramaSeriesView.m
//  JSONModel
//

#import "ShortDramaSeriesView.h"
#import "UIColor+RGB.h"
#import <Masonry/Masonry.h>
#import "VEDramaVideoInfoModel.h"

@interface ShortDramaSeriesView ()

@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *dramaButton;

@end

@implementation ShortDramaSeriesView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self configuratoinCustomView];
    }
    return self;
}

- (void)reloadData:(VEDramaVideoInfoModel *)dramaVideoInfo {
    self.titleLabel.text = [NSString stringWithFormat:@"观看完整短剧 · 全%@集", @(dramaVideoInfo.dramaEpisodeInfo.dramaInfo.totalEpisodeNumber)];
}

#pragma mark - UI

- (void)configuratoinCustomView {
    self.backgroundColor = [UIColor colorWithRGB:0x292929 alpha:.34];
    self.layer.cornerRadius = 8;
    self.layer.masksToBounds = YES;
    
    [self addSubview:self.iconImageView];
    [self addSubview:self.titleLabel];
    [self addSubview:self.dramaButton];
    
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.left.equalTo(self).with.offset(16);
        make.size.mas_equalTo(CGSizeMake(16, 16));
    }];
    
    [self.dramaButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.right.equalTo(self).with.offset(-16);
        make.size.mas_equalTo(CGSizeMake(68, 28));
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.left.equalTo(self.iconImageView.mas_right).with.offset(8);
        make.right.equalTo(self.dramaButton.mas_left).with.offset(-10);
    }];
}

#pragma mark - private

- (void)dramaButtonHandle:(UIButton *)button {
    if (self.delegate && [self.delegate respondsToSelector:@selector(onClickSeriesViewCallback)]) {
        [self.delegate onClickSeriesViewCallback];
    }
}

#pragma mark - lazy load

- (UIImageView *)iconImageView {
    if (_iconImageView == nil) {
        _iconImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_drama"]];
        _iconImageView.backgroundColor = [UIColor clearColor];
    }
    return _iconImageView;
}

- (UILabel *)titleLabel {
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.text = @"观看完整短剧";
        _titleLabel.font = [UIFont systemFontOfSize:13];
    }
    return _titleLabel;
}

- (UIButton *)dramaButton {
    if (_dramaButton == nil) {
        _dramaButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _dramaButton.layer.cornerRadius = 6;
        _dramaButton.layer.masksToBounds = YES;
        _dramaButton.titleLabel.font = [UIFont systemFontOfSize:12];
        _dramaButton.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.15];
        [_dramaButton setTitle:@"连续看" forState:UIControlStateNormal];
        [_dramaButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_dramaButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [_dramaButton addTarget:self action:@selector(dramaButtonHandle:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _dramaButton;
}

@end
