//
//  VEInterfaceLongVideoScene.m
//  VEPlayerUIModule
//
//  Created by real on 2021/9/24.
//

#import "VEInterfaceSimpleBlockSceneConf.h"
#import "VEPlayerUIModule.h"
#import "Masonry.h"
#import "VEActionButton.h"
#import "VEProgressView.h"
#import "VEDisplayLabel.h"
#import "VEInterfaceSlideMenuCell.h"
#import "VEInterfaceElementDescriptionImp.h"


static NSString *playButtonIdentifier = @"playButtonIdentifier";

static NSString *progressViewIdentifier = @"progressViewIdentifier";

static NSString *fullScreenButtonIdentifier = @"fullScreenButtonIdentifier";

static NSString *backButtonIdentifier = @"backButtonIdentifier";

static NSString *resolutionButtonIdentifier = @"resolutionButtonIdentifier";

static NSString *playSpeedButtonIdentifier = @"playSpeedButtonIdentifier";

static NSString *moreButtonIdentifier = @"moreButtonIdentifier";

static NSString *lockButtonIdentifier = @"lockButtonIdentifier";

static NSString *titleLabelIdentifier = @"titleLabelIdentifier";

static NSString *loopPlayButtonIdentifier = @"loopPlayButtonIdentifier";

static NSString *volumeGestureIdentifier = @"volumeGestureIdentifier";

static NSString *brightnessGestureIdentifier = @"brightnessGestureIdentifier";

static NSString *progressGestureIdentifier = @"progressGestureIdentifier";

static NSString *clearScreenGestureIdentifier = @"clearScreenGestureIdentifier";

static NSString *playGestureIdentifier = @"playGestureIdentifier";

@implementation VEInterfaceSimpleBlockSceneConf

#pragma mark ----- Tool

static inline BOOL normalScreenBehaivor () {
    return ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait);
}

static inline CGSize squareSize () {
    if (normalScreenBehaivor()) {
        return CGSizeMake(24.0, 24.0);
    } else {
        return CGSizeMake(36.0, 36.0);
    }
}

- (UIView *)viewOfElementIdentifier:(NSString *)identifier inGroup:(NSSet<UIView *> *)viewGroup {
    for (UIView *aView in viewGroup) {
        if ([aView.elementID isEqualToString:identifier]) {
            return aView;
        }
    }
    return nil;
}


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
            BOOL screenIsLocking = [[VEEventPoster currentPoster] screenIsLocking];
            if ([key isEqualToString:VEPlayEventStateChanged]) {
                VEPlaybackState playbackState = [[VEEventPoster currentPoster] currentPlaybackState];
                button.selected = playbackState != VEPlaybackStatePlaying;
            } else if ([key isEqualToString:VEUIEventScreenClearStateChanged]) {
                button.hidden = screenIsLocking ?: screenIsClear;
            } else if ([key isEqualToString:VEUIEventScreenLockStateChanged]) {
                button.hidden = screenIsLocking;
            }
            return @[VEPlayEventStateChanged, VEUIEventScreenClearStateChanged, VEUIEventScreenLockStateChanged];
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
            BOOL screenIsLocking = [[VEEventPoster currentPoster] screenIsLocking];
            if ([key isEqualToString:VEPlayEventTimeIntervalChanged]) {
                if ([obj isKindOfClass:[NSNumber class]]) {
                    NSTimeInterval interval = [((NSNumber *)obj) doubleValue];
                    progressView.totalValue = [[VEEventPoster currentPoster] duration];
                    progressView.currentValue = interval;
                    progressView.bufferValue = [[VEEventPoster currentPoster] playableDuration];
                };
            } else if ([key isEqualToString:VEUIEventScreenClearStateChanged]) {
                progressView.hidden = screenIsLocking ?: screenIsClear;
            } else if ([key isEqualToString:VEUIEventScreenLockStateChanged]) {
                progressView.hidden = screenIsLocking;
            }
            return @[VEPlayEventTimeIntervalChanged, VEUIEventScreenClearStateChanged, VEUIEventScreenLockStateChanged];
        };
        progressViewDes.elementWillLayout = ^(UIView *elementView, NSSet<UIView *> *elementGroup, UIView *groupContainer) {
            VEProgressView *progressView = (VEProgressView *)elementView;
            if (normalScreenBehaivor()) {
                UIView *fullscreenBtn = [self viewOfElementIdentifier:fullScreenButtonIdentifier inGroup:elementGroup];
                [elementView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.leading.equalTo(groupContainer).offset(12.0);
                    make.centerY.equalTo(fullscreenBtn);
                    make.trailing.equalTo(fullscreenBtn.mas_leading).offset(-5.0);
                    make.height.equalTo(@50.0);
                }];
                progressView.currentOrientation = UIInterfaceOrientationPortrait;
            } else {
                [elementView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.leading.equalTo(groupContainer).offset(45.0);
                    make.trailing.equalTo(groupContainer).offset(-45.0);
                    make.bottom.equalTo(groupContainer).offset(-50.0);
                    make.height.equalTo(@40.0);
                }];
                progressView.currentOrientation = UIInterfaceOrientationLandscapeRight;
            }
        };
        progressViewDes;
    });
}

