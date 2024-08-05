//
//  ShortDramaRecommodIntroduceModule.m
//  VEPlayModule
//
//  Created by zyw on 2024/7/16.
//

#import "ShortDramaRecommodIntroduceModule.h"
#import "VEPlayerContextKeyDefine.h"
#import "VEPlayerActionViewInterface.h"
#import "ShortDramaIntroduceView.h"
#import <Masonry/Masonry.h>
#import "VEDramaVideoInfoModel.h"
#import "VEVideoPlayback.h"

@interface ShortDramaRecommodIntroduceModule ()

@property (nonatomic, strong) ShortDramaIntroduceView *introduceView;
@property (nonatomic, weak) id<VEVideoPlayback> playerInterface;
@property (nonatomic, weak) id<VEPlayerActionViewInterface> actionViewInterface;

@end

@implementation ShortDramaRecommodIntroduceModule

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
}

- (void)controlViewTemplateDidUpdate {
    [super controlViewTemplateDidUpdate];
}

- (void)configuratoinCustomView {
    [self.actionViewInterface.playbackControlView addSubview:self.introduceView];
    
    [self.introduceView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.actionViewInterface.playbackControlView).with.offset(12);
        make.right.equalTo(self.actionViewInterface.playbackControlView).with.offset(-90);
        make.bottom.equalTo(self.actionViewInterface.playbackControlView).with.offset(-20-60);
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
