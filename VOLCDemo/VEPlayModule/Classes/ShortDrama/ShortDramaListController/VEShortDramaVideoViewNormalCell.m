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
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.desLablel];
    
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
}

- (void)setDramaInfoModel:(VEDramaInfoModel *)dramaInfoModel {
    _dramaInfoModel = dramaInfoModel;
    self.titleLabel.text = [NSString stringWithFormat:@"%@", dramaInfoModel.dramaTitle];
    self.desLablel.text = [NSString stringWithFormat:@"%@", dramaInfoModel.dramaDes];
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

@end
