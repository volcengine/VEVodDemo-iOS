//
//  VEPlayerPipModule.m
//  VEPlayModule
//
//  Created by litao.he on 2025/3/17.
//

#import "VEPlayerPipModule.h"
#import "VEPlayerContextKeyDefine.h"
#import "VEPlayerActionViewInterface.h"
#import "VEPlayerGestureServiceInterface.h"
#import <Masonry/Masonry.h>
#import "VEPlayerSeekState.h"
#import "VEVideoPlayback.h"
#import "VEVideoPlayerPipController.h"

@interface VEPlayerPipModule ()

@property (nonatomic, strong) UIButton *btnPip;

@property (nonatomic, weak) id<VEVideoPlayback> playerInterface;

@property (nonatomic, weak) id<VEPlayerActionViewInterface> actionViewInterface;

@property (nonatomic, assign) NSInteger pipActived;

@end

@implementation VEPlayerPipModule

VEPlayerContextDILink(playerInterface, VEVideoPlayback, self.context);
VEPlayerContextDILink(actionViewInterface, VEPlayerActionViewInterface, self.context);

#pragma mark - Life Cycle

- (void)moduleDidLoad {
    [super moduleDidLoad];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.pipActived = [[VEVideoPlayerPipController shared] isPipActive] ? 1 : 0;
    [self configuratoinCustomView];

    @weakify(self);
    [self.context addKey:VEPlayerContextKeyPictureInPictureStateChanged withObserver:self handler:^(NSNumber *actived, NSString *key) {
        @strongify(self);
        self.pipActived = [actived integerValue];
    }];
}

- (void)controlViewTemplateDidUpdate {
    [super controlViewTemplateDidUpdate];
}

- (void)configuratoinCustomView {

    [self.actionViewInterface.overlayControlView addSubview:self.btnPip];

    [self.btnPip mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.actionViewInterface.overlayControlView).offset(52);
        make.right.equalTo(self.actionViewInterface.overlayControlView).offset(-12);
        make.size.mas_equalTo(CGSizeMake(36, 36));
    }];
}

- (void)moduleDidUnLoad {
    [super moduleDidUnLoad];
    if (self.btnPip) {
        [self.btnPip removeFromSuperview];
        self.btnPip = nil;
    }
}

- (void)switchPip:(UIButton *)sender {
    NSLog(@"======= switch pip");
    [self.context post:@(self.pipActived) forKey:VEPlayerContextKeySwitchPictureInPicture];
}

#pragma mark - Getter && Setter

- (UIButton *)btnPip {
    if (!_btnPip) {
        _btnPip = [[UIButton alloc] init];
        [_btnPip setImage:[UIImage systemImageNamed:_pipActived ? @"pip.exit" : @"pip.enter"] forState:UIControlStateNormal];
        [_btnPip setTintColor:UIColor.whiteColor];
        [_btnPip addTarget:self action:@selector(switchPip:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnPip;
}

- (void)setPipActived:(NSInteger)pipActived {
    if (_pipActived == pipActived) {
        return;
    }
    _pipActived = pipActived;
    [self.btnPip setImage:[UIImage systemImageNamed:_pipActived ? @"pip.exit" : @"pip.enter"] forState:UIControlStateNormal];
}

@end
