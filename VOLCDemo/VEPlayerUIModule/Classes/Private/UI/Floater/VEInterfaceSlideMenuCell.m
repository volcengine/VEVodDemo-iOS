//
//  VEInterfaceSlideMenuCell.m
//  VEPlayerUIModule
//
//  Created by real on 2021/11/16.
//

#import "VEInterfaceSlideMenuCell.h"
#import "VEInterfaceElementDescription.h"
#import "UIView+VEElementDescripition.h"
#import "Masonry.h"

@implementation VEInterfaceSlideMenuCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initializeElements];
    }
    return self;
}

- (void)initializeElements {
    [self.contentView addSubview:self.iconImgView];
    [self.contentView addSubview:self.titleLabel];
    
    [self.iconImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView);
        make.leading.equalTo(self.contentView).offset(7.5);
        make.trailing.equalTo(self.contentView).offset(-7.5);;
        make.height.equalTo(@(45.0)); // width
    }];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.iconImgView.mas_bottom);
        make.leading.trailing.bottom.equalTo(self.contentView);
    }];
}


#pragma mark ----- Lazy Load

- (UIImageView *)iconImgView {
    if (!_iconImgView) {
        _iconImgView = [UIImageView new];
    }
    return _iconImgView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.highlighted = YES;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont systemFontOfSize:9.0];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.tintColor = [UIColor lightGrayColor];
    }
    return _titleLabel;
}

@end
