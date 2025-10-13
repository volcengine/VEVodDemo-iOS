//
//  VELongVideoOtherFunctionsView.m
//  VESceneModule
//
//  Created by zys on 2025/10/15.
//

#import "VELongVideoOtherFunctionsView.h"
#import "VEPlayerContextKeyDefine.h"
#import <Masonry/Masonry.h>

@interface VELongVideoOtherFunctionsView ()

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIButton *loopButton;
@property (nonatomic, strong) UILabel *loopLabel;
@property (nonatomic, assign) BOOL isLooping;

@end

@implementation VELongVideoOtherFunctionsView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self configuratoinCustomView];
    }
    return self;
}

- (void)configuratoinCustomView {
    self.backgroundColor = [UIColor clearColor];
    
    [self addSubview:self.containerView];
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self).multipliedBy(0.5);
        make.right.top.bottom.equalTo(self);
    }];
    
    [self.containerView addSubview:self.loopButton];
    [self.loopButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(40, 40));
        make.left.equalTo(self.containerView).offset(20);
        make.top.equalTo(self.containerView).offset(15);
    }];
    
    [self.containerView addSubview:self.loopLabel];
    [self.loopLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.loopButton);
        make.top.equalTo(self.loopButton.mas_bottom).offset(5);
        make.size.mas_equalTo(CGSizeMake(40, 10));
    }];
    
    self.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickView:)];
    [self addGestureRecognizer:tapGesture];
}

#pragma mark - lazy load

- (UIButton *)loopButton {
    if (!_loopButton) {
        _loopButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_loopButton setImage:[UIImage imageNamed:@"long_video_loopplay"] forState:UIControlStateNormal];
        [_loopButton addTarget:self action:@selector(onClickPlayButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _loopButton;
}

- (UIView *)containerView {
    if (!_containerView) {
        _containerView = [[UIView alloc] init];
        _containerView.backgroundColor = [UIColor blackColor];
        _containerView.alpha = 0.8;
    }
    return _containerView;
}

- (UILabel *)loopLabel {
    if (!_loopLabel) {
        _loopLabel = [[UILabel alloc] init];
        _loopLabel.text = @"循环播放";
        _loopLabel.font = [UIFont systemFontOfSize:10];
        _loopLabel.textColor = [UIColor whiteColor];
    }
    return _loopLabel;
}

#pragma mark - event

- (void)onClickPlayButton:(UIButton *)sender {
    if (self.isLooping) {
        [self.loopButton setImage:[UIImage imageNamed:@"long_video_loopplay"] forState:UIControlStateNormal];
        if (self.playerInterface != NULL) {
            self.playerInterface.looping = NO;
        }
    }else {
        [self.loopButton setImage:[UIImage imageNamed:@"long_video_loopplay_sel"] forState:UIControlStateNormal];
        if (self.playerInterface != NULL) {
            self.playerInterface.looping = YES;
        }
    }
    self.isLooping = !self.isLooping;
}

- (void)onClickView:(UITapGestureRecognizer *)gestureRecognizer {
    CGPoint touchPoint = [gestureRecognizer locationInView:self];
    CGFloat viewWidth = self.bounds.size.width;
    if (touchPoint.x < viewWidth / 2.0) {
        [self removeFromSuperview];
        if (self.context != NULL) {
            [self.context post:@(1) forKey:VEPlayerContextKeyViewVisible];
        }
    }
}

@end
