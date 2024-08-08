//
//  VEShortDramaDetailFeedViewController.m
//  VEPlayModule
//

#import "VEShortDramaDetailFeedViewController.h"
#import "VEShortDramaDetailVideoCellController.h"
#import "ShortDramaSelectionViewController.h"
#import "ShortDramaPayViewController.h"
#import "VEDramaDataManager.h"
#import "VEDramaVideoInfoModel.h"
#import "VESettingManager.h"
#import "VEPageViewController.h"
#import "VEPlayerKit.h"
#import <Masonry/Masonry.h>
#import <MJRefresh/MJRefresh.h>
#import "NSArray+BTDAdditions.h"
#import "BTDMacros.h"
#import "ShortDramaCachePayManager.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "VEPlayerUtility.h"

static NSInteger VEShortDramaDetailVideoFeedPageCount = -1; // default load all
static NSInteger VEShortDramaDetailVideoFeedLoadMoreDetection = 3;
static NSString *VEShortDramaDetailVideoFeedCellReuseID = @"VEShortDramaDetailVideoFeedCellReuseID";

@interface VEShortDramaDetailFeedViewController () <VEPageDataSource, VEPageDelegate, VEShortDramaDetailVideoCellControllerDelegate, ShortDramaSelectionViewControllerDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) VEPageViewController *pageContainer;
@property (nonatomic, strong) ShortDramaSelectionViewController *selectionViewController;
@property (nonatomic, strong) UILabel *dramaEpisodeLabel;
@property (nonatomic, strong) NSMutableArray<VEDramaVideoInfoModel *> *dramaVideoModels;
@property (nonatomic, strong) NSString *lastDramaId;
@property (nonatomic, strong) NSString *fromDramaId;
@property (nonatomic, strong) VEDramaVideoInfoModel *fromDramaVideoInfo;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, assign) BOOL firstLoadData;
@property (nonatomic, assign) BOOL isLoadingData;

@end

@implementation VEShortDramaDetailFeedViewController

- (instancetype)initWtihDramaVideoInfo:(VEDramaVideoInfoModel *)dramaVideoInfo {
    self = [super init];
    if (self) {
        self.firstLoadData = YES;
        self.fromDramaId = dramaVideoInfo.dramaEpisodeInfo.dramaInfo.dramaId;
        self.lastDramaId = self.fromDramaId;
        self.fromDramaVideoInfo = dramaVideoInfo;
        [self.dramaVideoModels addObject:dramaVideoInfo];
    }
    return self;
}

- (instancetype)initWithDramaInfo:(VEDramaInfoModel *)dramaInfo {
    self = [super init];
    if (self) {
        self.fromDramaId = dramaInfo.dramaId;
        self.lastDramaId = self.fromDramaId;
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    self.navigationController.interactivePopGestureRecognizer.delegate = nil;
}

- (void)willMoveToParentViewController:(UIViewController *)parent {
    if (parent == nil) {
        // Synchronize the current playing episode information of the parent page
        [self updateParentPlayDramaVideoInfo];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    
    [self configuratoinCustomView];
    [self firstUpdateDramaTitle];
    
    [self startVideoStategy];
    if (self.dramaVideoModels && self.dramaVideoModels.count > 0) {
        [self.pageContainer reloadData];
    }
    [self loadData:NO dramaId:self.fromDramaId];
 
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onPaySuccessNotificationHandle:) name:VEDramaPaySuccessNotification object:nil];
}

#pragma mark - Pay Success

