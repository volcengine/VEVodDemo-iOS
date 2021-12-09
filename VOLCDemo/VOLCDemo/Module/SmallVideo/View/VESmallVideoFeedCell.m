//
//  VESmallVideoFeedCell.m
//  VOLCDemo
//
//  Created by wangzhiyong on 2021/6/30.
//  Copyright © 2021 ByteDance. All rights reserved.
//

#import "VESmallVideoFeedCell.h"
#import "VEVideoPlayerViewController.h"
#import "VEVideoModel.h"
#import "VESmallVideoPlaybackPanelViewController.h"

@interface VESmallVideoFeedCell ()

@property (nonatomic, strong) VEVideoPlayerViewController *playerViewController;
@property (nonatomic, strong) VEVideoModel *videoModel;

@end

@implementation VESmallVideoFeedCell

@synthesize indexPath;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self configuratoinCustomView];
    }
    return self;
}


#pragma mark - UI

- (void)configuratoinCustomView {
    _playerViewController = [[VEVideoPlayerViewController alloc] init];
    
    VESmallVideoPlaybackPanelViewController *playerControlViewContorller = [[VESmallVideoPlaybackPanelViewController alloc] initWithVideoPlayer:_playerViewController];
    [_playerViewController registePlaybackPanelController:playerControlViewContorller];
    
    [self.contentView addSubview:_playerViewController.view];
    [_playerViewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
}


#pragma mark - Public

- (void)configWithVideoModel:(VEVideoModel *)videoModel {
    self.videoModel = videoModel;
    NSLog(@"update data index ==== %@", @(self.indexPath));
    [self.playerViewController loadBackgourdImageWithMediaSource:[VEVideoModel videoEngineVidSource:videoModel]];
}

- (void)play {
    NSLog(@"play index ==== %@", @(self.indexPath));
    [self.playerViewController playWithMediaSource:[VEVideoModel videoEngineVidSource:self.videoModel]];
}

- (void)stop {
    [self.playerViewController stop];
}

- (void)pause {
    [self.playerViewController pause];
}

@end
