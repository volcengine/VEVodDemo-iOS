//
//  ShortDramaSelectionView.m
//  VEPlayModule
//

#import "ShortDramaSelectionView.h"
#import <Masonry/Masonry.h>
#import "VEDramaVideoInfoModel.h"

@interface ShortDramaSelectionView ()

@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *arrowImageView;

@end

@implementation ShortDramaSelectionView

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
    [self addSubview:self.arrowImageView];
    
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).with.offset(16);
        make.centerY.equalTo(self);
    }];
    
    [self.arrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).with.offset(-16);
        make.centerY.equalTo(self);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).with.offset(45);
        make.right.equalTo(self).with.offset(-50);
        make.centerY.equalTo(self);
    }];
    
    
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickHandle)];
    [self addGestureRecognizer:tapGes];
}

#pragma mark - Event

- (void)onClickHandle {
    if (self.delegate && [self.delegate respondsToSelector:@selector(onClickDramaSelectionCallback)]) {
        [self.delegate onClickDramaSelectionCallback];
    }
}

#pragma mark - public

- (void)reloadData:(id)dataObj {
    VEDramaVideoInfoModel *dramaVideoInfo = (VEDramaVideoInfoModel *)dataObj;
    self.titleLabel.text = [NSString stringWithFormat:@"选集（%@集）", @(dramaVideoInfo.dramaEpisodeInfo.dramaInfo.totalEpisodeNumber)];
}

- (void)closePlayer {
    
}

#pragma mark - lazy load

- (UIImageView *)iconImageView {
    if (_iconImageView == nil) {
        _iconImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_drama_selec"]];
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

- (UIImageView *)arrowImageView {
    if (_arrowImageView == nil) {
        _arrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_up_arrow"]];
    }
    return _arrowImageView;
}

@end