- (void)onPaySuccessNotificationHandle:(NSNotification *)notification {
    if (self.isLoadingData) {
        return;
    }
    self.isLoadingData = YES;
    VEDramaVideoInfoModel *dramaVideoInfo = [self.dramaVideoModels btd_objectAtIndex:self.pageContainer.currentIndex];
    if (dramaVideoInfo) {
        @weakify(self);
        [VEDramaDataManager requestDramaEpisodeList:dramaVideoInfo.dramaEpisodeInfo.dramaInfo.dramaId episodeNumber:dramaVideoInfo.dramaEpisodeInfo.episodeNumber offset:0 pageSize:VEShortDramaDetailVideoFeedPageCount result:^(id  _Nullable responseData, NSString * _Nullable errorMsg) {
            @strongify(self);
            btd_dispatch_async_on_main_queue(^{
                if (!errorMsg) {
                    // response drama data
                    NSArray<VEDramaVideoInfoModel *> *resArray = (NSArray *)responseData;

                    for (VEDramaVideoInfoModel *dramaVideoInfo in resArray) {
                        for (NSInteger i = 0; i < self.dramaVideoModels.count; i++) {
                            VEDramaVideoInfoModel *targetVideoInfo = [self.dramaVideoModels objectAtIndex:i];
                            if ([dramaVideoInfo.videoId isEqualToString:targetVideoInfo.videoId]) {
                                [self.dramaVideoModels replaceObjectAtIndex:i withObject:dramaVideoInfo];
                                break;
                            }
                        }
                    }
                    [self.pageContainer reloadData];
                } else {
                    BTDLog(@"request pay data error, please try again later.");
                }
                self.isLoadingData = NO;
            });
        }];
    } else {
        self.isLoadingData = NO;
    }
}

#pragma mark ----- UI

- (void)configuratoinCustomView {
    self.view.backgroundColor = [UIColor whiteColor];
    [self addChildViewController:self.pageContainer];
    [self.view addSubview:self.pageContainer.view];
    [self.pageContainer.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self.view addSubview:self.backButton];
    [self.view addSubview:self.dramaEpisodeLabel];
    [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        } else {
            make.top.equalTo(self.view).offset(24);
        }
        make.left.equalTo(self.view).with.offset(5);
        make.size.mas_equalTo(CGSizeMake(44, 44));
    }];
    
    [self.dramaEpisodeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.backButton);
        make.left.equalTo(self.backButton.mas_right);
    }];
    
    @weakify(self);
    self.pageContainer.scrollView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        @strongify(self);
        [self loadData:NO dramaId:self.fromDramaId];
    }];
}

#pragma mark ----- Data

- (void)loadData:(BOOL)isLoadMore dramaId:(NSString *)dramaId {
    if (self.isLoadingData) {
        return;
    }
    self.isLoadingData = YES;
    
    @weakify(self);
    [VEDramaDataManager requestDramaEpisodeList:dramaId episodeNumber:-1 offset:0 pageSize:VEShortDramaDetailVideoFeedPageCount result:^(id  _Nullable responseData, NSString * _Nullable errorMsg) {
        @strongify(self);
        if (!errorMsg) {
            btd_dispatch_async_on_main_queue(^{
                // response drama data
                NSArray *resArray = (NSArray *)responseData;
                
                if (resArray && resArray.count) {
                    if (isLoadMore) {
                        [self.dramaVideoModels addObjectsFromArray:resArray];
                        [self onHandleFromDramaVideoInfo];
                        [self.pageContainer reloadData];
                    } else {
                        self.dramaVideoModels = [resArray mutableCopy];
                        [self.pageContainer.scrollView.mj_header endRefreshing];
                        [self.pageContainer reloadData];
                        [self onHandleFromDramaVideoInfo];
                    }
                    // set video strategy source
                    [self setVideoStrategySource:!isLoadMore];
                    
                    self.pageContainer.scrollView.mj_header.hidden = YES;
                }
                self.isLoadingData = NO;
                [self updateDramaTitle];
            });
        } else {
            self.isLoadingData = NO;
        }
    }];
}

