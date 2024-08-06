//
//  ShortDramaIntroduceModule.m
//  VEPlayModule
//
//  Created by zyw on 2024/7/15.
//

#import "ShortDramaIntroduceModule.h"
#import "VEPlayerContextKeyDefine.h"
#import "VEPlayerActionViewInterface.h"
#import "ShortDramaIntroduceView.h"
#import <Masonry/Masonry.h>
#import "VEDramaVideoInfoModel.h"
#import "VEVideoPlayback.h"

@interface ShortDramaIntroduceModule ()

@property (nonatomic, strong) ShortDramaIntroduceView *introduceView;
@property (nonatomic, weak) id<VEVideoPlayback> playerInterface;
@property (nonatomic, weak) id<VEPlayerActionViewInterface> actionViewInterface;

@end

@implementation ShortDramaIntroduceModule

VEPlayerContextDILink(playerInterface, VEVideoPlayback, self.context);
VEPlayerContextDILink(actionViewInterface, VEPlayerActionViewInterface, self.context);

#pragma mark - Life Cycle

- (void)moduleDidLoad {
    [super moduleDidLoad];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configuratoinCustomView];
    
    @weakify(self);
    [self.context addKey:VEPlayerContextKeyShortDramaDataModelChanged withObserver:self handler:^(VEDramaVideoInfoModel *dramaVideoInfo, NSString *key) {
        @strongify(self);
        [self.introduceView reloadData:dramaVideoInfo];
    }];
    [self.context addKey:VEPlayerContextKeySliderSeekBegin withObserver:self handler:^(id  _Nullable object, NSString *key) {
        @strongify(self);
        [self.introduceView showView:NO];
    }];
    [self.context addKeys:@[VEPlayerContextKeySliderCancel, VEPlayerContextKeySliderSeekEnd] withObserver:self handler:^(id  _Nullable object, NSString *key) {
        @strongify(self);
        [self.introduceView showView:YES];
    }];
    
    [self.context addKey:VEPlayerContextKeySpeedTipViewShowed withObserver:self handler:^(id  _Nullable object, NSString *key) {
        @strongify(self);
        BOOL showSpeedTipView = [object boolValue];
        [self.introduceView showView:!showSpeedTipView];
    }];
}

- (void)controlViewTemplateDidUpdate {
    [super controlViewTemplateDidUpdate];
}

- (void)configuratoinCustomView {
    [self.actionViewInterface.playbackControlView addSubview:self.introduceView];
    
    [self.introduceView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.actionViewInterface.playbackControlView).with.offset(-20);
        make.left.equalTo(self.actionViewInterface.playbackControlView).with.offset(12);
        make.right.equalTo(self.actionViewInterface.playbackControlView).with.offset(-90);
        make.height.mas_equalTo(ShortDramaIntroduceViewHeight);
    }];
}

- (void)moduleDidUnLoad {
    [super moduleDidUnLoad];
    if (self.introduceView) {
        [self.introduceView removeFromSuperview];
        self.introduceView = nil;
    }
}

#pragma mark - Getter

- (ShortDramaIntroduceView *)introduceView {
    if (_introduceView == nil) {
        _introduceView = [[ShortDramaIntroduceView alloc] init];
    }
    return _introduceView;
}

@end
