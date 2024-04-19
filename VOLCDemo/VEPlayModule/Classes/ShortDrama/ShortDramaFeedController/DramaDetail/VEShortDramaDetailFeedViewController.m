//
//  VEShortDramaDetailFeedViewController.m
//  VEPlayModule
//

#import "VEShortDramaDetailFeedViewController.h"
#import "VEShortDramaDetailVideoCellController.h"
#import "ShortDramaSelectionViewController.h"
#import "VEDramaDataManager.h"
#import "VEDramaVideoInfoModel.h"
#import "VESettingManager.h"
#import "UIScrollView+Refresh.h"
#import <VESceneKit/VEPageViewController.h>
#import <VEPlayerKit/VEPlayerKit.h>
#import <Masonry/Masonry.h>

static NSInteger VEShortDramaDetailVideoFeedPageCount = 20;
static NSInteger VEShortDramaDetailVideoFeedLoadMoreDetection = 2;
static NSString *VEShortDramaDetailVideoFeedCellReuseID = @"VEShortDramaDetailVideoFeedCellReuseID";

@interface VEShortDramaDetailFeedViewController () <VEPageDataSource, VEPageDelegate, VEShortDramaDetailVideoCellControllerDelegate, ShortDramaSelectionViewControllerDelegate>

@property (nonatomic, strong) VEPageViewController *pageContainer;
@property (nonatomic, strong) UILabel *dramaEpisodeLabel;
@property (nonatomic, strong) NSMutableArray<VEDramaVideoInfoModel *> *dramaVideoModels;
@property (nonatomic, strong) NSString *fromDramaId;
@property (nonatomic, strong) VEDramaVideoInfoModel *fromDramaVideoInfo;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, assign) NSInteger pageOffset;
@property (nonatomic, assign) BOOL firstLoadData;

@end

@implementation VEShortDramaDetailFeedViewController

- (instancetype)initWtihDramaVideoInfo:(VEDramaVideoInfoModel *)dramaVideoInfo {
    self = [super init];
    if (self) {
        self.firstLoadData = YES;
        self.fromDramaId = dramaVideoInfo.dramaEpisodeInfo.dramaInfo.dramaId;
        self.fromDramaVideoInfo = dramaVideoInfo;
//        self.dramaVideoModels = [NSMutableArray arrayWithObject:dramaVideoInfo];
    }
    return self;
}

- (instancetype)initWtihDramaInfo:(VEDramaInfoModel *)dramaInfo {
    self = [super init];
    if (self) {
        self.fromDramaId = dramaInfo.dramaId;
    }
    return self;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [VEVideoPlayerController clearAllEngineStrategy];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configuratoinCustomView];
    [self startVideoStategy];
    if (self.dramaVideoModels && self.dramaVideoModels.count > 0) {
        [self.pageContainer reloadData];
        [self loadData:NO];
    } else {
        [self loadData:NO];
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
    
    __weak typeof(self) weakSelf = self;
    [self.pageContainer.scrollView systemRefresh:^{
        [weakSelf loadData:NO];
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
}

#pragma mark ----- Data

- (void)loadData:(BOOL)isLoadMore {
    if (isLoadMore) {
        self.pageContainer.scrollView.veLoading = YES;
    } else {
        [self.pageContainer.scrollView beginRefresh];
        [self.dramaVideoModels removeAllObjects];
    }
    
    @weakify(self);
    [VEDramaDataManager requestDramaEpisodeList:self.fromDramaId offset:self.pageOffset pageSize:VEShortDramaDetailVideoFeedPageCount result:^(id  _Nullable responseData, NSString * _Nullable errorMsg) {
        @strongify(self);
        if (!errorMsg) {
            NSArray *resArray = (NSArray *)responseData;
            [self.dramaVideoModels addObjectsFromArray:resArray];
            self.pageOffset = self.dramaVideoModels.count;
            
            // set video strategy source
            [self setVideoStrategySource:!isLoadMore];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self onHandleFromDramaVideoInfo];
                
                if (isLoadMore) {
                    [self.pageContainer reloadContentSize];
                    self.pageContainer.scrollView.veLoading = NO;
                } else {
                    [self.pageContainer reloadData];
                    [self.pageContainer.scrollView endRefresh];
                }

                [self updateDramaTitle];
            });
        } else {
            
        }
    }];
}

- (void)onHandleFromDramaVideoInfo {
    if (self.firstLoadData) {
        self.firstLoadData = NO;
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
                break;
            }
        }
    }
}

#pragma mark - private

- (void)updateDramaTitle {
    if (self.pageContainer.currentIndex < self.dramaVideoModels.count) {
        VEDramaVideoInfoModel *dramaVideoInfo = [self.dramaVideoModels objectAtIndex:self.pageContainer.currentIndex];
        self.dramaEpisodeLabel.text = [NSString stringWithFormat:@"第%@集", @(dramaVideoInfo.dramaEpisodeInfo.episodeNumber)];
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
        if (dramaVideoInfo.dramaEpisodeInfo.episodeNumber == tempDramaVideoInfo.dramaEpisodeInfo.episodeNumber) {
            [self.pageContainer setCurrentIndex:i];
            [self updateDramaTitle];
            break;
        }
    }
}

#pragma mark - VEShortDramaDetailVideoCellController Delegate

- (void)onClickDramaSelectionCallback:(VEDramaVideoInfoModel *)dramaVideoInfo {
    ShortDramaSelectionViewController *selectionViewController = [[ShortDramaSelectionViewController alloc] initWtihDramaVideoInfo:dramaVideoInfo];
    selectionViewController.delegate = self;
    [self presentViewController:selectionViewController animated:YES completion:nil];
}

- (void)dramaVideoPlayFinish:(VEDramaVideoInfoModel *)dramaVideoInfo {
    if (dramaVideoInfo.dramaEpisodeInfo.episodeNumber < self.dramaVideoModels.count) {
        [self.pageContainer reloadNextData];
    }
}

#pragma mark - Event Response

- (void)onBackButtonHandle:(UIButton *)button {
    UIViewController *presentingViewController = self.presentingViewController;
    if (presentingViewController) {
        [presentingViewController dismissViewControllerAnimated:NO completion:nil];
    }
    else if (self.navigationController) {
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
    cell.dramaVideoInfo = [self.dramaVideoModels objectAtIndex:index];
    return cell;
}

- (BOOL)shouldScrollVertically:(VEPageViewController *)pageViewController{
    return YES;
}

- (void)pageViewController:(VEPageViewController *)pageViewController didScrollChangeDirection:(VEPageItemMoveDirection)direction offsetProgress:(CGFloat)progress {
    if (((self.dramaVideoModels.count - 1) - self.pageContainer.currentIndex <= VEShortDramaDetailVideoFeedLoadMoreDetection) && direction == VEPageItemMoveDirectionNext) {
        if (!self.pageContainer.scrollView.veLoading) {
            [self loadData:YES];
        }
    }
}

- (void)pageViewController:(VEPageViewController *)pageViewController willDisplayItem:(id<VEPageItem>)viewController {
    
}

- (void)pageViewController:(VEPageViewController *)pageViewController didDisplayItem:(id<VEPageItem>)viewController {
    [self updateDramaTitle];
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

- (NSMutableArray *)dramaVideoModels {
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
