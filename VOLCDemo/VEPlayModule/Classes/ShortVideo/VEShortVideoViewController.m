//
//  VEShortVideoViewController.m
//  VOLCDemo
//
//  Created by real on 2022/8/22.
//  Copyright © 2022 ByteDance. All rights reserved.
//

#import "VEShortVideoViewController.h"
#import "VEShortVideoCellController.h"
#import "VEDataManager.h"
#import "VEVideoModel.h"
#import "VESettingManager.h"
#import "UIScrollView+Refresh.h"

#import <VESceneKit/VEPageViewController.h>
#import <VEPlayerKit/VEPlayerKit.h>
#import <Masonry/Masonry.h>

static NSInteger VEShortVideoPageCount = 10;

static NSInteger VEShortVideoLoadMoreDetection = 2;

static NSString *VEShortVideoCellReuseID = @"VEShortVideoCellReuseID";

@interface VEShortVideoViewController () <VEPageDataSource, VEPageDelegate, VEShortVideoCellControllerDelegate>

@property (nonatomic, strong) VEPageViewController *pageContainer;

@property (nonatomic, strong) UIButton *backButton;

@property (nonatomic, strong) NSMutableArray<VEVideoModel *> *videoModels;

@end

@implementation VEShortVideoViewController

- (instancetype)initWtihVideoSources:(NSArray<VEVideoModel *> *)videoModels {
    self = [super init];
    if (self) {
        self.videoModels = [videoModels mutableCopy];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initialUI];
    [self startVideoStategy];
    if (self.videoModels && self.videoModels.count > 0) {
        // set video strategy source
        [self setVideoStrategySource:YES];
        
        [self.pageContainer reloadData];
    } else {
        [self loadData:NO];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [VEVideoPlayerController clearAllEngineStrategy];
}


#pragma mark ---- ATPageViewControllerDataSource & Delegate
- (NSInteger)numberOfItemInPageViewController:(VEPageViewController *)pageViewController {
    return self.videoModels.count;
}

// 类似于UITableView的cellForRow，提供对应index的item元素
- (__kindof UIViewController<VEPageItem> *)pageViewController:(VEPageViewController *)pageViewController pageForItemAtIndex:(NSUInteger)index {
    VEShortVideoCellController *cell = [pageViewController dequeueItemForReuseIdentifier:VEShortVideoCellReuseID];
    if (!cell) {
        cell = [VEShortVideoCellController new];
        cell.reuseIdentifier = VEShortVideoCellReuseID;
    }
    cell.delegate = self;
    cell.videoModel = [self.videoModels objectAtIndex:index];
    return cell;
}

- (BOOL)shouldScrollVertically:(VEPageViewController *)pageViewController{
    return YES;
}

- (void)pageViewController:(VEPageViewController *)pageViewController
  didScrollChangeDirection:(VEPageItemMoveDirection)direction
            offsetProgress:(CGFloat)progress {
    if (((self.videoModels.count - 1) - self.pageContainer.currentIndex <= VEShortVideoLoadMoreDetection) && direction == VEPageItemMoveDirectionNext) {
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

- (UIButton *)backButton {
    if (!_backButton) {
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backButton setImage:[UIImage imageNamed:@"video_page_back"] forState:UIControlStateNormal];
        [_backButton addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backButton;
}

- (NSMutableArray *)videoModels {
    if (!_videoModels) {
        _videoModels = [NSMutableArray array];
    }
    return _videoModels;
}


#pragma mark ----- Data

- (void)loadData:(BOOL)isLoadMore {
    if (isLoadMore) {
        self.pageContainer.scrollView.veLoading = YES;
    } else {
        [self.pageContainer.scrollView beginRefresh];
        [self.videoModels removeAllObjects];
    }
    [VEDataManager dataForScene:VESceneTypeShortVideo range:NSMakeRange(self.videoModels.count, VEShortVideoPageCount) result:^(NSArray<VEVideoModel *> *videoModels) {
        [self.videoModels addObjectsFromArray:videoModels];
        
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
    }];
}

- (void)setVideoStrategySource:(BOOL)reset {
    NSMutableArray *sources = [NSMutableArray array];
    [self.videoModels enumerateObjectsUsingBlock:^(VEVideoModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [sources addObject:[VEVideoModel ConvertVideoEngineSource:obj]];
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


#pragma mark ----- UI
- (void)initialUI {
    self.view.backgroundColor = [UIColor whiteColor];
    [self addChildViewController:self.pageContainer];
    [self.view addSubview:self.pageContainer.view];
    [self.pageContainer.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    [self.view addSubview:self.backButton];
    [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(20);
        } else {
            make.top.equalTo(self.view).offset(24);
        }
        make.leading.equalTo(self.view).offset(10);
        make.size.equalTo(@(CGSizeMake(44, 44)));
    }];
    __weak typeof(self) weakSelf = self;
    [self.pageContainer.scrollView systemRefresh:^{
        [weakSelf loadData:NO];
    }];
}


#pragma mark ----- VEShortVideoCellControllerDelegate

- (void)shortVideoController:(VEShortVideoCellController *)controller shouldLockVerticalScroll:(BOOL)shouldLock {
    self.pageContainer.scrollView.scrollEnabled = !shouldLock;
}

@end
