//
//  ShortDramaIntroduceView.m
//  JSONModel
//

#import "ShortDramaIntroduceView.h"
#import <Masonry/Masonry.h>
#import "VEDramaVideoInfoModel.h"

@interface ShortDramaIntroduceView ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *desLabel;

@end

@implementation ShortDramaIntroduceView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self configuratoinCustomView];
    }
    return self;
}

- (void)reloadData:(id)dataObj {
    VEDramaVideoInfoModel *dramaVideoInfo = (VEDramaVideoInfoModel *)dataObj;
    self.titleLabel.text = dramaVideoInfo.dramaEpisodeInfo.dramaInfo.dramaTitle;
    self.desLabel.text = dramaVideoInfo.dramaEpisodeInfo.episodeDesc;
}

- (void)closePlayer {
    
}

- (void)configuratoinCustomView {
    [self addSubview:self.titleLabel];
    [self addSubview:self.desLabel];
    
    [self.desLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.equalTo(self);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.bottom.equalTo(self.desLabel.mas_top).with.offset(-12);
    }];
}

#pragma mark - lazy load

- (UILabel *)titleLabel {
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.font = [UIFont boldSystemFontOfSize:17];
    }
    return _titleLabel;
}

- (UILabel *)desLabel {
    if (_desLabel == nil) {
        _desLabel = [[UILabel alloc] init];
        _desLabel.textColor = [UIColor whiteColor];
        _desLabel.font = [UIFont systemFontOfSize:15];
        _desLabel.numberOfLines = 0;
    }
    return _desLabel;
}

@end
