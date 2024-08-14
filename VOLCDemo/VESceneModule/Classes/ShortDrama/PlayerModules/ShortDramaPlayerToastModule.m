//
//  ShortDramaPlayerToastModule.m
//  VESceneModule
//
//  Created by zyw on 2024/8/7.
//

#import "ShortDramaPlayerToastModule.h"
#import "VEPlayerContextKeyDefine.h"
#import "VEPlayerActionViewInterface.h"
#import <Masonry/Masonry.h>
#import "VEVideoPlayback.h"
#import "VEDramaVideoInfoModel.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "VEPlayerUtility.h"

@interface ShortDramaPlayerToastModule ()

@property (nonatomic, weak) id<VEVideoPlayback> playerInterface;
@property (nonatomic, weak) id<VEPlayerActionViewInterface> actionViewInterface;
@property (nonatomic, weak) VEDramaVideoInfoModel *dramaVideoInfo;

@end

@implementation ShortDramaPlayerToastModule

VEPlayerContextDILink(playerInterface, VEVideoPlayback, self.context);
VEPlayerContextDILink(actionViewInterface, VEPlayerActionViewInterface, self.context);

#pragma mark - Life Cycle

- (void)moduleDidLoad {
    [super moduleDidLoad];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    @weakify(self);
    [self.context addKey:VEPlayerContextKeyShortDramaDataModelChanged withObserver:self handler:^(VEDramaVideoInfoModel *dramaVideoInfo, NSString * _Nullable key) {
        @strongify(self);
        self.dramaVideoInfo = dramaVideoInfo;
    }];
    
    [self.context addKey:VEPlayerContextKeyShowToastModule withObserver:self handler:^(NSString *message, NSString * _Nullable key) {
        @strongify(self);
        if (message) {
            [self showToast:message];
        }
    }];
}

- (void)controlViewTemplateDidUpdate {
    [super controlViewTemplateDidUpdate];
}

- (void)configuratoinCustomView {
    
}

- (void)moduleDidUnLoad {
    [super moduleDidUnLoad];
}

- (void)showToast:(NSString *)message {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:UIApplication.sharedApplication.keyWindow animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.label.text = message;
    hud.offset = CGPointMake(0, 50);
    [hud hideAnimated:YES afterDelay:1.5];
}

@end