- (VEInterfaceElementDescriptionImp *)fullScreenButton {
    return ({
        VEInterfaceElementDescriptionImp *fullScreenBtnDes = [VEInterfaceElementDescriptionImp new];
        fullScreenBtnDes.elementID = fullScreenButtonIdentifier;
        fullScreenBtnDes.type = VEInterfaceElementTypeButton;
        fullScreenBtnDes.elementDisplay = ^(VEActionButton *button) {
            [button setImage:[UIImage imageNamed:@"long_video_portrait"] forState:UIControlStateNormal];
        };
        fullScreenBtnDes.elementAction = ^NSString *(VEActionButton *button) {
            return VEUIEventScreenRotation;
        };
        fullScreenBtnDes.elementNotify = ^id (VEActionButton *button, NSString *key, id obj) {
            BOOL screenIsClear = [[VEEventPoster currentPoster] screenIsClear];
            BOOL screenIsLocking = [[VEEventPoster currentPoster] screenIsLocking];
            if ([key isEqualToString:VEUIEventScreenClearStateChanged]) {
                button.hidden = screenIsLocking ?: screenIsClear;
            } else if ([key isEqualToString:VEUIEventScreenLockStateChanged]) {
                button.hidden = screenIsLocking;
            }
            return @[VEUIEventScreenClearStateChanged, VEUIEventScreenLockStateChanged];
        };
        fullScreenBtnDes.elementWillLayout = ^(UIView *elementView, NSSet<UIView *> *elementGroup, UIView *groupContainer) {
            if (normalScreenBehaivor()) {
                elementView.hidden = NO;
                elementView.alpha = 1.0;
                [elementView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.bottom.equalTo(groupContainer).offset(-10.0);
                    make.trailing.equalTo(groupContainer).offset(-3.0);
                    make.size.equalTo(@(CGSizeMake(44.0, 44.0)));
                }];
            } else {
                elementView.hidden = YES;
                elementView.alpha = 0.0;
            }
        };
        fullScreenBtnDes;
    });
}

