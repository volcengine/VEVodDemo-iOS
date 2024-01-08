//
//  VEFeedVideoNormalCell.m
//  VOLCDemo
//
//  Created by real on 2022/8/19.
//  Copyright © 2022 ByteDance. All rights reserved.
//

#import "VEFeedVideoNormalCell.h"
#import "VESettingManager.h"
#import "VEVideoModel.h"
#import "UIColor+RGB.h"

#import <VEPlayerUIModule/VEPlayerUIModule.h>
#import <VEPlayerUIModule/VEInterfaceFeedBlockSceneConf.h>
#import <VEPlayerKit/VEPlayerKit.h>
#import <SDWebImage/SDWebImage.h>
#import <Masonry/Masonry.h>

#define VE_FEED_CELL_VIDEO_RATIO      (210.00 / 375.00)

#define VE_FEED_CELL_CONSTANT_HEIGHT      (55.0 + 40.0 + 8.0)

@interface VEFeedVideoNormalCell ()

@property (weak, nonatomic) IBOutlet UIImageView *avatarImgView;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UILabel *detailLabel;

@property (weak, nonatomic) IBOutlet UIImageView *avaImgView;

@property (weak, nonatomic) IBOutlet UIImageView *coverImgView;

@property (weak, nonatomic) IBOutlet UIImageView *playIconView;

@property (weak, nonatomic) IBOutlet UIView *centerContainerView;

@property (nonatomic, weak) VEVideoPlayerController *playerController;

@property (nonatomic, strong) VEInterface *playerControlInterface;

@property (nonatomic, assign) NSInteger currentPlayState;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *centerContainerHeightConstraint;

@end

@implementation VEFeedVideoNormalCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.avaImgView.layer.borderColor = [[UIColor colorWithRGB:0xD0D0D0 alpha:1.0] CGColor];
    self.centerContainerHeightConstraint.constant = VE_FEED_CELL_VIDEO_RATIO * UIScreen.mainScreen.bounds.size.width;
    [self layoutIfNeeded];
}

- (void)cellDidEndDisplay:(BOOL)force {
    [self.centerContainerView bringSubviewToFront:self.playIconView];
    self.playIconView.hidden = NO;
    [self.contentView bringSubviewToFront:self.playIconView];
    self.coverImgView.hidden = NO;
    [self.playerControlInterface removeFromSuperview];
    [self.playerControlInterface destory];
    self.playerControlInterface = nil;
    if (force) {
        [self.playerController stop];
        [self.playerController.view removeFromSuperview];
        self.playerController = nil;
    }
}


#pragma mark ----- Variable Setter & Getter

- (void)setVideoModel:(VEVideoModel *)videoModel {
    _videoModel = videoModel;
    self.detailLabel.text = [NSString stringWithFormat:@"%@", self.videoModel.title];
    [self.coverImgView sd_setImageWithURL:[NSURL URLWithString:videoModel.coverUrl]];
}

+ (CGFloat)cellHeight:(VEVideoModel *)videoModel {
    CGFloat height = [videoModel.title boundingRectWithSize:CGSizeMake((UIScreen.mainScreen.bounds.size.width - 68), CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:15]} context:nil].size.height;
    return (UIScreen.mainScreen.bounds.size.width * VE_FEED_CELL_VIDEO_RATIO) + VE_FEED_CELL_CONSTANT_HEIGHT + height;
}


#pragma mark ----- Play

- (IBAction)centerViewTouchUpInsideAction:(id)sender {
    self.playIconView.hidden = YES;
    self.coverImgView.hidden = YES;
    [self createPlayer];
    [self playerStart];
}

- (void)createPlayer {
    if ([self.delegate respondsToSelector:@selector(feedVideoCellShouldPlay:)]) {
        self.playerController = (VEVideoPlayerController *)[self.delegate feedVideoCellShouldPlay:self];
        [self.centerContainerView addSubview:self.playerController.view];
        [self.playerController.view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.centerContainerView);
        }];
        [self.playerController loadBackgourdImageWithMediaSource:[VEVideoModel ConvertVideoEngineSource:self.videoModel]];
        [self createPlayerControl];
    }
}

- (void)createPlayerControl {
    self.playerControlInterface = [[VEInterface alloc] initWithPlayerCore:self.playerController scene:[VEInterfaceFeedBlockSceneConf new]];
    [self.centerContainerView addSubview:self.playerControlInterface];
    [self.playerControlInterface mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.centerContainerView);
    }];
}

- (void)playerStart {
    if (self.playerController.isPlaying || self.playerController.isPause) {
        [self.playerController play];
    } else {
        [self playerOptions];
        [self.playerController playWithMediaSource:[VEVideoModel ConvertVideoEngineSource:self.videoModel]];
    }
    self.playerController.looping = YES;
}

- (void)playerOptions {
    VESettingModel *preRender = [[VESettingManager universalManager] settingForKey:VESettingKeyShortVideoPreRenderStrategy];
    self.playerController.preRenderOpen = preRender.open;
    
    VESettingModel *preload = [[VESettingManager universalManager] settingForKey:VESettingKeyShortVideoPreloadStrategy];
    self.playerController.preloadOpen = preload.open;
    
    VESettingModel *h265 = [[VESettingManager universalManager] settingForKey:VESettingKeyUniversalH265];
    self.playerController.h265Open = h265.open;
    
    VESettingModel *hardwareDecode = [[VESettingManager universalManager] settingForKey:VESettingKeyUniversalHardwareDecode];
    self.playerController.hardwareDecodeOpen = hardwareDecode.open;
    
    VESettingModel *sr = [[VESettingManager universalManager] settingForKey:VESettingKeyUniversalSR];
    self.playerController.srOpen = sr.open;
}


@end
