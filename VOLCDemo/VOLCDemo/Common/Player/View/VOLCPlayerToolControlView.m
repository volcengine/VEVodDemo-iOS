//
//  VOLCPlayerToolControlView.m
//  VOLCDemo
//
//  Created by wangzhiyong on 2021/5/31.
//  Copyright © 2021 ByteDance. All rights reserved.
//

#import "VOLCPlayerToolControlView.h"

@interface VOLCPlayerToolControlView ()

@property (nonatomic, strong) UIButton *debugButton;
@property (nonatomic, strong) UIButton *muteButton;
@property (nonatomic, strong) UIButton *audioButton;
@property (nonatomic, assign, readwrite) BOOL isDebugShow;
@property (nonatomic, assign, readwrite) BOOL isMuteOn;
@property (nonatomic, assign, readwrite) BOOL isAudioOn;

@end

@implementation VOLCPlayerToolControlView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.muteButton = [self __newButtonWithTitle:@"Mute" target:self handle:@selector(_muteButtonHandler:)];
        [self addSubview:self.muteButton];
        [self.muteButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self);
            make.centerY.equalTo(self);
            make.height.mas_equalTo(35);
        }];
        
        //audio btn
        self.audioButton = [self __newButtonWithTitle:@"Audio" target:self handle:@selector(_audioButtonHandler:)];
        [self addSubview:self.audioButton];
        [self.audioButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.muteButton.mas_right);
            make.centerY.equalTo(self);
            make.height.mas_equalTo(35);
            make.width.equalTo(self.muteButton);
        }];
        
        //debug tool btn
        self.debugButton = [self __newButtonWithTitle:@"ShowDebug" target:self handle:@selector(_debugButtonHandler:)];
        [self addSubview:self.debugButton];
        [self.debugButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.audioButton.mas_right);
            make.centerY.equalTo(self);
            make.height.mas_equalTo(35);
            make.width.equalTo(self.audioButton);
            make.right.equalTo(self);
        }];
    }
    return self;
}


#pragma mark - Public

- (void)reset {
    self.isAudioOn = NO;
    self.isMuteOn = NO;
    self.isDebugShow = NO;
    [self.audioButton setTitle:@"Audio" forState:UIControlStateNormal];
    [self.muteButton setTitle:@"Mute" forState:UIControlStateNormal];
    [self.debugButton setTitle:@"ShowDebug" forState:UIControlStateNormal];
}


#pragma mark - Private

- (void)_audioButtonHandler:(UIButton *)sender {
    if (!self.isAudioOn) {
        [self.audioButton setTitle:@"Video" forState:UIControlStateNormal];
        if (self.delegate && [self.delegate respondsToSelector:@selector(toolControlViewLogAudioButtonDidClicked:isAudio:)]) {
            [self.delegate toolControlViewLogAudioButtonDidClicked:self isAudio:YES];
        }
    } else {
        [self.audioButton setTitle:@"Audio" forState:UIControlStateNormal];
        if (self.delegate && [self.delegate respondsToSelector:@selector(toolControlViewLogAudioButtonDidClicked:isAudio:)]) {
            [self.delegate toolControlViewLogAudioButtonDidClicked:self isAudio:NO];
        }
    }
    self.isAudioOn = !self.isAudioOn;
}

- (void)_muteButtonHandler:(UIButton *)sender {
    if (!self.isMuteOn) {
        [self.muteButton setTitle:@"Unmute" forState:UIControlStateNormal];
        if (self.delegate && [self.delegate respondsToSelector:@selector(toolControlViewLogMuteButtonDidClicked:isMute:)]) {
            [self.delegate toolControlViewLogMuteButtonDidClicked:self isMute:YES];
        }
    } else {
        [self.muteButton setTitle:@"Mute" forState:UIControlStateNormal];
        if (self.delegate && [self.delegate respondsToSelector:@selector(toolControlViewLogMuteButtonDidClicked:isMute:)]) {
            [self.delegate toolControlViewLogMuteButtonDidClicked:self isMute:NO];
        }
    }
    self.isMuteOn = !self.isMuteOn;
}

- (void)_debugButtonHandler:(UIButton *)sender {
    if (!self.isDebugShow) {
        [self.debugButton setTitle:@"HideDebug" forState:UIControlStateNormal];
        if (self.delegate && [self.delegate respondsToSelector:@selector(toolControlViewDebugButtonDidClicked:isShow:)]) {
            [self.delegate toolControlViewDebugButtonDidClicked:self isShow:YES];
        }
    } else {
        [self.debugButton setTitle:@"ShowDebug" forState:UIControlStateNormal];
        if (self.delegate && [self.delegate respondsToSelector:@selector(toolControlViewDebugButtonDidClicked:isShow:)]) {
            [self.delegate toolControlViewDebugButtonDidClicked:self isShow:NO];
        }
    }
    self.isDebugShow = !self.isDebugShow;
}


#pragma mark - Private

- (UIButton *)__newButtonWithTitle:(NSString *)title target:(id)target handle:(SEL)selector {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = [[UIColor darkGrayColor] colorWithAlphaComponent:0.5];
    button.titleLabel.font = [UIFont systemFontOfSize:14];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    return button;
}

@end
