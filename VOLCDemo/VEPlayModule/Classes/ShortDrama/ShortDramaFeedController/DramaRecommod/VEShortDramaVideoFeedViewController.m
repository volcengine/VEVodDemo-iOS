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
#import <VESceneKit/VEPageViewController.h>
#import <VEPlayerKit/VEPlayerKit.h>
#import <Masonry/Masonry.h>
#import "VEDramaDataManager.h"
#import "VEDramaVideoInfoModel.h"

static NSInteger VEShortDramaVideoFeedPageCount = 30;
static NSInteger VEShortDramaVideoFeedLoadMoreDetection = 2;

static NSString *VEShortDramaVideoFeedCellReuseID = @"VEShortDramaVideoFeedCellReuseID";

@interface VEShortDramaVideoFeedViewController () <VEPageDataSource, VEPageDelegate>

@property (nonatomic, strong) VEPageViewController *pageContainer;
@property (nonatomic, strong) NSMutableArray<VEDramaVideoInfoModel *> *dramaVideoModels;
@property (nonatomic, assign) NSInteger pageOffset;
@property (nonatomic, assign) BOOL viewDidAppear;

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
    [self.pageContainer.scrollView systemRefresh:^{
        [weakSelf loadData:NO];
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
    [VEDramaDataManager requestDramaRecommondList:self.pageOffset pageSize:VEShortDramaVideoFeedPageCount result:^(id  _Nullable responseData, NSString * _Nullable errorMsg) {
        @strongify(self);
        if (!errorMsg) {
            NSArray *resArray = (NSArray *)responseData;
            self.dramaVideoModels = [resArray mutableCopy];
            [self.dramaVideoModels addObjectsFromArray:resArray];
            self.pageOffset = self.dramaVideoModels.count;
            
            // set video strategy source
            [self setVideoStrategySource:!isLoadMore];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (isLoadMore) {
                    [self.pageContainer reloadContentSize];
                    self.pageContainer.scrollView.veLoading = NO;
                } else {
                    [self.pageContainer reloadData];
                    [self.pageContainer.scrollView endRefresh];
                }
            });
        } else {
            
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

#pragma mark ---- ATPageViewControllerDataSource & Delegate
- (NSInteger)numberOfItemInPageViewController:(VEPageViewController *)pageViewController {
    return self.dramaVideoModels.count;
}

- (__kindof UIViewController<VEPageItem> *)pageViewController:(VEPageViewController *)pageViewController pageForItemAtIndex:(NSUInteger)index {
    VEShortDramaVideoCellController *cell = [pageViewController dequeueItemForReuseIdentifier:VEShortDramaVideoFeedCellReuseID];
    if (!cell) {
        cell = [VEShortDramaVideoCellController new];
        cell.reuseIdentifier = VEShortDramaVideoFeedCellReuseID;
    }
    cell.videoModel = [self.dramaVideoModels objectAtIndex:index];
    return cell;
}

- (BOOL)shouldScrollVertically:(VEPageViewController *)pageViewController{
    return YES;
}

- (void)pageViewController:(VEPageViewController *)pageViewController
  didScrollChangeDirection:(VEPageItemMoveDirection)direction
            offsetProgress:(CGFloat)progress {
    if (((self.dramaVideoModels.count - 1) - self.pageContainer.currentIndex <= VEShortDramaVideoFeedLoadMoreDetection) && direction == VEPageItemMoveDirectionNext) {
        if (!self.pageContainer.scrollView.veLoading) {
            [self loadData:YES];
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
