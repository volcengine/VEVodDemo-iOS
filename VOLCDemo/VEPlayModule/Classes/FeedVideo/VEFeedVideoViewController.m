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
#import "VEFeedVideoDetailViewController.h"
#import <Masonry/Masonry.h>

static NSString *VEFeedVideoNormalCellReuseID = @"VEFeedVideoNormalCellReuseID";

@interface VEFeedVideoViewController () <UITableViewDelegate, UITableViewDataSource, VEFeedVideoNormalCellDelegate, VEFeedVideoDetailProtocol>

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

- (void)dealloc {
    [self.playerController stop];
    self.playerController = nil;
}

#pragma mark ----- Base

- (void)initialUI {
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.tableView];
    [self.tableView registerNib:[UINib nibWithNibName:@"VEFeedVideoNormalCell" bundle:nil] forCellReuseIdentifier:VEFeedVideoNormalCellReuseID];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    self.title = NSLocalizedString(@"title_middle_video", nil);
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
    if ([cell respondsToSelector:@selector(cellDidEndDisplay:)]) {
        [(VEFeedVideoNormalCell *)cell cellDidEndDisplay:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    VEVideoModel *videoModel = [self.videoModels objectAtIndex:indexPath.row];
    return [VEFeedVideoNormalCell cellHeight:videoModel];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    VEVideoModel *videoModel = [self.videoModels objectAtIndex:indexPath.row];
    BOOL shouldGoOn = [self willPlayCurrentSource:videoModel];
    [self stopVideos:!shouldGoOn];
    VEFeedVideoDetailViewController *detailViewController = [VEFeedVideoDetailViewController new];
    detailViewController.delegate = self;
    detailViewController.videoModel = videoModel;
    [self.navigationController pushViewController:detailViewController animated:YES];
}

- (id)feedVideoCellShouldPlay:(VEFeedVideoNormalCell *)cell {
    if ([self willPlayCurrentSource:cell.videoModel]) {
    } else {
        [self stopVideos:YES];
        self.playerController = [[VEVideoPlayerController alloc] init];
    }
    return self.playerController;
}

- (void)stopVideos:(BOOL)force {
    for (VEFeedVideoNormalCell *cell in self.tableView.visibleCells) {
        [cell cellDidEndDisplay:force];
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


#pragma mark ----- VEFeedVideoDetailProtocol

- (VEVideoPlayerController *)currentPlayerController:(VEVideoModel *)videoModel {
    if ([self willPlayCurrentSource:videoModel]) {
        VEVideoPlayerController *c = self.playerController;
        self.playerController = nil;
        return c;
    } else {
        return nil;
    }
}

- (BOOL)willPlayCurrentSource:(VEVideoModel *)videoModel {
    NSString *currentVid = @"";
    if (self.playerController && [self.playerController.mediaSource isKindOfClass:[TTVideoEngineVidSource class]]) {
        currentVid = [self.playerController.mediaSource performSelector:@selector(vid)];
    }
    if ([currentVid isEqualToString:videoModel.videoId]) {
        return YES;
    } else {
        return NO;
    }
}

@end
