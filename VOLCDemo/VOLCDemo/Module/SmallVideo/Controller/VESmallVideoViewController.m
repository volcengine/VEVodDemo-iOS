//
//  VESmallVideoViewController.m
//  VOLCDemo
//
//  Created by wangzhiyong on 2021/5/24.
//  Copyright © 2021 ByteDance. All rights reserved.
//

#import "VESmallVideoViewController.h"
#import "VEVideoPlayerViewController.h"
#import "VEUserGlobalConfigViewController.h"
#import "UITableView+VE.h"
#import "VECustomHeaderView.h"
#import "VEVideoModel.h"
#import "VENetworkHelper.h"
#import "VESmallVideoFeedCell.h"
#import <TTSDK/TTVideoEngine+Strategy.h>
#import <TTSDK/TTVideoEngineMediaSource.h>
#import "VEUserGlobalConfiguration.h"
#import "MJRefresh.h"

NSString * const VOLCSmallVideoRequestVideoModels = @"http://vod-app-server.snssdk.com/api/general/v1/getFeedStreamWithPlayAuthToken";

NSString * const kSmallVideoFeedCellIdentifier = @"kSmallVideoFeedCellIdentifier";

@interface VESmallVideoViewController () <VECustomHeaderViewDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSMutableArray<VEVideoModel *> *videoModels;
@property (nonatomic, assign) NSInteger requestOffset;

@property (nonatomic, strong) VECustomHeaderView *headerView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSIndexPath *currentPlayIndexPath;
@property (nonatomic, strong) NSIndexPath *willPlayIndexPath;
@property (nonatomic, strong) VESmallVideoFeedCell *currentPlayCell;

@property (nonatomic, assign) BOOL shouldPlayInAdvance;
@property (nonatomic, assign) BOOL isDragging;
@property (nonatomic, assign) CGFloat lastContentOffsetY;
@property (nonatomic, assign) NSTimeInterval lastCheckPlayTimeInAdvance;

@end

@implementation VESmallVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.shouldPlayInAdvance = YES; // default open play advance

    [self enableVideoEngineStategy];
    
    [self configuratoinCustomView];
    
    [self loadVideoData:0];
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

#pragma mark - UI

- (void)configuratoinCustomView {
    self.view.backgroundColor = [UIColor blackColor];
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    [self.tableView registerClass:[VESmallVideoFeedCell class] forCellReuseIdentifier:kSmallVideoFeedCellIdentifier];
    
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        self.requestOffset = 0;
        [self loadVideoData:self.requestOffset];
    }];
    
    @weakify(self);
    MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        @strongify(self);
        [self loadVideoData:self.requestOffset];
    }];
    self.tableView.mj_footer = footer;
    
    [self.view addSubview:self.headerView];
    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.top.mas_equalTo(self.view.mas_safeAreaLayoutGuideTop);
        } else {
            make.bottom.equalTo(self.view).with.offset(20);
        }
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.height.mas_equalTo(50);
    }];
}

#pragma mark - Engine Strategy

- (void)enableVideoEngineStategy {
    if ([[VEUserGlobalConfiguration sharedInstance] commonStrategyEnabled]) {
        [TTVideoEngine enableEngineStrategy:TTVideoEngineStrategyTypeCommon scene:TTVEngineStrategySceneSmallVideo];
    }
    if ([[VEUserGlobalConfiguration sharedInstance] preloadStrategyEnabled]) {
        [TTVideoEngine enableEngineStrategy:TTVideoEngineStrategyTypePreload scene:TTVEngineStrategySceneSmallVideo];
    }
    if ([[VEUserGlobalConfiguration sharedInstance] preRenderStrategyEnabled]) {
        [TTVideoEngine setPreRenderVideoEngineDelegate:[VEPreRenderVideoEngineMediatorDelegate shareInstance]];
        [TTVideoEngine enableEngineStrategy:TTVideoEngineStrategyTypePreRender scene:TTVEngineStrategySceneSmallVideo];
    }
}

- (void)configVideoEngineStrategyMediaSources:(NSArray<VEVideoModel *> *)videoModels refresh:(BOOL)refresh {
    if ([[VEUserGlobalConfiguration sharedInstance] preRenderStrategyEnabled] ||
        [[VEUserGlobalConfiguration sharedInstance] preloadStrategyEnabled]) {
        NSMutableArray *sources = [NSMutableArray array];
        [videoModels enumerateObjectsUsingBlock:^(VEVideoModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [sources addObject:[VEVideoModel videoEngineVidSource:obj]];
        }];
        if (refresh) {
            [TTVideoEngine setStrategyVideoSources:sources];
        } else {
            [TTVideoEngine addStrategyVideoSources:sources];
        }
    }
}


#pragma mark - Load Data

- (void)loadVideoData:(NSInteger)requestOffset {
    NSDictionary *paramDic = @{ @"userID" : @"small-video", @"offset" : @(requestOffset), @"pageSize" : @(20) };
    @weakify(self);
    [VENetworkHelper requestDataWithUrl:VOLCSmallVideoRequestVideoModels httpMethod:@"POST" parameters:paramDic success:^(id  _Nonnull responseObject) {
        @strongify(self);
        if (requestOffset == 0) {
            [self.videoModels removeAllObjects];
        }
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *responseDictionary = responseObject;
            NSArray *retVideoList = [responseDictionary objectForKey:@"result"];
            NSMutableArray *tempVideoModles = [NSMutableArray array];
            for (NSDictionary *itemDictionary in retVideoList) {
                VEVideoModel *videoModel = [[VEVideoModel alloc] initWithJsonDictionary:itemDictionary];
                [tempVideoModles addObject:videoModel];
            }
            
            [self configVideoEngineStrategyMediaSources:tempVideoModles refresh:requestOffset == 0];
            self.requestOffset += tempVideoModles.count;
            [self.videoModels addObjectsFromArray:tempVideoModles];
            [self.tableView reloadData];
            [self __play];
            
            /// update refresh view status
            [self uddateRefreshViewStatus:requestOffset == 0 hasMoreData:tempVideoModles.count];
        }
    } failure:^(NSString * _Nonnull errorMessage) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.label.text = errorMessage;
        [hud hideAnimated:YES afterDelay:2.0];
    }];
}