- (VEInterfaceElementDescriptionImp *)backButton {
    return ({
        VEInterfaceElementDescriptionImp *backBtnDes = [VEInterfaceElementDescriptionImp new];
        backBtnDes.elementID = backButtonIdentifier;
        backBtnDes.type = VEInterfaceElementTypeButton;
        backBtnDes.elementDisplay = ^(VEActionButton *button) {
            [button setImage:[UIImage imageNamed:@"video_page_back"] forState:UIControlStateNormal];
        };
        backBtnDes.elementAction = ^NSString *(VEActionButton *button) {
            if (normalScreenBehaivor()) {
                return VEUIEventPageBack;
            } else {
                return VEUIEventScreenRotation;
            }
        };
        backBtnDes.elementNotify = ^id (VEActionButton *button, NSString *key, id obj) {
            BOOL screenIsClear = [[VEEventPoster currentPoster] screenIsClear];
            BOOL screenIsLocking = [[VEEventPoster currentPoster] screenIsLocking];
            if ([key isEqualToString:VEUIEventScreenClearStateChanged]) {
                button.hidden = screenIsLocking ?: screenIsClear;
            } else if ([key isEqualToString:VEUIEventScreenLockStateChanged]) {
                button.hidden = screenIsLocking;
            }
            return @[VEUIEventScreenClearStateChanged, VEUIEventScreenLockStateChanged];
        };
        backBtnDes.elementWillLayout = ^(UIView *elementView, NSSet<UIView *> *elementGroup, UIView *groupContainer) {
            CGFloat leading = normalScreenBehaivor() ? 12.0 : 48.0;
            CGFloat top = normalScreenBehaivor() ? 10.0 : 16.0;
            [elementView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(groupContainer).offset(top);
                make.leading.equalTo(groupContainer).offset(leading);
                make.size.equalTo(@(squareSize()));
            }];
        };
        backBtnDes;
    });
}

- (VEInterfaceElementDescriptionImp *)resolutionButton {
    return ({
        VEInterfaceElementDescriptionImp *resolutionBtnDes = [VEInterfaceElementDescriptionImp new];
        resolutionBtnDes.elementID = resolutionButtonIdentifier;
        resolutionBtnDes.type = VEInterfaceElementTypeButton;
        resolutionBtnDes.elementDisplay = ^(VEActionButton *button) {
            [button setImage:[UIImage imageNamed:@"long_video_resolution"] forState:UIControlStateNormal];
            [button setTitle:@"默认" forState:UIControlStateNormal];
        };
        resolutionBtnDes.elementAction = ^NSString* (VEActionButton *button) {
            return VEUIEventShowResolutionMenu;
        };
        resolutionBtnDes.elementNotify = ^id (VEActionButton *button,  NSString *key, id obj) {
            BOOL screenIsClear = [[VEEventPoster currentPoster] screenIsClear];
            BOOL screenIsLocking = [[VEEventPoster currentPoster] screenIsLocking];
            if ([key isEqualToString:VEPlayEventResolutionChanged]) {
                NSString *currentResolutionTitle = [[VEEventPoster currentPoster] currentResolutionForDisplay];
                [button setTitle:currentResolutionTitle forState:UIControlStateNormal];
            } else if ([key isEqualToString:VEUIEventScreenClearStateChanged]) {
                button.hidden = screenIsLocking ?: screenIsClear;
            } else if ([key isEqualToString:VEUIEventScreenLockStateChanged]) {
                button.hidden = screenIsLocking;
            }
            return @[VEPlayEventResolutionChanged, VEUIEventScreenClearStateChanged, VEUIEventScreenLockStateChanged];
        };
        resolutionBtnDes.elementWillLayout = ^(UIView *elementView, NSSet<UIView *> *elementGroup, UIView *groupContainer) {
            if (normalScreenBehaivor()) {
                elementView.hidden = YES;
                elementView.alpha = 0.0;
            } else {
                elementView.hidden = NO;
                elementView.alpha = 1.0;
                [elementView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.bottom.equalTo(groupContainer).offset(-9.0);
                    make.trailing.equalTo(groupContainer.mas_trailing).offset(-50.0);
                    make.size.equalTo(@(CGSizeMake(80.0, 50.0)));
                }];
            }
        };
        resolutionBtnDes;
    });
}

