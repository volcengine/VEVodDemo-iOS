//
//  VOLCSmallVideoViewController.m
//  VOLCDemo
//
//  Created by wangzhiyong on 2021/5/24.
//  Copyright © 2021 ByteDance. All rights reserved.
//

#import "VOLCSmallVideoViewController.h"
#import "VOLCUserGlobalConfigViewController.h"
#import "UITableView+VOLC.h"
#import "VOLCCustomHeaderView.h"
#import "VOLCSmallVideoViewModel.h"
#import "VOLCVideoModel.h"
#import "VOLCSmallVideoFeedCell.h"
#import "VOLCPreloadHelper.h"

NSString * const kSmallVideoFeedCellIdentifier = @"kSmallVideoFeedCellIdentifier";
NSInteger kSmallVideoPreloadMaxCount = 5;

@interface VOLCSmallVideoViewController () <VOLCCustomHeaderViewDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) VOLCSmallVideoViewModel *viewModel;
@property (nonatomic, assign) VOLCSmallVideoPlayState playState;
@property (nonatomic, strong) VOLCCustomHeaderView *headerView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSIndexPath *currentPlayIndexPath;
@property (nonatomic, strong) NSIndexPath *willPlayIndexPath;
@property (nonatomic, strong) VOLCSmallVideoFeedCell *currentPlayCell;

@property (nonatomic, assign) BOOL shouldPlayInAdvance;
@property (nonatomic, assign) BOOL isDragging;
@property (nonatomic, assign) CGFloat lastContentOffsetY;
@property (nonatomic, assign) NSTimeInterval lastCheckPlayTimeInAdvance;

@end

@implementation VOLCSmallVideoViewController

- (void)dealloc {
    [self removeObserver];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.shouldPlayInAdvance = YES; // default open play advance
    
    [self configuratoinCustomView];
    [self loadVideoData];
    [self addObserver];
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
}


#pragma mark - UI

- (void)configuratoinCustomView {
    [self.navigationController setNavigationBarHidden:YES];
    self.view.backgroundColor = [UIColor blackColor];
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    [self.tableView registerClass:[VOLCSmallVideoFeedCell class] forCellReuseIdentifier:kSmallVideoFeedCellIdentifier];
    
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


#pragma mark - Load Data

- (void)loadVideoData {
    [self.viewModel requestVideoModels:^(id  _Nonnull responseObject) {
        [self.tableView reloadData];
        [self __play];
    } failure:^(NSString * _Nonnull errorMessage) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.label.text = errorMessage;
        [hud hideAnimated:YES afterDelay:2.0];
    }];
}


#pragma mark - UITableView delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.viewModel numberOfRowsInSection:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return CGRectGetHeight(self.view.frame);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    VOLCSmallVideoFeedCell *cell = [tableView dequeueReusableCellWithIdentifier:kSmallVideoFeedCellIdentifier];
    if (!cell) {
        cell = [[VOLCSmallVideoFeedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kSmallVideoFeedCellIdentifier];
    }
    if (cell) {
        [cell configWithVideoModel:[self.viewModel cellVideoModelForRowAtIndexPath:indexPath]];
        cell.indexPath = indexPath.row;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    self.willPlayIndexPath = indexPath;
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

- (void)__close {
    if (self.currentPlayCell) {
        [self.currentPlayCell stop];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)__handleSettingButtonClicked {
    VOLCUserGlobalConfigViewController *settingController = [[VOLCUserGlobalConfigViewController alloc] init];
    [self.navigationController pushViewController:settingController animated:YES];
}

- (void)__onScrollDidEnd {
    [self __play];
}

- (void)__play {
    self.playState = VOLCSmallVideoPlayStatePlay;
    NSIndexPath *indexPath = [self.tableView currentIndexPathForFullScreenCell];
    [self __playWithIndexPath:indexPath];
}

- (void)__playWithIndexPath:(NSIndexPath *)indexPath {
    if (self.currentPlayIndexPath && self.currentPlayIndexPath.row == indexPath.row) {
        return;
    }
    if (indexPath && indexPath.row < [self.viewModel numberOfRowsInSection:indexPath.section]) {
        VOLCSmallVideoFeedCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
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

- (void)addObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(preloadNextVideoIfNeed) name:kVOLCCanPreLoadNextVideoIfNeedNotification object:nil];
}

- (void)removeObserver {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kVOLCCanPreLoadNextVideoIfNeedNotification object:nil];
}

/// Simple preload strategy, preload next (kSmallVideoPreloadMaxCount) video
/// You can optimize the preload quantity and preload size in more detail
/// For example, you can dynamically adjust the preload strategy base on the network status
- (void)preloadNextVideoIfNeed {
    NSInteger curIndex = self.currentPlayIndexPath.row;
    NSInteger location = curIndex + 1;
    NSInteger length = [self.viewModel numberOfRowsInSection:0] - location > kSmallVideoPreloadMaxCount ? kSmallVideoPreloadMaxCount : [self.viewModel numberOfRowsInSection:0] - location;
    if (location < ([self.viewModel numberOfRowsInSection:0] - 1) ) {
        NSArray *preloadVideos = [self.viewModel.videoModels subarrayWithRange:NSMakeRange(location, length)];
        [[VOLCPreloadHelper shareInstance] addPreloadTaskWithVideoModels:preloadVideos];
    }
}


#pragma mark - VOLCCustomHeaderView Delegate

- (void)headerViewBackButtonDidClicked:(VOLCCustomHeaderView *)headerView {
    [self __close];
}

- (void)headerViewSettingButtonDidClicked:(VOLCCustomHeaderView *)headerView {
    [self __handleSettingButtonClicked];
}


#pragma mark - lazy load

- (VOLCSmallVideoViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[VOLCSmallVideoViewModel alloc] init];
    }
    return _viewModel;
}

- (VOLCCustomHeaderView *)headerView {
    if (!_headerView) {
        _headerView = [[VOLCCustomHeaderView alloc] init];
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

#pragma mark - System

- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}


@end
