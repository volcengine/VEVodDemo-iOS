//
//  ShortDramaSeriesModule.m
//  VEPlayModule
//
//  Created by zyw on 2024/7/16.
//

#import "ShortDramaSeriesModule.h"
#import "VEPlayerContextKeyDefine.h"
#import "VEPlayerActionViewInterface.h"
#import "VEPlayerGestureServiceInterface.h"
#import "VEPlayerGestureHandlerProtocol.h"
#import "ShortDramaSeriesView.h"
#import <Masonry/Masonry.h>
#import "VEDramaVideoInfoModel.h"
#import "VEVideoPlayback.h"

@interface ShortDramaSeriesModule () <ShortDramaSeriesViewDelegate>

@property (nonatomic, strong) ShortDramaSeriesView *seriesView;
@property (nonatomic, weak) id<VEVideoPlayback> playerInterface;
@property (nonatomic, weak) id<VEPlayerGestureServiceInterface> gestureService;
@property (nonatomic, weak) id<VEPlayerActionViewInterface> actionViewInterface;

@end

@implementation ShortDramaSeriesModule

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
    
    @weakify(self);
    [self.context addKey:VEPlayerContextKeyShortDramaDataModelChanged withObserver:self handler:^(VEDramaVideoInfoModel *dramaVideoInfo, NSString *key) {
        @strongify(self);
        [self.seriesView reloadData:dramaVideoInfo];
    }];
    
    [self.context addKey:VEPlayerContextKeySpeedTipViewShowed withObserver:self handler:^(id  _Nullable object, NSString *key) {
        @strongify(self);
        BOOL showSpeedTipView = [object boolValue];
        [UIView animateWithDuration:0.3 animations:^{
            self.seriesView.alpha = showSpeedTipView ? 0 : 1;;
        }];
    }];
}

- (void)controlViewTemplateDidUpdate {
    [super controlViewTemplateDidUpdate];
}

- (void)configuratoinCustomView {
    [self.actionViewInterface.playbackControlView addSubview:self.seriesView];
    [self.seriesView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.actionViewInterface.playbackControlView).with.offset(-20);
        make.left.equalTo(self.actionViewInterface.playbackControlView).with.offset(12);
        make.right.equalTo(self.actionViewInterface.playbackControlView).with.offset(-90);
        make.height.mas_equalTo(ShortDramaSeriesViewHeight);
    }];
}

- (void)moduleDidUnLoad {
    [super moduleDidUnLoad];
    if (self.seriesView) {
        [self.seriesView removeFromSuperview];
        self.seriesView = nil;
    }
}

#pragma mark - ShortDramaSeriesViewDelegate

- (void)onClickSeriesViewCallback {
    if (self.delegate && [self.delegate respondsToSelector:@selector(onClickSeriesViewCallback)]) {
        [self.delegate onClickSeriesViewCallback];
    }
}

#pragma mark - Getter

- (ShortDramaSeriesView *)seriesView {
    if (_seriesView == nil) {
        _seriesView = [[ShortDramaSeriesView alloc] init];
        _seriesView.delegate = self;
    }
    return _seriesView;
}

@end
