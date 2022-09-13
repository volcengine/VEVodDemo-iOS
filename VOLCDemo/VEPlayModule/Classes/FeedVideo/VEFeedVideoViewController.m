//
//  VEFeedVideoViewController.m
//  VOLCDemo
//
//  Created by real on 2022/8/21.
//  Copyright © 2022 ByteDance. All rights reserved.
//

#import "VEFeedVideoViewController.h"
#import "VEFeedVideoNormalCell.h"
#import "VEVideoModel.h"
#import "VEDataManager.h"
#import "VEVideoPlayerController.h"
#import <Masonry/Masonry.h>

static NSString *VEFeedVideoNormalCellReuseID = @"VEFeedVideoNormalCellReuseID";

@interface VEFeedVideoViewController () <UITableViewDelegate, UITableViewDataSource, VEFeedVideoNormalCellDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *videoModels;

@property (nonatomic, strong) VEVideoPlayerController *playerController;

@end

@implementation VEFeedVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initialUI];
    [self loadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self stopVideos];
}

#pragma mark ----- Base

- (void)initialUI {
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.tableView];
    [self.tableView registerNib:[UINib nibWithNibName:@"VEFeedVideoNormalCell" bundle:nil] forCellReuseIdentifier:VEFeedVideoNormalCellReuseID];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    self.title = NSLocalizedString(@"title_feed_video", nil);
    self.navigationItem.leftBarButtonItem = ({
        UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(close)];
        leftItem.tintColor = [UIColor blackColor];
        leftItem;
    });
}


#pragma mark ----- UITableView Delegate & DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.videoModels.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    VEVideoModel *videoModel = [self.videoModels objectAtIndex:indexPath.row];
    VEFeedVideoNormalCell *normalCell = [tableView dequeueReusableCellWithIdentifier:VEFeedVideoNormalCellReuseID];
    normalCell.delegate = self;
    normalCell.videoModel = videoModel;
    return normalCell;
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell respondsToSelector:@selector(cellDidEndDisplay)]) {
        [cell performSelector:@selector(cellDidEndDisplay)];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    VEVideoModel *videoModel = [self.videoModels objectAtIndex:indexPath.row];
    return [VEFeedVideoNormalCell cellHeight:videoModel];
}

- (id)feedVideoCellShouldPlay:(VEFeedVideoNormalCell *)cell {
    [self stopVideos];
    self.playerController = [[VEVideoPlayerController alloc] init];
    return self.playerController;
}

- (void)stopVideos {
    if (self.playerController) {
        for (VEFeedVideoNormalCell *cell in self.tableView.visibleCells) {
            [cell cellDidEndDisplay];
        }
    }
}


#pragma mark ----- lazy load

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.directionalLockEnabled = YES;
        _tableView.estimatedRowHeight = 0.0;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _tableView;
}

- (NSMutableArray *)videoModels {
    if (!_videoModels) {
        _videoModels = [NSMutableArray array];
    }
    return _videoModels;
}


#pragma mark ----- Data

- (void)loadData {
    [self.videoModels removeAllObjects];
    [VEDataManager dataForScene:VESceneTypeFeedVideo range:NSMakeRange(0, 0) result:^(NSArray<VEVideoModel *> *videoModels) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.videoModels addObjectsFromArray:videoModels];
            [self.tableView reloadData];
        });
    }];
}

@end
