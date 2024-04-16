//
//  ShortDramaVideoPlayView.m
//  VEPlayModule
//

#import "ShortDramaVideoPlayView.h"
#import <Masonry/Masonry.h>

@interface ShortDramaVideoPlayView ()

@property (nonatomic, strong) UIImageView *playImageView;

@end

@implementation ShortDramaVideoPlayView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self configuratoinCustomView];
    }
    return self;
}

- (void)configuratoinCustomView {
    self.backgroundColor = [UIColor clearColor];
    [self addSubview:self.playImageView];
    [self.playImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
    }];
}

#pragma mark - lazy load

- (UIImageView *)playImageView {
    if (_playImageView == nil) {
        _playImageView = [[UIImageView alloc] init];
        [_playImageView setImage:[UIImage imageNamed:@"video_drama_play"]];
    }
    return _playImageView;
}

@end
