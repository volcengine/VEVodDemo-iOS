//
//  ShortDramaSelectionModule.m
//  VEPlayModule
//
//  Created by zyw on 2024/7/15.
//

#import "ShortDramaSelectionModule.h"
#import "VEPlayerContextKeyDefine.h"
#import "VEPlayerActionViewInterface.h"
#import "VEPlayerGestureServiceInterface.h"
#import "VEPlayerGestureHandlerProtocol.h"
#import "ShortDramaSelectionView.h"
#import <Masonry/Masonry.h>
#import "VEDramaVideoInfoModel.h"
#import "VEVideoPlayback.h"

@interface ShortDramaSelectionModule () <ShortDramaSelectionViewDelegate>

@property (nonatomic, strong) ShortDramaSelectionView *selectionView;
@property (nonatomic, weak) id<VEVideoPlayback> playerInterface;
@property (nonatomic, weak) id<VEPlayerGestureServiceInterface> gestureService;
@property (nonatomic, weak) id<VEPlayerActionViewInterface> actionViewInterface;

@end

@implementation ShortDramaSelectionModule

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
        [self.selectionView reloadData:dramaVideoInfo];
    }];
    [self.context addKey:VEPlayerContextKeySpeedTipViewShowed withObserver:self handler:^(id  _Nullable object, NSString *key) {
        @strongify(self);
        BOOL showSpeedTipView = [object boolValue];
        [self.selectionView showView:!showSpeedTipView];
    }];
}

- (void)controlViewTemplateDidUpdate {
    [super controlViewTemplateDidUpdate];
}

- (void)configuratoinCustomView {
    [self.actionViewInterface.playerContainerView addSubview:self.selectionView];
    [self.selectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.actionViewInterface.playerContainerView).with.offset(12);
        make.right.equalTo(self.actionViewInterface.playerContainerView).with.offset(-12);
        make.bottom.equalTo(self.actionViewInterface.playerContainerView).with.offset(-33);
        make.height.mas_equalTo(ShortDramaSelectionViewHeight);
    }];
}

- (void)moduleDidUnLoad {
    [super moduleDidUnLoad];
    if (self.selectionView) {
        [self.selectionView removeFromSuperview];
        self.selectionView = nil;
    }
}

#pragma mark - ShortDramaSelectionViewDelegate

- (void)onClickDramaSelectionCallback {
    if (self.delegate && [self.delegate respondsToSelector:@selector(onClickDramaSelectionCallback)]) {
        [self.delegate onClickDramaSelectionCallback];
    }
}

#pragma mark - Getter

- (ShortDramaSelectionView *)selectionView {
    if (_selectionView == nil) {
        _selectionView = [[ShortDramaSelectionView alloc] init];
        _selectionView.delegate = self;
    }
    return _selectionView;
}

@end