- (VEInterfaceElementDescriptionImp *)playSpeedButton {
    return ({
        VEInterfaceElementDescriptionImp *playSpeedBtnDes = [VEInterfaceElementDescriptionImp new];
        playSpeedBtnDes.elementID = playSpeedButtonIdentifier;
        playSpeedBtnDes.type = VEInterfaceElementTypeButton;
        playSpeedBtnDes.elementDisplay = ^(VEActionButton *button) {
            [button setImage:[UIImage imageNamed:@"long_video_speed"] forState:UIControlStateNormal];
            [button setTitle:@"1.0x" forState:UIControlStateNormal];
        };
        playSpeedBtnDes.elementAction = ^NSString* (VEActionButton *button) {
            return VEUIEventShowPlaySpeedMenu;
        };
        playSpeedBtnDes.elementNotify = ^id (VEActionButton *button, NSString *key, id obj) {
            BOOL screenIsClear = [[VEEventPoster currentPoster] screenIsClear];
            BOOL screenIsLocking = [[VEEventPoster currentPoster] screenIsLocking];
            if ([key isEqualToString:VEPlayEventPlaySpeedChanged]) {
                NSString *currentSpeedTitle = [[VEEventPoster currentPoster] currentPlaySpeedForDisplay];
                [button setTitle:currentSpeedTitle forState:UIControlStateNormal];
            } else if ([key isEqualToString:VEUIEventScreenClearStateChanged]) {
                button.hidden = screenIsLocking ?: screenIsClear;
            } else if ([key isEqualToString:VEUIEventScreenLockStateChanged]) {
                button.hidden = screenIsLocking;
            }
            return @[VEPlayEventPlaySpeedChanged, VEUIEventScreenClearStateChanged, VEUIEventScreenLockStateChanged];;
        };
        playSpeedBtnDes.elementWillLayout = ^(UIView *elementView, NSSet<UIView *> *elementGroup, UIView *groupContainer) {
            if (normalScreenBehaivor()) {
                elementView.hidden = YES;
                elementView.alpha = 0.0;
            } else {
                elementView.hidden = NO;
                elementView.alpha = 1.0;
                UIView *resolutionBtn = [self viewOfElementIdentifier:resolutionButtonIdentifier inGroup:elementGroup];
                [elementView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.centerY.equalTo(resolutionBtn);
                    make.trailing.equalTo(resolutionBtn.mas_leading).offset(-10.0);
                    make.size.equalTo(@(CGSizeMake(80.0, 50.0)));
                }];
            }
        };
        playSpeedBtnDes;
    });
}

- (VEInterfaceElementDescriptionImp *)moreButton {
    return ({
        VEInterfaceElementDescriptionImp *moreButtonDes = [VEInterfaceElementDescriptionImp new];
        moreButtonDes.elementID = moreButtonIdentifier;
        moreButtonDes.type = VEInterfaceElementTypeButton;
        moreButtonDes.elementDisplay = ^(VEActionButton *button) {
            [button setImage:[UIImage imageNamed:@"long_video_more"] forState:UIControlStateNormal];
        };
        moreButtonDes.elementAction = ^NSString* (VEActionButton *button) {
            return VEUIEventShowMoreMenu;
        };
        moreButtonDes.elementNotify = ^id (VEActionButton *button, NSString *key, id obj) {
            BOOL screenIsClear = [[VEEventPoster currentPoster] screenIsClear];
            BOOL screenIsLocking = [[VEEventPoster currentPoster] screenIsLocking];
            if ([key isEqualToString:VEUIEventScreenClearStateChanged]) {
                button.hidden = screenIsLocking ?: screenIsClear;
            } else if ([key isEqualToString:VEUIEventScreenLockStateChanged]) {
                button.hidden = screenIsLocking;
            }
            return @[VEUIEventScreenClearStateChanged, VEUIEventScreenLockStateChanged];;
        };
        moreButtonDes.elementWillLayout = ^(UIView *elementView, NSSet<UIView *> *elementGroup, UIView *groupContainer) {
            CGFloat trailing = normalScreenBehaivor() ? 14.0 : 54.0;
            CGFloat top = normalScreenBehaivor() ? 10.0 : 16.0;
            [elementView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(groupContainer).offset(top);
                make.trailing.equalTo(groupContainer).offset(-trailing);
                make.size.equalTo(@(squareSize()));
            }];
        };
        moreButtonDes;
    });
}

