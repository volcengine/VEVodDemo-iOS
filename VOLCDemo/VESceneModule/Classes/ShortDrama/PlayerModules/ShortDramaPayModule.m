//
//  ShortDramaPayModule.m
//  VEPlayModule
//
//  Created by zyw on 2024/7/24.
//

#import "ShortDramaPayModule.h"
#import "VEPlayerContextKeyDefine.h"
#import "VEPlayerActionViewInterface.h"
#import <Masonry/Masonry.h>
#import "VEVideoPlayback.h"
#import "ShortDramaPayViewController.h"
#import "VEPlayerUtility.h"

@interface ShortDramaPayModule () <ShortDramaPayViewControllerDelegate>

@property (nonatomic, strong) ShortDramaPayViewController *payViewController;
@property (nonatomic, weak) id<VEVideoPlayback> playerInterface;
@property (nonatomic, weak) id<VEPlayerActionViewInterface> actionViewInterface;
@property (nonatomic, weak) VEDramaVideoInfoModel *dramaVideoInfo;

@end

@implementation ShortDramaPayModule

VEPlayerContextDILink(playerInterface, VEVideoPlayback, self.context);
VEPlayerContextDILink(actionViewInterface, VEPlayerActionViewInterface, self.context);

#pragma mark - Life Cycle

- (void)moduleDidLoad {
    [super moduleDidLoad];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    @weakify(self);
    [self.context addKey:VEPlayerContextKeyShortDramaShowPayModule withObserver:self handler:^(VEDramaVideoInfoModel *dramaVideoInfo, NSString * _Nullable key) {
        @strongify(self);
        [self configuratoinCustomView];
        self.dramaVideoInfo = dramaVideoInfo;
        [self.payViewController reloadData:dramaVideoInfo];
    }];
    [self.context addKey:VEPlayerContextKeyShortDramaDataModelChanged withObserver:self handler:^(VEDramaVideoInfoModel *dramaVideoInfo, NSString * _Nullable key) {
        @strongify(self);
        self.dramaVideoInfo = dramaVideoInfo;
    }];
    [self.context addKey:VEPlayerContextKeyPlayButtonSingleTap withObserver:self handler:^(id  _Nullable object, NSString * _Nullable key) {
        @strongify(self);
        if (![self.dramaVideoInfo.payInfo isPaid]) {
            [self configuratoinCustomView];
            [self.payViewController reloadData:self.dramaVideoInfo];
        }
    }];
}

- (void)controlViewTemplateDidUpdate {
    [super controlViewTemplateDidUpdate];
}

- (void)configuratoinCustomView {
    UIViewController *topViewController = [VEPlayerUtility lm_topmostViewController];
    if (topViewController) {
        [topViewController addChildViewController:self.payViewController];
        [topViewController.view addSubview:self.payViewController.view];
        [self.payViewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(topViewController.view);
        }];
    }
}

- (void)moduleDidUnLoad {
    [super moduleDidUnLoad];
    [self removePayViewController];
}

- (void)removePayViewController {
    if (self.payViewController) {
        [self.payViewController removeFromParentViewController];
        [self.payViewController.view removeFromSuperview];
        self.payViewController = nil;
    }
}

#pragma mark - ShortDramaPayViewControllerDelegate

- (void)onPayingCallback:(VEDramaVideoInfoModel *)dramaVideoInfo {
    [self removePayViewController];
}

- (void)onPaySuccessCallback:(VEDramaVideoInfoModel *)dramaVideoInfo {
    [self removePayViewController];
    self.dramaVideoInfo = dramaVideoInfo;
    [self.playerInterface playWithMediaSource:[VEDramaVideoInfoModel toVideoEngineSource:dramaVideoInfo]];
    [self.playerInterface play];
}

- (void)onPayCancelCallback:(VEDramaVideoInfoModel *)dramaVideoInfo {
    [self removePayViewController];
}

#pragma mark - Getter

- (ShortDramaPayViewController *)payViewController {
    if (_payViewController == nil) {
        _payViewController = [[ShortDramaPayViewController alloc] init];
        _payViewController.delegate = self;
    }
    return _payViewController;
}

@end
