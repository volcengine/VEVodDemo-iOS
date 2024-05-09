//
//  VEShortDramaListViewController.m
//  VOLCDemo
//

#import "VEShortDramaListViewController.h"
#import "VEShortDramaDetailFeedViewController.h"
#import "VEShortDramaVideoViewNormalCell.h"
#import "VEDramaDataManager.h"
#import "VEDramaInfoModel.h"
#import <Masonry/Masonry.h>
#import <MJRefresh/MJRefresh.h>

static NSInteger VEShortDramaVideoListPageCount = 20;
static NSString *VEShortDramaVideoNormalCellReuseID = @"VEShortDramaVideoNormalCellReuseID";

@interface VEShortDramaListViewController () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) NSMutableArray<VEDramaInfoModel *> *dramasArray;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, assign) NSInteger pageOffset;
@property (nonatomic, assign) BOOL isLoadingData;

@end

@implementation VEShortDramaListViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configuratoinCustomView];
    [self loadData:YES];
}

- (void)configuratoinCustomView {
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.collectionView];
    [self.collectionView registerClass:[VEShortDramaVideoViewNormalCell class] forCellWithReuseIdentifier:VEShortDramaVideoNormalCellReuseID];
    
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(44);
        } else {
            make.top.equalTo(self.view).offset(64);
        }
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
    __weak typeof(self) weakSelf = self;
    self.collectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf loadData:NO];
    }];
    
    self.collectionView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf loadData:YES];
    }];
}

- (void)loadData:(BOOL)isLoadMore {
    if (self.isLoadingData) {
        return;
    }
    self.isLoadingData = YES;
    
    if (!isLoadMore) {
        self.pageOffset = 0;
        self.collectionView.mj_footer.hidden = NO;
    }
    
    __weak typeof(self) weakSelf = self;
    [VEDramaDataManager requestDramaList:self.pageOffset pageSize:VEShortDramaVideoListPageCount result:^(id _Nullable responseData, NSString * _Nullable errorMsg) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        dispatch_async(dispatch_get_main_queue(), ^{
            NSArray *resArray = (NSArray *)responseData;
            if (resArray && resArray.count > 0) {
                if (isLoadMore) {
                    [strongSelf.dramasArray addObjectsFromArray:resArray];
                    [strongSelf.collectionView reloadData];
                    [strongSelf.collectionView.mj_footer endRefreshing];
                } else {
                    strongSelf.dramasArray = [resArray mutableCopy];
                    [strongSelf.collectionView.mj_header endRefreshing];
                    [strongSelf.collectionView reloadData];
                }
            } else {
                strongSelf.collectionView.mj_footer.hidden = YES;
            }
            strongSelf.isLoadingData = NO;
            strongSelf.pageOffset = strongSelf.dramasArray.count;
        });
    }];
}


#pragma mark ----- UICollectionView Delegate & DataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dramasArray.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    VEDramaInfoModel *dramaModel = [self.dramasArray objectAtIndex:indexPath.row];
    VEShortDramaVideoViewNormalCell *normalCell = [collectionView dequeueReusableCellWithReuseIdentifier:VEShortDramaVideoNormalCellReuseID forIndexPath:indexPath];
    normalCell.dramaInfoModel = dramaModel;
    return normalCell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    VEDramaInfoModel *dramaInfoModel = [self.dramasArray objectAtIndex:indexPath.row];
    VEShortDramaDetailFeedViewController *dramaDetailFeedViewController = [[VEShortDramaDetailFeedViewController alloc] initWtihDramaInfo:dramaInfoModel];
    [self.navigationController pushViewController:dramaDetailFeedViewController animated:YES];
}


#pragma mark ----- lazy load

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *collectionViewlayout = [UICollectionViewFlowLayout new];
        
        CGFloat width = ([UIScreen mainScreen].bounds.size.width - 50) / 3.0;
        CGFloat height = width * 208 / 109.0f;
        
        collectionViewlayout.itemSize = CGSizeMake(width, height);
        collectionViewlayout.sectionInset = UIEdgeInsetsMake(0, 16, 0, 16);
        collectionViewlayout.minimumLineSpacing = 16.0;
        collectionViewlayout.minimumInteritemSpacing = 8.0;
        collectionViewlayout.headerReferenceSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, 10);
        collectionViewlayout.footerReferenceSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, 10);
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:collectionViewlayout];
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsHorizontalScrollIndicator = NO;
    }
    return _collectionView;
}

- (NSMutableArray<VEDramaInfoModel *> *)dramasArray {
    if (!_dramasArray) {
        _dramasArray = [NSMutableArray array];
    }
    return _dramasArray;
}

@end
