//
//  ShortDramaPlayerSpeedModule.m
//  VEPlayModule
//
//  Created by zyw on 2024/7/16.
//

#import "ShortDramaPlayerSpeedModule.h"
#import "VEPlayerContextKeyDefine.h"
#import "VEPlayerActionViewInterface.h"
#import "VEPlayerGestureServiceInterface.h"
#import "VEPlayerGestureHandlerProtocol.h"
#import "ShortDramaSpeedTipView.h"
#import <Masonry/Masonry.h>
#import "VEVideoPlayback.h"

@interface ShortDramaPlayerSpeedModule () <VEPlayerGestureHandlerProtocol>

@property (nonatomic, strong) ShortDramaSpeedTipView *speedTipView;
@property (nonatomic, weak) id<VEVideoPlayback> playerInterface;
@property (nonatomic, weak) id<VEPlayerGestureServiceInterface> gestureService;
@property (nonatomic, weak) id<VEPlayerActionViewInterface> actionViewInterface;

@end

@implementation ShortDramaPlayerSpeedModule

VEPlayerContextDILink(playerInterface, VEVideoPlayback, self.context);
VEPlayerContextDILink(gestureService, VEPlayerGestureServiceInterface, self.context);
VEPlayerContextDILink(actionViewInterface, VEPlayerActionViewInterface, self.context);

#pragma mark - Life Cycle

- (void)moduleDidLoad {
    [super moduleDidLoad];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configuratoinCustomView];
    
    [self.gestureService addGestureHandler:self forType:VEGestureType_LongPress];
}

- (void)controlViewTemplateDidUpdate {
    [super controlViewTemplateDidUpdate];
}

- (void)configuratoinCustomView {
    [self.actionViewInterface.playerContainerView addSubview:self.speedTipView];
    [self.speedTipView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.actionViewInterface.playerContainerView);
        make.bottom.equalTo(self.actionViewInterface.playerContainerView).with.offset(-33);
        make.size.mas_equalTo(CGSizeMake(ShortDramaSpeedTipViewViewWidth, ShortDramaSpeedTipViewViewHeight));
    }];
    self.speedTipView.alpha = 0;
}

- (void)moduleDidUnLoad {
    [super moduleDidUnLoad];
    if (self.speedTipView) {
        [self.speedTipView removeFromSuperview];
        self.speedTipView = nil;
    }
}

#pragma mark - VEPlayerGestureHandlerProtocol

- (void)handleGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer gestureType:(VEGestureType)gestureType {
    if (gestureType == VEGestureType_LongPress) {
        UIGestureRecognizerState state = gestureRecognizer.state;
        if (state == UIGestureRecognizerStateBegan) {
            self.playerInterface.playbackRate = 2.0f;
            [self.speedTipView showSpeedView:[NSString stringWithFormat:@"%.0fx倍速中", self.playerInterface.playbackRate]];
            [self.context post:@(YES) forKey:VEPlayerContextKeySpeedTipViewShowed];
        } else if (state == UIGestureRecognizerStateEnded ||
                   state == UIGestureRecognizerStateCancelled ||
                   state == UIGestureRecognizerStateFailed) {
            self.playerInterface.playbackRate = 1.0f;
            [self.speedTipView hiddenSpeedView];
            [self.context post:@(NO) forKey:VEPlayerContextKeySpeedTipViewShowed];
        }
    }
}

#pragma mark - Getter

- (ShortDramaSpeedTipView *)speedTipView {
    if (_speedTipView == nil) {
        _speedTipView = [[ShortDramaSpeedTipView alloc] init];
    }
    return _speedTipView;
}

@end