- (VEInterfaceElementDescriptionImp *)lockButton {
    return ({
        VEInterfaceElementDescriptionImp *lockButtonDes = [VEInterfaceElementDescriptionImp new];
        lockButtonDes.elementID = lockButtonIdentifier;
        lockButtonDes.type = VEInterfaceElementTypeButton;
        lockButtonDes.elementDisplay = ^(VEActionButton *button) {
            [button setImage:[UIImage imageNamed:@"long_video_unlock"] forState:UIControlStateNormal];
            [button setImage:[UIImage imageNamed:@"long_video_lock"] forState:UIControlStateSelected];
        };
        lockButtonDes.elementAction = ^NSString* (VEActionButton *button) {
            return VEUIEventLockScreen;
        };
        lockButtonDes.elementNotify = ^id (VEActionButton *button, NSString *key, id obj) {
            BOOL screenIsClear = [[VEEventPoster currentPoster] screenIsClear];
            BOOL screenIsLocking = [[VEEventPoster currentPoster] screenIsLocking];
            if ([key isEqualToString:VEUIEventScreenClearStateChanged]) {
                button.hidden = screenIsClear;
            } else if ([key isEqualToString:VEUIEventScreenLockStateChanged]) {
                button.selected = screenIsLocking;
            }
            return @[VEUIEventScreenClearStateChanged, VEUIEventScreenLockStateChanged];;
        };
        lockButtonDes.elementWillLayout = ^(UIView *elementView, NSSet<UIView *> *elementGroup, UIView *groupContainer) {
            UIView *backBtn = [self viewOfElementIdentifier:backButtonIdentifier inGroup:elementGroup];
            [elementView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.leading.equalTo(backBtn);
                make.centerY.equalTo(groupContainer);
                make.size.equalTo(@(squareSize()));
            }];
        };
        lockButtonDes;
    });
}

- (VEInterfaceElementDescriptionImp *)titleLabel {
    return ({
        VEInterfaceElementDescriptionImp *titleLabelDes = [VEInterfaceElementDescriptionImp new];
        titleLabelDes.elementID = titleLabelIdentifier;
        titleLabelDes.type = VEInterfaceElementTypeLabel;
        titleLabelDes.elementDisplay = ^(VEDisplayLabel *label) {
            label.text = [[VEEventPoster currentPoster] title];
        };
        titleLabelDes.elementNotify = ^id (VEDisplayLabel *label, NSString *key, id obj) {
            BOOL screenIsClear = [[VEEventPoster currentPoster] screenIsClear];
            BOOL screenIsLocking = [[VEEventPoster currentPoster] screenIsLocking];
            if ([key isEqualToString:VEUIEventScreenClearStateChanged]) {
                label.hidden = screenIsLocking ?: screenIsClear;
            } else if ([key isEqualToString:VEUIEventScreenLockStateChanged]) {
                label.hidden = screenIsLocking;
            }
            return @[VEUIEventScreenClearStateChanged, VEUIEventScreenLockStateChanged];;
        };
        titleLabelDes.elementWillLayout = ^(UIView *elementView, NSSet<UIView *> *elementGroup, UIView *groupContainer) {
            UIView *backBtn = [self viewOfElementIdentifier:backButtonIdentifier inGroup:elementGroup];
            UIView *moreBtn = [self viewOfElementIdentifier:moreButtonIdentifier inGroup:elementGroup];
            [elementView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.leading.equalTo(backBtn.mas_trailing).offset(8.0);
                make.centerY.equalTo(backBtn);
                make.trailing.equalTo(moreBtn.mas_leading).offset(8.0);
                make.height.equalTo(@50.0);
            }];
        };
        titleLabelDes;
    });
}

