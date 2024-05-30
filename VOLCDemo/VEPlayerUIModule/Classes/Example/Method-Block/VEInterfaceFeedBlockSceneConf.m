//
//  VEInterfaceFeedBlockSceneConf.m
//  VOLCDemo
//
//  Created by RealZhao on 2021/12/2.
//  Copyright © 2021 ByteDance. All rights reserved.
//

#import "VEInterfaceFeedBlockSceneConf.h"
#import "VEPlayerUIModule.h"
#import "VEActionButton.h"
#import "VEProgressView.h"
#import "VEDisplayLabel.h"
#import "VEInterfaceSlideMenuCell.h"
#import "VEInterfaceElementDescriptionImp.h"
#import <Masonry/Masonry.h>

@implementation VEInterfaceFeedBlockSceneConf

static NSString *playButtonIdentifier = @"playButtonIdentifier";

static NSString *progressViewIdentifier = @"progressViewIdentifier";

static NSString *clearScreenGestureIdentifier = @"clearScreenGestureIdentifier";

#pragma mark ----- Element Statement

- (VEInterfaceElementDescriptionImp *)playButton {
    return ({
        VEInterfaceElementDescriptionImp *playBtnDes = [VEInterfaceElementDescriptionImp new];
        playBtnDes.elementID = playButtonIdentifier;
        playBtnDes.type = VEInterfaceElementTypeButton;
        playBtnDes.elementDisplay = ^(VEActionButton *button) {
            [button setImage:[UIImage imageNamed:@"video_pause"] forState:UIControlStateNormal];
            [button setImage:[UIImage imageNamed:@"video_play"] forState:UIControlStateSelected];
        };

        playBtnDes.elementAction = ^NSString *(VEActionButton *button) {
            VEPlaybackState playbackState = [[VEEventPoster currentPoster] currentPlaybackState];
            if (playbackState == VEPlaybackStatePlaying) {
                return VEPlayEventPause;
            } else {
                return VEPlayEventPlay;
            }
        };
        playBtnDes.elementNotify = ^id (VEActionButton *button, NSString *key, id obj) {
            BOOL screenIsClear = [[VEEventPoster currentPoster] screenIsClear];
            if ([key isEqualToString:VEPlayEventStateChanged]) {
                VEPlaybackState playbackState = [[VEEventPoster currentPoster] currentPlaybackState];
                button.selected = playbackState != VEPlaybackStatePlaying;
            } else if ([key isEqualToString:VEUIEventScreenClearStateChanged]) {
                button.hidden = screenIsClear;
            }
            return @[VEPlayEventStateChanged, VEUIEventScreenClearStateChanged];
        };
        playBtnDes.elementWillLayout = ^(UIView *elementView, NSSet<UIView *> *elementGroup, UIView *groupContainer) {
            [elementView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.center.equalTo(groupContainer);
                make.size.equalTo(@(CGSizeMake(50.0, 50.0)));
            }];
        };
        playBtnDes;
    });
}

- (VEInterfaceElementDescriptionImp *)progressView {
    return ({
        VEInterfaceElementDescriptionImp *progressViewDes = [VEInterfaceElementDescriptionImp new];
        progressViewDes.elementID = progressViewIdentifier;
        progressViewDes.type = VEInterfaceElementTypeProgressView;
        progressViewDes.elementAction = ^NSDictionary* (VEProgressView *progressView) {
            return @{VEPlayEventSeek : @(progressView.currentValue)};
        };
        progressViewDes.elementNotify = ^id (VEProgressView *progressView, NSString *key, id obj) {
            BOOL screenIsClear = [[VEEventPoster currentPoster] screenIsClear];
            if ([obj isKindOfClass:[NSNumber class]]) {
                NSTimeInterval interval = [((NSNumber *)obj) doubleValue];
                progressView.totalValue = [[VEEventPoster currentPoster] duration];
                progressView.currentValue = interval;
                progressView.bufferValue = [[VEEventPoster currentPoster] playableDuration];
            } else if ([key isEqualToString:VEUIEventScreenClearStateChanged]) {
                progressView.hidden = screenIsClear;
            }
            return @[VEPlayEventTimeIntervalChanged, VEUIEventScreenClearStateChanged];
        };
        progressViewDes.elementWillLayout = ^(UIView *elementView, NSSet<UIView *> *elementGroup, UIView *groupContainer) {
            ((VEProgressView *)elementView).currentOrientation = UIInterfaceOrientationPortrait;
            [elementView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.leading.equalTo(groupContainer).offset(10.0);
                make.bottom.equalTo(groupContainer).offset(5.0);
                make.trailing.equalTo(groupContainer).offset(-10.0);
                make.height.equalTo(@50.0);
            }];
        };
        progressViewDes;
    });
}

- (VEInterfaceElementDescriptionImp *)clearScreenGesture {
    return ({
        VEInterfaceElementDescriptionImp *clearScreenGestureDes = [VEInterfaceElementDescriptionImp new];
        clearScreenGestureDes.elementID = clearScreenGestureIdentifier;
        clearScreenGestureDes.type = VEInterfaceElementTypeGestureSingleTap;
        clearScreenGestureDes.elementAction = ^NSString* (id sender) {
            return VEUIEventClearScreen;
        };
        clearScreenGestureDes;
    });
}


#pragma mark ----- VEInterfaceElementProtocol

- (NSArray<id<VEInterfaceElementDescription>> *)customizedElements {
    return @[[self playButton], [self progressView], [self clearScreenGesture]];
}

@end
