//
//  VELongVideoViewNormalCell.m
//  VOLCDemo
//
//  Created by real on 2022/8/18.
//  Copyright © 2022 ByteDance. All rights reserved.
//

#import "VELongVideoViewNormalCell.h"
#import "VEVideoModel.h"
#import <SDWebImage/SDWebImage.h>

@interface VELongVideoViewNormalCell ()

@property (weak, nonatomic) IBOutlet UIImageView *coverImgView;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation VELongVideoViewNormalCell

- (void)setVideoModel:(VEVideoModel *)videoModel {
    _videoModel = videoModel;
    if ([videoModel isKindOfClass:[VEVideoModel class]]) {
        self.titleLabel.text = [NSString stringWithFormat:@"%@", videoModel.title];
        [self.coverImgView sd_setImageWithURL:[NSURL URLWithString:videoModel.coverUrl]];
    } else {
        self.titleLabel.text = @"";
        self.coverImgView.image = nil;
    }
}

@end
