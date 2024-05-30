//
//  VEInterfacePlayElement.m
//  VEPlayerUIModule
//
//  Created by real on 2021/12/28.
//

#import "VEInterfacePlayElement.h"
#import "VEPlayerUIModule.h"
#import <Masonry/Masonry.h>

NSString *const playButtonId = @"playButtonId";

NSString *const playGestureId = @"playGestureId";

@implementation VEInterfacePlayElement

@synthesize elementID;
@synthesize type;

#pragma mark ----- VEInterfaceElementProtocol

- (NSString *)elementAction:(id)mayElementView {
    VEPlaybackState playbackState = [[VEEventPoster currentPoster] currentPlaybackState];
    if (playbackState == VEPlaybackStatePlaying) {
        return VEPlayEventPause;
    } else {
        return VEPlayEventPlay;
    }
}

- (void)elementNotify:(id)mayElementView :(NSString *)key :(id)obj {
    if (self.type == VEInterfaceElementTypeButton) {
        VEActionButton *button = (VEActionButton *)mayElementView;
        BOOL screenIsClear = [[VEEventPoster currentPoster] screenIsClear];
        BOOL screenIsLocking = [[VEEventPoster currentPoster] screenIsLocking];
        if ([key isEqualToString:VEPlayEventStateChanged]) {
            VEPlaybackState playbackState = [[VEEventPoster currentPoster] currentPlaybackState];
            button.hidden = playbackState == VEPlaybackStatePlaying;
            button.selected = playbackState != VEPlaybackStatePlaying;
        } else if ([key isEqualToString:VEUIEventScreenClearStateChanged]) {
            button.hidden = screenIsLocking ?: screenIsClear;
        } else if ([key isEqualToString:VEUIEventScreenLockStateChanged]) {
            button.hidden = screenIsLocking;
        }
    }
}

- (id)elementSubscribe:(id)mayElementView {
    if (self.type == VEInterfaceElementTypeButton) {
        return @[VEPlayEventStateChanged, VEUIEventScreenClearStateChanged, VEUIEventScreenLockStateChanged];
    } else {
        return VEPlayEventStateChanged;
    }
}

- (void)elementWillLayout:(UIView *)elementView :(NSSet<UIView *> *)elementGroup :(UIView *)groupContainer {
    [elementView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(groupContainer);
        make.size.equalTo(@(CGSizeMake(80.0, 80.0)));
    }];
}

- (void)elementDisplay:(VEActionButton *)button {
    [button setImage:[UIImage imageNamed:@"video_play"] forState:UIControlStateSelected];
}

#pragma mark ----- Element output

+ (VEInterfaceElementDescriptionImp *)playButton {
    @autoreleasepool {
        VEInterfacePlayElement *element = [VEInterfacePlayElement new];
        element.type = VEInterfaceElementTypeButton;
        element.elementID = playButtonId;
        return element.elementDescription;
    }
}

+ (VEInterfaceElementDescriptionImp *)playGesture {
    @autoreleasepool {
        VEInterfacePlayElement *element = [VEInterfacePlayElement new];
        element.type = VEInterfaceElementTypeGestureSingleTap;
        element.elementID = playGestureId;
        return element.elementDescription;
    }
}

@end
