//
//  VEShortDramaVideoFeedViewController.m
//  VOLCDemo
//

#import "VEShortDramaVideoFeedViewController.h"
#import "VEShortDramaVideoCellController.h"
#import "VEDataManager.h"
#import "VEVideoModel.h"
#import "VESettingManager.h"
#import "UIScrollView+Refresh.h"
#import "VEPageViewController.h"
#import "VEPlayerKit.h"
#import <Masonry/Masonry.h>
#import "VEDramaDataManager.h"
#import "VEDramaVideoInfoModel.h"
#import "VEShortDramaDetailFeedViewController.h"
#import <MJRefresh/MJRefresh.h>

static NSInteger VEShortDramaVideoFeedPageCount = 10;
static NSInteger VEShortDramaVideoFeedLoadMoreDetection = 3;

static NSString *VEShortDramaVideoFeedCellReuseID = @"VEShortDramaVideoFeedCellReuseID";

@interface VEShortDramaVideoFeedViewController () <VEPageDataSource, VEPageDelegate, VEShortDramaVideoCellControllerDelegate>

@property (nonatomic, strong) VEPageViewController *pageContainer;
@property (nonatomic, strong) NSMutableArray<VEDramaVideoInfoModel *> *dramaVideoModels;
@property (nonatomic, assign) NSInteger pageOffset;
@property (nonatomic, assign) BOOL viewDidAppear;
@property (nonatomic, assign) BOOL isLoadingData;

@end

@implementation VEShortDramaVideoFeedViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.pageOffset = 0;
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.viewDidAppear = YES;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if (self.viewDidAppear) {
        [VEVideoPlayerController clearAllEngineStrategy];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configuratoinCustomView];
    [self startVideoStategy];
    [self loadData:NO];
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
    self.pageContainer.scrollView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf loadData:NO];
    }];
    
    self.pageContainer.scrollView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf loadData:YES];
    }];
}

#pragma mark ----- Data

- (void)loadData:(BOOL)isLoadMore {
    if (self.isLoadingData) {
        return;
    }
    self.isLoadingData = YES;
    
    if (!isLoadMore) {
        self.pageOffset = 0;
        self.pageContainer.scrollView.mj_footer.hidden = NO;
    }
    
    __weak typeof(self) weakSelf = self;
    [VEDramaDataManager requestDramaRecommondList:self.pageOffset pageSize:VEShortDramaVideoFeedPageCount result:^(id  _Nullable responseData, NSString * _Nullable errorMsg) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!errorMsg) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSArray *resArray = (NSArray *)responseData;
                if (resArray && resArray.count) {
                    // set video strategy source
                    [strongSelf setVideoStrategySource:!isLoadMore];
                    
                    if (isLoadMore) {
                        [strongSelf.dramaVideoModels addObjectsFromArray:resArray];
                        [strongSelf.pageContainer reloadContentSize];
                        [strongSelf.pageContainer.scrollView.mj_footer endRefreshing];
                    } else {
                        strongSelf.dramaVideoModels = [resArray mutableCopy];
                        [strongSelf.pageContainer.scrollView.mj_header endRefreshing];
                        [strongSelf.pageContainer reloadData];
                    }
                    strongSelf.isLoadingData = NO;
                    strongSelf.pageOffset = strongSelf.dramaVideoModels.count;
                } else {
                    strongSelf.pageContainer.scrollView.mj_footer.hidden = YES;
                }
            });
        } else {
            strongSelf.isLoadingData = NO;
        }
    }];
}

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

#pragma mark - VEShortDramaVideoCellController Delegate

- (void)dramaVideoPlayFinish:(VEDramaVideoInfoModel *)dramaVideoInfo {
    if (self.pageContainer.currentIndex < (self.dramaVideoModels.count - 1)) {
        if (dramaVideoInfo.dramaEpisodeInfo.episodeNumber == dramaVideoInfo.dramaEpisodeInfo.dramaInfo.totalEpisodeNumber) {
            NSInteger nextPage = self.pageContainer.currentIndex++;
            if (nextPage < self.dramaVideoModels.count) {
                self.pageContainer.currentIndex = nextPage;
            }
        } else {
            VEShortDramaDetailFeedViewController *detailFeedViewController = [[VEShortDramaDetailFeedViewController alloc] initWtihDramaVideoInfo:dramaVideoInfo];
            detailFeedViewController.autoPlayNextDaram = YES;
            [self.navigationController pushViewController:detailFeedViewController animated:YES];
        }
    }
}

#pragma mark ---- PageViewControllerDataSource & Delegate

- (NSInteger)numberOfItemInPageViewController:(VEPageViewController *)pageViewController {
    return self.dramaVideoModels.count;
}

- (__kindof UIViewController<VEPageItem> *)pageViewController:(VEPageViewController *)pageViewController pageForItemAtIndex:(NSUInteger)index {
    VEShortDramaVideoCellController *cell = [pageViewController dequeueItemForReuseIdentifier:VEShortDramaVideoFeedCellReuseID];
    if (!cell) {
        cell = [VEShortDramaVideoCellController new];
        cell.delegate = self;
        cell.reuseIdentifier = VEShortDramaVideoFeedCellReuseID;
    }
    cell.dramaVideoInfo = [self.dramaVideoModels objectAtIndex:index];
    return cell;
}

- (BOOL)shouldScrollVertically:(VEPageViewController *)pageViewController{
    return YES;
}

- (void)pageViewController:(VEPageViewController *)pageViewController didDisplayItem:(id<VEPageItem>)viewController {
    if (((self.dramaVideoModels.count - 1) - self.pageContainer.currentIndex) <= VEShortDramaVideoFeedLoadMoreDetection) {
        [self loadData:YES];
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

- (NSMutableArray *)dramaVideoModels {
    if (!_dramaVideoModels) {
        _dramaVideoModels = [NSMutableArray array];
    }
    return _dramaVideoModels;
}

#pragma mark ----- VEShortDramaVideoCellControllerDelegate

- (void)shortVideoController:(VEShortDramaVideoCellController *)controller shouldLockVerticalScroll:(BOOL)shouldLock {
    self.pageContainer.scrollView.scrollEnabled = !shouldLock;
}

@end
