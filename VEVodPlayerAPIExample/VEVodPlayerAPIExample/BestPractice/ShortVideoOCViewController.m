// Copyright (c) 2025 Beijing Volcano Engine Technology Co., Ltd.
// SPDX-License-Identifier: MIT
//
//  ShortVideoOCViewController.m
//  VEVodPlayerAPIExample
//
//  Created by ByteDance on 2025/6/19.
//

#import "ShortVideoOCViewController.h"
#import "ShortVideoOCTableViewCell.h"
#import "VEAPIVideoModel.h"
#import "VEAPIMediaSource.h"
#import <Masonry/Masonry.h>

@interface ShortVideoOCViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray<VEAPIVideoModel *> *sources;
@property (nonatomic, strong) NSIndexPath *currentPlayIndexPath;
@property (nonatomic, strong) ShortVideoOCTableViewCell *currentPlayCell;

@end

@implementation ShortVideoOCViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"VEVodPlayerAPIExample - ShortVideoOCViewController");
    self.sources = [VEAPIVideoModel defaultVideoModel];
    [self constructViews];
    [self startStrategy];
    [self.tableView reloadData];
    NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self __playWithIndexPath:firstIndexPath];
}

- (void)viewDidDisappear:(BOOL)animated {
    if (self.currentPlayCell) {
        [self.currentPlayCell closeAysnc];
    }
    // 清除策略
    [TTVideoEngine clearAllEngineStrategy];
    [super viewWillDisappear:animated];
}

- (void)constructViews {
    UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];
    [appearance configureWithOpaqueBackground];
    appearance.backgroundColor = [UIColor clearColor];
    appearance.shadowColor = [UIColor clearColor];
    self.navigationController.navigationBar.standardAppearance = appearance;
    self.navigationController.navigationBar.scrollEdgeAppearance = appearance;
    
    self.view.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

- (void)startStrategy {
    // 开启预加载策略，建议在进入短视频页面开启
    [TTVideoEngine enableEngineStrategy:TTVideoEngineStrategyTypePreload scene:TTVEngineStrategySceneSmallVideo];
    // 开启预渲染策略，建议在进入短视频页面开启
    [TTVideoEngine enableEngineStrategy:TTVideoEngineStrategyTypePreRender scene:TTVEngineStrategySceneSmallVideo];
    NSArray<id<TTVideoEngineMediaSource>> *mediaSources = [VEAPIMediaSource covertVideoModelsToTTVideoEngineSources:self.sources];
    [TTVideoEngine setStrategyVideoSources:mediaSources];
}

- (void)__play {
    NSIndexPath *indexPath = [self currentIndexPathForFullScreenCell:self.tableView];
    [self __playWithIndexPath:indexPath];
}

- (void)__playWithIndexPath:(NSIndexPath *)indexPath {
    if (self.currentPlayIndexPath && self.currentPlayIndexPath.row == indexPath.row) {
        return;
    }
    if (indexPath && indexPath.row < [self.sources count]) {
        ShortVideoOCTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        if (self.currentPlayCell) {
            [self.currentPlayCell closeAysnc];
        }
        [cell play];
        self.currentPlayCell = cell;
        self.currentPlayIndexPath = indexPath;
    }
}

- (NSIndexPath *)currentIndexPathForFullScreenCell:(UITableView *)tableView {
    CGRect visibleRect = CGRectZero;
    visibleRect.origin = tableView.contentOffset;
    visibleRect.size = tableView.frame.size;

    CGPoint visiblePoint = CGPointMake(CGRectGetMidX(visibleRect),
                                       CGRectGetMidY(visibleRect));

    return [tableView indexPathForRowAtPoint:visiblePoint];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.sources.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return CGRectGetHeight(self.view.frame);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ShortVideoOCTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"VEVodPlayerAPIExampleShortVideo" forIndexPath:indexPath];
    if (!cell) {
        cell = [[ShortVideoOCTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"VEVodPlayerAPIExampleShortVideo"];
    }
    cell.row = indexPath.row;
    [cell configureSource:self.sources[indexPath.row].videoUrl cover:self.sources[indexPath.row].coverUrl];
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    cell.userInteractionEnabled = YES;
    cell.backgroundColor = [UIColor blackColor];
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [(ShortVideoOCTableViewCell *)cell configureSource:self.sources[indexPath.row].videoUrl cover:self.sources[indexPath.row].coverUrl];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self __play];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        [self __play];
    }
}

- (UITableView *)tableView {
    if (_tableView == NULL) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))];
        [_tableView registerClass:[ShortVideoOCTableViewCell class] forCellReuseIdentifier:@"VEVodPlayerAPIExampleShortVideo"];
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

@end