- (void)onHandleFromDramaVideoInfo {
    if (self.firstLoadData) {
        self.firstLoadData = NO;
        BOOL flag = NO;
        for (NSInteger i = 0; i < self.dramaVideoModels.count; i++) {
            VEDramaVideoInfoModel *tempDramaVideoInfo = [self.dramaVideoModels objectAtIndex:i];
            if (self.fromDramaVideoInfo.dramaEpisodeInfo.episodeNumber == tempDramaVideoInfo.dramaEpisodeInfo.episodeNumber) {
                if (self.autoPlayNextDaram) {
                    if ((i + 1) < self.dramaVideoModels.count) {
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.2f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [self.pageContainer reloadDataWithPageIndex:i+1 animated:YES];
                        });
                    }
                } else {
                    if (self.fromDramaVideoInfo.startTime > 0) {
                        tempDramaVideoInfo.startTime = self.fromDramaVideoInfo.startTime;
                    }
                    [self.pageContainer setCurrentIndex:i];
                }
                flag = YES;
                break;
            }
        }
        if (!flag) {
            [self.pageContainer setCurrentIndex:0];
        }
    }
}

#pragma mark - private

- (void)firstUpdateDramaTitle {
    NSInteger episodeNumber = 1;
    if (self.fromDramaVideoInfo) {
        episodeNumber = self.fromDramaVideoInfo.dramaEpisodeInfo.episodeNumber;
    }
    self.dramaEpisodeLabel.text = [NSString stringWithFormat:@"第%@集", @(episodeNumber)];
}

- (void)updateDramaTitle {
    if (self.pageContainer.currentIndex < self.dramaVideoModels.count) {
        VEDramaVideoInfoModel *dramaVideoInfo = [self.dramaVideoModels objectAtIndex:self.pageContainer.currentIndex];
        self.dramaEpisodeLabel.text = [NSString stringWithFormat:@"第%@集", @(dramaVideoInfo.dramaEpisodeInfo.episodeNumber)];
    }
}

- (void)updateParentPlayDramaVideoInfo {
    if (self.delegate && [self.delegate respondsToSelector:@selector(shortDramaDetailFeedViewWillback:)]) {
        VEDramaVideoInfoModel *curDramaVideoInfo = [self.dramaVideoModels objectAtIndex:self.pageContainer.currentIndex];
        // 当前剧集未解锁，找到上一个最近解锁的视频
        if (curDramaVideoInfo.payInfo.payStatus != VEDramaPayStatus_Paid) {
            for (NSInteger i = (self.dramaVideoModels.count - 1); i >= 0; i--) {
                VEDramaVideoInfoModel *retDramaVideoInfo = [self.dramaVideoModels objectAtIndex:i];
                if (retDramaVideoInfo.payInfo.payStatus == VEDramaPayStatus_Paid) {
                    curDramaVideoInfo = retDramaVideoInfo;
                    break;
                }
            }
        }
        [self.delegate shortDramaDetailFeedViewWillback:curDramaVideoInfo];
    }
}

- (void)needLoadMoreDramaVideoInfo {
    if (!self.isLoadingData) {
        if (self.dataSource && [self.dataSource respondsToSelector:@selector(nextRecommondDramaIdForDramaDetailFeedPlay:)]) {
            NSString *nextDramaId = [self.dataSource nextRecommondDramaIdForDramaDetailFeedPlay:self.lastDramaId];
            if (nextDramaId) {
                self.lastDramaId = nextDramaId;
                [self loadData:YES dramaId:self.lastDramaId];
            }
        }
    }
}

#pragma mark - engine startegy

- (void)setVideoStrategySource:(BOOL)reset {
    NSMutableArray *sources = [NSMutableArray array];
    [self.dramaVideoModels enumerateObjectsUsingBlock:^(VEDramaVideoInfoModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [sources addObject:[VEDramaVideoInfoModel toVideoEngineSource:obj]];
    }];
    if (reset) {
        [VEVideoPlayerController setStrategyVideoSources:sources];
    } else {
        [VEVideoPlayerController addStrategyVideoSources:sources];
    }
}

