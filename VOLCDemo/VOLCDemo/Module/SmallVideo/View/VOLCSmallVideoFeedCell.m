//
//  VOLCSmallVideoFeedCell.m
//  VOLCDemo
//
//  Created by wangzhiyong on 2021/6/30.
//  Copyright © 2021 Copyright © 2021 ByteDance. All rights reserved. All rights reserved.
//

#import "VOLCSmallVideoFeedCell.h"
#import "VOLCSmallVideoPlayerView.h"
#import "VOLCVideoModel.h"

@interface VOLCSmallVideoFeedCell ()

@property (nonatomic, strong) VOLCSmallVideoPlayerView *playerView;

@end

@implementation VOLCSmallVideoFeedCell

@synthesize indexPath = _indexPath;

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
    _playerView = [[VOLCSmallVideoPlayerView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [self.contentView addSubview:_playerView];
    [_playerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
}


#pragma mark - Public

- (void)configWithVideoModel:(VOLCVideoModel *)videoModle {
    [_playerView configWithVideoModel:videoModle];
}

- (void)play {
    [self.playerView play];
}

- (void)stop {
    [self.playerView stop];
}

- (void)pause {
    [self.playerView pause];
}

@end