- (void)uddateRefreshViewStatus:(BOOL)refresh hasMoreData:(BOOL)hasMore {
    if (refresh) {
        [self.tableView.mj_header endRefreshing];
    } else {
        if (hasMore) {
            [self.tableView.mj_footer endRefreshing];
        } else {
            [self.tableView.footer endRefreshingWithNoMoreData];
        }
    }
}

#pragma mark - UITableView delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.videoModels.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return CGRectGetHeight(self.view.frame);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    VESmallVideoFeedCell *cell = [tableView dequeueReusableCellWithIdentifier:kSmallVideoFeedCellIdentifier];
    if (!cell) {
        cell = [[VESmallVideoFeedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kSmallVideoFeedCellIdentifier];
    }
    if (cell) {
        cell.indexPath = indexPath.row;
        [cell configWithVideoModel:[self.videoModels objectAtIndex:indexPath.row]];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    self.willPlayIndexPath = indexPath;
    [(VESmallVideoFeedCell *)cell configWithVideoModel:[self.videoModels objectAtIndex:indexPath.row]];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.isDragging) {
        return;
    }
    
    CGFloat oldContentOffsetY = self.lastContentOffsetY;
    self.lastContentOffsetY = scrollView.contentOffset.y;
    
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    if (now - self.lastCheckPlayTimeInAdvance < 0.05) {
        return;
    }
    self.lastCheckPlayTimeInAdvance = now;
    
    if (self.lastContentOffsetY > oldContentOffsetY) {
        // scroll up
        if (self.currentPlayIndexPath.row < self.willPlayIndexPath.row) {
            NSIndexPath *currentIndexPath = [self.tableView currentIndexPathForFullScreenCell];
            if (currentIndexPath.row == self.willPlayIndexPath.row) {
                [self __playNextVideoInAdvance];
            }
        }
    } else {
        // scroll down
        if (self.currentPlayIndexPath.row > self.willPlayIndexPath.row) {
            NSIndexPath *currentIndexPath = [self.tableView currentIndexPathForFullScreenCell];
            if (currentIndexPath.row == self.willPlayIndexPath.row) {
                [self __playNextVideoInAdvance];
            }
        }
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.isDragging = YES;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self __onScrollDidEnd];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    self.isDragging = NO;
    if (!decelerate) {
        [self __onScrollDidEnd];
    }
}


#pragma mark - Private

- (void)close {
    [super close];
    [TTVideoEngine clearAllEngineStrategy];
    if (self.currentPlayCell) {
        [self.currentPlayCell stop];
    }
}

- (void)__handleSettingButtonClicked {
    VEUserGlobalConfigViewController *settingController = [[VEUserGlobalConfigViewController alloc] init];
    [self.navigationController pushViewController:settingController animated:YES];
}

- (void)__onScrollDidEnd {
    [self __play];
}

- (void)__play {
    NSIndexPath *indexPath = [self.tableView currentIndexPathForFullScreenCell];
    if (self.currentPlayIndexPath && self.currentPlayIndexPath.row == indexPath.row) {
        return;
    }
    [self __playWithIndexPath:indexPath];
}

- (void)__playWithIndexPath:(NSIndexPath *)indexPath {
    if (indexPath && indexPath.row < self.videoModels.count) {
        VESmallVideoFeedCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        if (self.currentPlayCell) {
            [self.currentPlayCell stop];
        }
        
        [cell play];
        self.currentPlayCell = cell;
        self.currentPlayIndexPath = indexPath;
    }
}

- (void)__playNextVideoInAdvance {
    if (!self.shouldPlayInAdvance) {
        return;
    }
    if (self.currentPlayIndexPath.row != [self.tableView currentIndexPathForFullScreenCell].row) {
        [self.currentPlayCell stop];
    }
    
    [self __play];
}


#pragma mark - Observer



#pragma mark - VECustomHeaderView Delegate

- (void)headerViewBackButtonDidClicked:(VECustomHeaderView *)headerView {
    [self close];
}

- (void)headerViewSettingButtonDidClicked:(VECustomHeaderView *)headerView {
    [self __handleSettingButtonClicked];
}


#pragma mark - lazy load

- (VECustomHeaderView *)headerView {
    if (!_headerView) {
        _headerView = [[VECustomHeaderView alloc] init];
        _headerView.delegate = self;
    }
    return _headerView;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))];
        _tableView.backgroundColor = [UIColor blackColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.pagingEnabled = YES;
        _tableView.estimatedRowHeight = 0;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        if (@available(iOS 11.0, *)) {
            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
    }
    return _tableView;
}

- (NSMutableArray<VEVideoModel *> *)videoModels {
    if (!_videoModels) {
        _videoModels = [NSMutableArray array];
    }
    return _videoModels;
}

#pragma mark - System

- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}


@end
