//
//  VELongVideoViewController.m
//  VOLCDemo
//
//  Created by RealZhao on 2021/12/23.
//

#import "VELongVideoViewController.h"
#import "VELongVideoViewLayout.h"
#import "VELongVideoViewTopCell.h"
#import "VELongVideoViewNormalCell.h"
#import "VEDataManager.h"
#import "VEVideoModel.h"
#import "VELongVideoDetailViewController.h"
#import <Masonry/Masonry.h>

static NSString *VELongVideoTopCellReuseID = @"VELongVideoTopCellReuseID";

static NSString *VELongVideoNormalCellReuseID = @"VELongVideoNormalCellReuseID";

static NSString *VELongVideoHeaderViewReuseID = @"VELongVideoHeaderViewReuseID";

static NSString *VELongVideoHeaderEmptyViewReuseID = @"VELongVideoHeaderEmptyViewReuseID";

static NSString *VELongSectionTopHeaderKey = @"置顶";

static NSString *VELongSectionHotHeaderKey = @"热播剧场";

static NSString *VELongSectionRecommendTodayHeaderKey = @"今日推荐";

static NSString *VELongSectionRecommendForUHeaderKey = @"为你推荐";

@interface VELongVideoViewController () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) NSMutableDictionary *videoModelDic;

@property (nonatomic, strong) UICollectionView *collectionView;

@end

@implementation VELongVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initialUI];
    [self loadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}


#pragma mark ----- Base

- (void)initialUI {
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.collectionView];
    NSBundle *currentBundle = [NSBundle bundleForClass:NSClassFromString(@"VELongVideoViewTopCell")];
    [self.collectionView registerNib:[UINib nibWithNibName:@"VELongVideoViewTopCell" bundle:currentBundle] forCellWithReuseIdentifier:VELongVideoTopCellReuseID];
    NSBundle *currentBundle2 = [NSBundle bundleForClass:NSClassFromString(@"VELongVideoViewNormalCell")];
    [self.collectionView registerNib:[UINib nibWithNibName:@"VELongVideoViewNormalCell" bundle:currentBundle2] forCellWithReuseIdentifier:VELongVideoNormalCellReuseID];
    [self.collectionView registerClass:[VELongVideoHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:VELongVideoHeaderViewReuseID];
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:VELongVideoHeaderEmptyViewReuseID];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    self.title = NSLocalizedString(@"title_long_video", nil);
    self.navigationItem.leftBarButtonItem = ({
        UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(close)];
        leftItem.tintColor = [UIColor blackColor];
        leftItem;
    });
}


#pragma mark ----- UICollectionView Delegate & DataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [[self sectionKeys] count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSArray *sectionKeys = [self sectionKeys];
    NSString *sectionKey = [sectionKeys objectAtIndex:section];
    NSArray *sectionItems = [self.videoModelDic objectForKey:sectionKey];
    return sectionItems.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *sectionKeys = [self sectionKeys];
    NSString *sectionKey = [sectionKeys objectAtIndex:indexPath.section];
    NSArray *sectionItems = [self.videoModelDic objectForKey:sectionKey];
    VEVideoModel *videoModel = [sectionItems objectAtIndex:indexPath.row];
    if (indexPath.section) {
        VELongVideoViewNormalCell *normalCell = [collectionView dequeueReusableCellWithReuseIdentifier:VELongVideoNormalCellReuseID forIndexPath:indexPath];
        normalCell.videoModel = videoModel;
        return normalCell;
    } else {
        VELongVideoViewTopCell *topCell = [collectionView dequeueReusableCellWithReuseIdentifier:VELongVideoTopCellReuseID forIndexPath:indexPath];
        topCell.videoModel = videoModel;
        return topCell;
    }
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if (kind == UICollectionElementKindSectionHeader
        && indexPath.section) {
        VELongVideoHeaderView *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:VELongVideoHeaderViewReuseID forIndexPath:indexPath];
        header.title = [[self sectionKeys] objectAtIndex:indexPath.section];
        return header;
    } else {
        return [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:VELongVideoHeaderEmptyViewReuseID forIndexPath:indexPath];
    }
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *sectionKeys = [self sectionKeys];
    NSString *sectionKey = [sectionKeys objectAtIndex:indexPath.section];
    NSArray *sectionItems = [self.videoModelDic objectForKey:sectionKey];
    VEVideoModel *videoModel = [sectionItems objectAtIndex:indexPath.row];
    VELongVideoDetailViewController *detailViewController = [VELongVideoDetailViewController new];
    detailViewController.videoModel = videoModel;
    [self.navigationController pushViewController:detailViewController animated:YES];
}


#pragma mark ----- lazy load

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:[VELongVideoViewLayout new]];
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsHorizontalScrollIndicator = NO;
    }
    return _collectionView;
}

- (NSMutableDictionary *)videoModelDic {
    if (!_videoModelDic) {
        _videoModelDic = [NSMutableDictionary dictionary];
    }
    return _videoModelDic;
}


#pragma mark ----- Data

- (void)loadData {
    [self.videoModelDic removeAllObjects];
    [VEDataManager dataForScene:VESceneTypeLongVideo range:NSMakeRange(0, 0) result:^(NSArray<VEVideoModel *> *videoModels) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self _fakeSection:videoModels];
            [self.collectionView reloadData];
        });
    }];
}

- (void)_fakeSection:(NSArray *)originalArray {
    [self.videoModelDic setValue:[originalArray subarrayWithRange:NSMakeRange(0, 1)] forKey:VELongSectionTopHeaderKey];
    NSArray *arr2 = [originalArray subarrayWithRange:NSMakeRange(1, 4)];
    [self.videoModelDic setValue:arr2 forKey:VELongSectionHotHeaderKey];
    [self.videoModelDic setValue:[originalArray subarrayWithRange:NSMakeRange(5, 4)] forKey:VELongSectionRecommendTodayHeaderKey];
    [self.videoModelDic setValue:[originalArray subarrayWithRange:NSMakeRange(9, (originalArray.count - 9))] forKey:VELongSectionRecommendForUHeaderKey];
}

- (NSArray *)sectionKeys {
    @autoreleasepool {
        return @[VELongSectionTopHeaderKey, VELongSectionHotHeaderKey, VELongSectionRecommendTodayHeaderKey, VELongSectionRecommendForUHeaderKey];
    }
}

@end
