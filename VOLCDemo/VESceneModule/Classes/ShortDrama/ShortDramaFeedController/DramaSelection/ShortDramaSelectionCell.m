//
//  ShortDramaSelectionCell.m
//  VEPlayModule
//

#import "ShortDramaSelectionCell.h"
#import "VEDramaVideoInfoModel.h"
#import "UIColor+RGB.h"
#import <Masonry/Masonry.h>

@interface ShortDramaSelectionCell ()

@property (nonatomic, strong) UIView *coverView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *playingImageView;
@property (nonatomic, strong) UIImageView *lockImageView;
@property (nonatomic, strong) UIView *tempImageView;

@end

@implementation ShortDramaSelectionCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self configuratoinCustomView];
    }
    return self;
}

- (void)configuratoinCustomView {
    [self.contentView addSubview:self.coverView];
    [self.contentView addSubview:self.playingImageView];
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.lockImageView];

    [self.coverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.contentView);
    }];

    [self.playingImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView.mas_right).with.offset(-5);
        make.bottom.equalTo(self.contentView.mas_bottom).with.offset(-5);
    }];
    
    [self.lockImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.equalTo(self.contentView);
        make.size.mas_equalTo(CGSizeMake(14, 14));
    }];
}

- (void)setDramaVideoInfo:(VEDramaVideoInfoModel *)dramaVideoInfo {
    _dramaVideoInfo = dramaVideoInfo;
    self.titleLabel.text = [NSString stringWithFormat:@"%@", @(dramaVideoInfo.dramaEpisodeInfo.episodeNumber)];
    
    BOOL showLock = (dramaVideoInfo.payInfo.payStatus == VEDramaPayStatus_Paid);
    self.lockImageView.hidden = showLock;
}

- (void)setCurPlayDramaVideoInfo:(VEDramaVideoInfoModel *)curPlayDramaVideoInfo {
    if (self.dramaVideoInfo.dramaEpisodeInfo.episodeNumber == curPlayDramaVideoInfo.dramaEpisodeInfo.episodeNumber) {
        self.coverView.layer.borderColor = [[UIColor colorWithRGB:0x1664FF alpha:1.0] CGColor];
        self.titleLabel.textColor = [UIColor colorWithRGB:0x1664FF alpha:1.0];
        self.playingImageView.hidden = NO;
    } else {
        self.coverView.layer.borderColor = [[UIColor colorWithRGB:0xF5F5F5 alpha:1.0] CGColor];
        self.titleLabel.textColor = [UIColor blackColor];
        self.playingImageView.hidden = YES;
    }
}

#pragma mark - lazy load

- (UIView *)coverView {
    if (_coverView == nil) {
        _coverView = [[UIView alloc] init];
        _coverView.backgroundColor = [UIColor colorWithRGB:0xF5F5F5 alpha:1.0];
        _coverView.layer.borderColor = [[UIColor colorWithRGB:0xF5F5F5 alpha:1.0] CGColor];
        _coverView.layer.borderWidth = 1;
        _coverView.layer.cornerRadius = 8;
        _coverView.layer.masksToBounds = YES;
    }
    return _coverView;
}

- (UILabel *)titleLabel {
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.font = [UIFont boldSystemFontOfSize:16];
    }
    return _titleLabel;
}

- (UIImageView *)playingImageView {
    if (_playingImageView == nil) {
        _playingImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_palying_drama"]];
    }
    return _playingImageView;
}

- (UIImageView *)lockImageView {
    if (_lockImageView == nil) {
        _lockImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_drama_lock"]];
    }
    return _lockImageView;
}

@end