- (VEInterfaceElementDescriptionImp *)loopPlayButton {
    return ({
        VEInterfaceElementDescriptionImp *loopPlayButtonDes = [VEInterfaceElementDescriptionImp new];
        loopPlayButtonDes.elementID = loopPlayButtonIdentifier;
        loopPlayButtonDes.type = VEInterfaceElementTypeMenuNormalCell;
        loopPlayButtonDes.elementDisplay = ^(VEInterfaceSlideMenuCell *cell) {
            cell.titleLabel.text = [[VEEventPoster currentPoster] loopPlayOpen] ? @"循环播放开启" :  @"循环播放关闭";
            cell.iconImgView.image = [UIImage imageNamed:@"long_video_loopplay"];
        };
        loopPlayButtonDes.elementAction = ^NSString* (VEInterfaceSlideMenuCell *cell) {
            return VEPlayEventChangeLoopPlayMode;
        };
        loopPlayButtonDes.elementWillLayout = ^(UIView *elementView, NSSet<UIView *> *elementGroup, UIView *groupContainer) {
            
        };
        loopPlayButtonDes;
    });
}

- (VEInterfaceElementDescriptionImp *)volumeGesture {
    return ({
        VEInterfaceElementDescriptionImp *volumeGestureDes = [VEInterfaceElementDescriptionImp new];
        volumeGestureDes.elementID = volumeGestureIdentifier;
        volumeGestureDes.type = VEInterfaceElementTypeGestureRightVerticalPan;
        volumeGestureDes.elementAction = ^NSString* (id sender) {
            return VEUIEventVolumeIncrease;
        };
        volumeGestureDes;
    });
}

- (VEInterfaceElementDescriptionImp *)brightnessGesture {
    return ({
        VEInterfaceElementDescriptionImp *brightnessGestureDes = [VEInterfaceElementDescriptionImp new];
        brightnessGestureDes.elementID = brightnessGestureIdentifier;
        brightnessGestureDes.type = VEInterfaceElementTypeGestureLeftVerticalPan;
        brightnessGestureDes.elementAction = ^NSString* (id sender) {
            return VEUIEventBrightnessIncrease;
        };
        brightnessGestureDes;
    });
}

- (VEInterfaceElementDescriptionImp *)progressGesture {
    return ({
        VEInterfaceElementDescriptionImp *progressGestureDes = [VEInterfaceElementDescriptionImp new];
        progressGestureDes.elementID = progressGestureIdentifier;
        progressGestureDes.type = VEInterfaceElementTypeGestureHorizontalPan;
        progressGestureDes.elementAction = ^NSString* (id sender) {
            return VEPlayEventProgressValueIncrease;
        };
        progressGestureDes;
    });
}

- (VEInterfaceElementDescriptionImp *)playGesture {
    return ({
        VEInterfaceElementDescriptionImp *playGestureDes = [VEInterfaceElementDescriptionImp new];
        playGestureDes.elementID = playGestureIdentifier;
        playGestureDes.type = VEInterfaceElementTypeGestureDoubleTap;
        playGestureDes.elementAction = ^NSString* (id sender) {
            if ([[VEEventPoster currentPoster] screenIsLocking] || [[VEEventPoster currentPoster] screenIsClear]) {
                return nil;
            }
            VEPlaybackState playbackState = [[VEEventPoster currentPoster] currentPlaybackState];
            if (playbackState == VEPlaybackStatePlaying) {
                return VEPlayEventPause;
            } else {
                return VEPlayEventPlay;
            }
        };
        playGestureDes;
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
    return @[[self playButton],
             [self progressView],
             [self fullScreenButton],
             [self backButton],
             [self resolutionButton],
             [self playSpeedButton],
             [self moreButton],
             [self lockButton],
             [self titleLabel],
             [self loopPlayButton],
             [self volumeGesture],
             [self brightnessGesture],
             [self progressGesture],
             [self playGesture],
             [self clearScreenGesture]
    ];
}


@end