- (void)startVideoStategy {
    VESettingModel *preRender = [[VESettingManager universalManager] settingForKey:VESettingKeyShortVideoPreRenderStrategy];
    if (preRender.open) {
        [VEVideoPlayerController enableEngineStrategy:TTVideoEngineStrategyTypePreRender scene:TTVEngineStrategySceneSmallVideo];
    }
    VESettingModel *preload = [[VESettingManager universalManager] settingForKey:VESettingKeyShortVideoPreloadStrategy];
    if (preload.open) {
        [VEVideoPlayerController enableEngineStrategy:TTVideoEngineStrategyTypePreload scene:TTVEngineStrategySceneSmallVideo];
    }
}

#pragma mark - ShortDramaSelectionViewController Delegate

- (void)onDramaSelectionCallback:(VEDramaVideoInfoModel *)dramaVideoInfo {
    for (NSInteger i = 0; i < self.dramaVideoModels.count; i++) {
        VEDramaVideoInfoModel *tempDramaVideoInfo = [self.dramaVideoModels objectAtIndex:i];
        if ([dramaVideoInfo.dramaEpisodeInfo.dramaInfo.dramaId isEqualToString:tempDramaVideoInfo.dramaEpisodeInfo.dramaInfo.dramaId] && dramaVideoInfo.dramaEpisodeInfo.episodeNumber == tempDramaVideoInfo.dramaEpisodeInfo.episodeNumber) {
            [self.pageContainer setCurrentIndex:i];
            [self updateDramaTitle];
            if (i == (self.dramaVideoModels.count - 1)) {
                [self needLoadMoreDramaVideoInfo];
            }
            break;
        }
    }
}

- (void)onCloseHandleCallback {
    if (self.selectionViewController) {
        [self.selectionViewController removeFromParentViewController];
        [self.selectionViewController.view removeFromSuperview];
        self.selectionViewController = nil;
    }
}

#pragma mark - VEShortDramaDetailVideoCellController Delegate

- (void)onClickDramaSelectionCallback:(VEDramaVideoInfoModel *)dramaVideoInfo {
    _selectionViewController = [[ShortDramaSelectionViewController alloc] initWtihDramaVideoInfo:dramaVideoInfo];
    _selectionViewController.delegate = self;
    [self addChildViewController:_selectionViewController];
    [self.view addSubview:_selectionViewController.view];
}

- (void)onDramaDetailVideoPlayFinish:(VEDramaVideoInfoModel *)dramaVideoInfo {
    if (self.pageContainer.currentIndex < (self.dramaVideoModels.count - 1) ) {
        if (dramaVideoInfo.dramaEpisodeInfo.episodeNumber == dramaVideoInfo.dramaEpisodeInfo.dramaInfo.totalEpisodeNumber) {
            if (self.selectionViewController) {
                [self onCloseHandleCallback];
            }
            VEDramaVideoInfoModel *nextDrama = [self.dramaVideoModels btd_objectAtIndex:self.pageContainer.currentIndex + 1];
            if (nextDrama) {
                MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:UIApplication.sharedApplication.keyWindow animated:YES];
                hud.mode = MBProgressHUDModeText;
                hud.label.text = [NSString stringWithFormat:@"本剧已看完，播放下一步：%@", nextDrama.dramaEpisodeInfo.dramaInfo.dramaTitle];
                hud.offset = CGPointMake(0, [VEPlayerUtility portraitFullScreenBounds].size.height - 100);
                [hud hideAnimated:YES afterDelay:1.5];
            }
        }
        [self.pageContainer reloadNextData];
    } else {
        [self needLoadMoreDramaVideoInfo];
    }
}

- (void)onDramaDetailVideoPlayStart:(VEDramaVideoInfoModel *)dramaVideoInfo {
    if (self.selectionViewController) {
        [self.selectionViewController updateCurrentDramaVideoInfo:dramaVideoInfo];
    }
}

#pragma mark - Event Response

