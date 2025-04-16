//
//  VEPlayerSubtitleModule.m
//  VEPlayModule
//
//  Created by litao.he on 2025/3/10.
//

#import "VEPlayerSubtitleModule.h"
#import "VEPlayerContextKeyDefine.h"
#import "VEPlayerActionViewInterface.h"
#import "VEPlayerGestureServiceInterface.h"
#import "VEPlayerSubtitleView.h"
#import <Masonry/Masonry.h>
#import "VEPlayerSeekState.h"
#import "VEVideoPlayback.h"

@interface VEPlayerSubtitleModule ()

@property (nonatomic, strong) VEPlayerSubtitleView *subtitleView;

@property (nonatomic, weak) id<VEVideoPlayback> playerInterface;

@property (nonatomic, weak) id<VEPlayerActionViewInterface> actionViewInterface;

@end

@implementation VEPlayerSubtitleModule

VEPlayerContextDILink(playerInterface, VEVideoPlayback, self.context);
VEPlayerContextDILink(actionViewInterface, VEPlayerActionViewInterface, self.context);

#pragma mark - Life Cycle

- (void)moduleDidLoad {
    [super moduleDidLoad];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self configuratoinCustomView];
}

- (void)controlViewTemplateDidUpdate {
    [super controlViewTemplateDidUpdate];
}

- (void)configuratoinCustomView {
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = CGRectGetWidth(screenBounds);
    CGFloat screenHeight = CGRectGetHeight(screenBounds);

    [self.actionViewInterface.overlayControlView addSubview:self.subtitleView];

    [self.subtitleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.actionViewInterface.overlayControlView);
        make.bottom.equalTo(self.actionViewInterface.overlayControlView).offset(-(screenHeight * 0.296));
        make.left.equalTo(self.actionViewInterface.overlayControlView).offset(screenWidth * 0.128);
        make.right.equalTo(self.actionViewInterface.overlayControlView).offset(-(screenWidth * 0.128));
        make.height.mas_equalTo(screenHeight * 0.222);
    }];
}

- (void)moduleDidUnLoad {
    [super moduleDidUnLoad];
    if (self.subtitleView) {
        [self.subtitleView removeFromSuperview];
        self.subtitleView = nil;
    }
}

#pragma mark - Getter && Setter

- (VEPlayerSubtitleView *)subtitleView {
    if (_subtitleView == nil) {
        _subtitleView = [[VEPlayerSubtitleView alloc] init];
    }
    return _subtitleView;
}

- (void)setSubtitle:(NSString *)subtitle {
    [self.subtitleView setSubtitle:subtitle];
}
@end
