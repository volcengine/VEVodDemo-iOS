//
//  VELongVideoIntroduceView.m
//  VESceneModule
//
//  Created by zys on 2025/10/14.
//

#import "VELongVideoIntroduceView.h"
#import <Masonry/Masonry.h>

@interface VELongVideoIntroduceView ()

@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation VELongVideoIntroduceView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self configuratoinCustomView];
    }
    return self;
}

- (void)configuratoinCustomView {
    self.backgroundColor = [UIColor clearColor];
    [self addSubview:self.titleLabel];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.equalTo(self);
    }];
}

- (void)updateTitle:(NSString *)title {
    self.titleLabel.text = title;
}

#pragma mark - lazy load

- (UILabel *)titleLabel {
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.font = [UIFont systemFontOfSize:15];
        _titleLabel.numberOfLines = 1;
    }
    return _titleLabel;
}

@end
