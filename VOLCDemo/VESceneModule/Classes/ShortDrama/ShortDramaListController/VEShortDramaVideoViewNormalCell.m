//
//  VEShortDramaVideoViewNormalCell.m
//  VOLCDemo
//

#import "VEShortDramaVideoViewNormalCell.h"
#import "VEDramaInfoModel.h"
#import <SDWebImage/SDWebImage.h>
#import "UIColor+RGB.h"
#import <Masonry/Masonry.h>

@interface VEShortDramaVideoViewNormalCell ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *desLablel;
@property (nonatomic, strong) UILabel *playCountLabel;
@property (nonatomic, strong) UIImageView *playIconImageView;
@property (nonatomic, strong) UIImageView *coverImageView;

@end

@implementation VEShortDramaVideoViewNormalCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        [self configuratoinCustomView];
    }
    return self;
}

- (void)configuratoinCustomView {
    [self.contentView addSubview:self.imageView];
    [self.imageView addSubview:self.coverImageView];
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.desLablel];
    [self.contentView addSubview:self.playCountLabel];
    [self.contentView addSubview:self.playIconImageView];
    
    [self.desLablel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.equalTo(self.contentView);
        make.height.mas_equalTo(18);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.contentView);
        make.bottom.equalTo(self.desLablel.mas_top);
        make.height.mas_equalTo(22);
    }];
    
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.contentView);
        make.bottom.equalTo(self.titleLabel.mas_top).with.offset(-8);
    }];
    
    [self.coverImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.equalTo(self.imageView);
    }];
    
    [self.playIconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.imageView.mas_bottom).with.offset(-6);
        make.left.equalTo(self.imageView.mas_left).with.offset(8);
    }];
    
    [self.playCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.playIconImageView.mas_right).with.offset(3);
        make.centerY.equalTo(self.playIconImageView).with.offset(-2);;
    }];
}

- (void)setDramaInfoModel:(VEDramaInfoModel *)dramaInfoModel {
    _dramaInfoModel = dramaInfoModel;
    self.titleLabel.text = [NSString stringWithFormat:@"%@", dramaInfoModel.dramaTitle];
    self.desLablel.text = [NSString stringWithFormat:@"更新至%@集", @(dramaInfoModel.latestEpisodeNumber)];
    CGFloat random = (arc4random() % 99) / 3.0 + 1;
    self.playCountLabel.text = [NSString stringWithFormat:@"%.1f万", random];
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:dramaInfoModel.coverUrl]];
}

#pragma mark - lazy load

- (UIImageView *)imageView {
    if (_imageView == nil) {
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.layer.cornerRadius = 8;
        _imageView.layer.masksToBounds = YES;
    }
    return _imageView;
}

- (UILabel *)titleLabel {
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont boldSystemFontOfSize:15];
        _titleLabel.textColor = [UIColor colorWithRGB:0x161823 alpha:1.0];
    }
    return _titleLabel;
}

- (UILabel *)desLablel {
    if (_desLablel == nil) {
        _desLablel = [[UILabel alloc] init];
        _desLablel.font = [UIFont systemFontOfSize:12];
        _desLablel.textColor = [UIColor colorWithRGB:0x161823 alpha:1.0];
    }
    return _desLablel;
}

- (UILabel *)playCountLabel {
    if (_playCountLabel == nil) {
        _playCountLabel = [[UILabel alloc] init];
        _playCountLabel.font = [UIFont systemFontOfSize:12];
        _playCountLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.9];
    }
    return _playCountLabel;
}

- (UIImageView *)playIconImageView {
    if (_playIconImageView == nil) {
        _playIconImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_play_sign"]];
    }
    return _playIconImageView;
}

- (UIImageView *)coverImageView {
    if (_coverImageView == nil) {
        _coverImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_drama_list_cover"]];
    }
    return _coverImageView;
}

@end