- (void)onBackButtonHandle:(UIButton *)button {
    // Synchronize the current playing episode information of the parent page
    [self updateParentPlayDramaVideoInfo];
        
    UIViewController *presentingViewController = self.presentingViewController;
    if (presentingViewController) {
        [presentingViewController dismissViewControllerAnimated:NO completion:nil];
    } else if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark ---- PageViewControllerDataSource & Delegate

- (NSInteger)numberOfItemInPageViewController:(VEPageViewController *)pageViewController {
    return self.dramaVideoModels.count;
}

- (__kindof UIViewController<VEPageItem> *)pageViewController:(VEPageViewController *)pageViewController pageForItemAtIndex:(NSUInteger)index {
    VEShortDramaDetailVideoCellController *cell = [pageViewController dequeueItemForReuseIdentifier:VEShortDramaDetailVideoFeedCellReuseID];
    if (!cell) {
        cell = [VEShortDramaDetailVideoCellController new];
        cell.reuseIdentifier = VEShortDramaDetailVideoFeedCellReuseID;
    }
    cell.delegate = self;
    [cell reloadData:[self.dramaVideoModels objectAtIndex:index]];
    return cell;
}

- (BOOL)shouldScrollVertically:(VEPageViewController *)pageViewController{
    return YES;
}

- (void)pageViewController:(VEPageViewController *)pageViewController willDisplayItem:(id<VEPageItem>)viewController {
    
}

- (void)pageViewController:(VEPageViewController *)pageViewController didDisplayItem:(id<VEPageItem>)viewController {
    [self updateDramaTitle];
    // load next drama
    if (((self.dramaVideoModels.count - 1) - self.pageContainer.currentIndex) <= VEShortDramaDetailVideoFeedLoadMoreDetection) {
        [self needLoadMoreDramaVideoInfo];
    }
    // recommond view sync next drama
    VEDramaVideoInfoModel *dramaVideoInfo = [self.dramaVideoModels btd_objectAtIndex:self.pageContainer.currentIndex];
    if (dramaVideoInfo) {
        if (![dramaVideoInfo.dramaEpisodeInfo.dramaInfo.dramaId isEqualToString:self.fromDramaId]) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(shortDramaDetailFeedViewWillPlayNextDrama:)]) {
                [self.delegate shortDramaDetailFeedViewWillPlayNextDrama:dramaVideoInfo];
            }
        }
    }
}

#pragma mark ----- Lazy load

- (VEPageViewController *)pageContainer {
    if (!_pageContainer) {
        _pageContainer = [VEPageViewController new];
        _pageContainer.dataSource = self;
        _pageContainer.delegate = self;
        _pageContainer.scrollView.directionalLockEnabled = YES;
        _pageContainer.scrollView.scrollsToTop = NO;
    }
    return _pageContainer;
}

- (NSMutableArray<VEDramaVideoInfoModel *> *)dramaVideoModels {
    if (!_dramaVideoModels) {
        _dramaVideoModels = [NSMutableArray array];
    }
    return _dramaVideoModels;
}

- (UIButton *)backButton {
    if (_backButton == nil) {
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backButton setImage:[UIImage imageNamed:@"video_page_back"] forState:UIControlStateNormal];
        [_backButton addTarget:self action:@selector(onBackButtonHandle:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backButton;
}

- (UILabel *)dramaEpisodeLabel {
    if (_dramaEpisodeLabel == nil) {
        _dramaEpisodeLabel = [[UILabel alloc] init];
        _dramaEpisodeLabel.textColor = [UIColor whiteColor];
        _dramaEpisodeLabel.font = [UIFont boldSystemFontOfSize:17];
    }
    return _dramaEpisodeLabel;
}

#pragma mark ----- VEShortDramaDetailVideoCellControllerDelegate

- (void)shortVideoController:(VEShortDramaDetailVideoCellController *)controller shouldLockVerticalScroll:(BOOL)shouldLock {
    self.pageContainer.scrollView.scrollEnabled = !shouldLock;
}

@end
