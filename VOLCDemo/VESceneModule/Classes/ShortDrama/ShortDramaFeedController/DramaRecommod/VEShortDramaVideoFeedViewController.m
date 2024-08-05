//
//  VEShortDramaVideoFeedViewController.m
//  VOLCDemo
//

#import "VEShortDramaVideoFeedViewController.h"
#import "VEShortDramaVideoCellController.h"
#import "VEDataManager.h"
#import "VEVideoModel.h"
#import "VESettingManager.h"
#import "VEPageViewController.h"
#import "VEPlayerKit.h"
#import <Masonry/Masonry.h>
#import "VEDramaDataManager.h"
#import "VEDramaVideoInfoModel.h"
#import "VEShortDramaDetailFeedViewController.h"
#import <MJRefresh/MJRefresh.h>
#import "BTDMacros.h"

static NSInteger VEShortDramaVideoFeedPageCount = 10;
static NSInteger VEShortDramaVideoFeedLoadMoreDetection = 3;

static NSString *VEShortDramaVideoFeedCellReuseID = @"VEShortDramaVideoFeedCellReuseID";

@interface VEShortDramaVideoFeedViewController () <VEPageDataSource, VEPageDelegate, VEShortDramaVideoCellControllerDelegate, VEShortDramaDetailFeedViewControllerDelegate, VEShortDramaDetailFeedViewControllerDataSource>

@property (nonatomic, strong) VEPageViewController *pageContainer;
@property (nonatomic, strong) NSMutableArray<VEDramaVideoInfoModel *> *dramaVideoModels;
@property (nonatomic, assign) NSInteger pageOffset;
@property (nonatomic, assign) BOOL viewDidAppear;
@property (nonatomic, assign) BOOL isLoadingData;
@property (nonatomic, assign) BOOL enableLoadMore;

@end

@implementation VEShortDramaVideoFeedViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.pageOffset = 0;
        self.enableLoadMore = YES;
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.dramaVideoModels) {
        [self startVideoStategy];
        [self setVideoStrategySource:YES];
    }
    self.viewDidAppear = YES;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
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
    
    @weakify(self);
    self.pageContainer.scrollView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        @strongify(self);
        [self loadData:NO];
    }];
    self.pageContainer.scrollView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        @strongify(self);
        [self loadData:YES];
    }];
    self.pageContainer.scrollView.mj_footer.hidden = YES;
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
    
    @weakify(self);
    [VEDramaDataManager requestDramaRecommondList:self.pageOffset pageSize:VEShortDramaVideoFeedPageCount result:^(id  _Nullable responseData, NSString * _Nullable errorMsg) {
        @strongify(self);
        if (!errorMsg) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSArray *resArray = (NSArray *)responseData;
                if (resArray && resArray.count) {
                    if (isLoadMore) {
                        [self.dramaVideoModels addObjectsFromArray:resArray];
                        [self.pageContainer reloadContentSize];
                        [self.pageContainer.scrollView.mj_footer endRefreshing];
                    } else {
                        self.dramaVideoModels = [resArray mutableCopy];
                        [self.pageContainer.scrollView.mj_header endRefreshing];
                        [self.pageContainer reloadData];
                    }
                    
                    // set video strategy source
                    [self setVideoStrategySource:!isLoadMore];
                    
                    self.pageOffset = self.dramaVideoModels.count;
                }
                if (resArray.count < VEShortDramaVideoFeedPageCount) {
                    self.enableLoadMore = NO;
                    self.pageContainer.scrollView.mj_footer.hidden = YES;
                } else {
                    self.enableLoadMore = YES;
                    self.pageContainer.scrollView.mj_footer.hidden = NO;
                }
                self.isLoadingData = NO;
            });
        } else {
            self.isLoadingData = NO;
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

#pragma mark - VEShortDramaDetailFeedViewController Delegate

- (void)shortDramaDetailFeedViewWillback:(VEDramaVideoInfoModel *)dramaVideoInfo {
    for (NSInteger i = 0; i < self.dramaVideoModels.count; i++) {
        VEDramaVideoInfoModel *tempDramaVideoInfo = [self.dramaVideoModels objectAtIndex:i];
        if ([dramaVideoInfo.dramaEpisodeInfo.dramaInfo.dramaId isEqualToString:tempDramaVideoInfo.dramaEpisodeInfo.dramaInfo.dramaId]) {
            [self.dramaVideoModels replaceObjectAtIndex:i withObject:dramaVideoInfo];
            break;
        }
    }
    [(VEShortDramaVideoCellController *)self.pageContainer.currentViewController reloadData:dramaVideoInfo];
}

- (void)shortDramaDetailFeedViewWillPlayNextDrama:(VEDramaVideoInfoModel *)nextDramaVideoInfo {
    for (NSInteger i = 0; i < self.dramaVideoModels.count; i++) {
        VEDramaVideoInfoModel *dramaVideoModel = [self.dramaVideoModels objectAtIndex:i];
        if ([nextDramaVideoInfo.dramaEpisodeInfo.dramaInfo.dramaId isEqualToString:dramaVideoModel.dramaEpisodeInfo.dramaInfo.dramaId]) {
            [self.dramaVideoModels replaceObjectAtIndex:i withObject:nextDramaVideoInfo];
            [self.pageContainer reloadDataWithPageIndex:i animated:YES];
            break;
        }
    }
}

#pragma mark - VEShortDramaDetailFeedViewControllerDataSource

- (NSString *)nextRecommondDramaIdForDramaDetailFeedPlay:(NSString *)currentDramaId {
    for (NSInteger i = 0; i < self.dramaVideoModels.count; i++) {
        VEDramaVideoInfoModel *dramaVideoModel = [self.dramaVideoModels objectAtIndex:i];
        if ([currentDramaId isEqualToString:dramaVideoModel.dramaEpisodeInfo.dramaInfo.dramaId]) {
            if (i + 1 < self.dramaVideoModels.count) {
                VEDramaVideoInfoModel *retDramaVideoModel = [self.dramaVideoModels objectAtIndex:i+1];
                return retDramaVideoModel.dramaEpisodeInfo.dramaInfo.dramaId;
            } else {
                return nil;
            }
            break;
        }
    }
    return nil;
}

#pragma mark - VEShortDramaVideoCellController Delegate

- (void)onDramaDetailVideoPlayFinish:(VEDramaVideoInfoModel *)dramaVideoInfo {
    if (self.pageContainer.currentIndex < (self.dramaVideoModels.count - 1)) {
        if (dramaVideoInfo.dramaEpisodeInfo.episodeNumber == dramaVideoInfo.dramaEpisodeInfo.dramaInfo.totalEpisodeNumber) {
            NSInteger nextPage = self.pageContainer.currentIndex++;
            if (nextPage < self.dramaVideoModels.count) {
                self.pageContainer.currentIndex = nextPage;
            }
        } else {
            VEShortDramaDetailFeedViewController *detailFeedViewController = [[VEShortDramaDetailFeedViewController alloc] initWtihDramaVideoInfo:dramaVideoInfo];
            detailFeedViewController.delegate = self;
            detailFeedViewController.dataSource = self;
            detailFeedViewController.autoPlayNextDaram = YES;
            [self.navigationController pushViewController:detailFeedViewController animated:YES];
        }
    }
}

- (void)dramaVideoWatchDetail:(VEDramaVideoInfoModel *)dramaVideoInfo {
    VEShortDramaDetailFeedViewController *detailFeedViewController = [[VEShortDramaDetailFeedViewController alloc] initWtihDramaVideoInfo:dramaVideoInfo];
    detailFeedViewController.delegate = self;
    detailFeedViewController.dataSource = self;
    [self.navigationController pushViewController:detailFeedViewController animated:YES];
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
    [cell reloadData:[self.dramaVideoModels objectAtIndex:index]];
    return cell;
}

- (BOOL)shouldScrollVertically:(VEPageViewController *)pageViewController{
    return YES;
}

- (void)pageViewController:(VEPageViewController *)pageViewController didDisplayItem:(id<VEPageItem>)viewController {
    if (self.enableLoadMore && ((self.dramaVideoModels.count - 1) - self.pageContainer.currentIndex) <= VEShortDramaVideoFeedLoadMoreDetection) {
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
