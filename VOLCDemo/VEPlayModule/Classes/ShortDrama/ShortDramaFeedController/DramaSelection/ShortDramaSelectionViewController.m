//
//  ShortDramaSelectionViewController.m
//  VEPlayModule
//

#import "ShortDramaSelectionViewController.h"
#import "ShortDramaSelectionCell.h"
#import "VEDramaDataManager.h"
#import "VEDramaVideoInfoModel.h"
#import <Masonry/Masonry.h>
#import "UIColor+RGB.h"

static NSInteger VEShortDramaSelectionPageCount = 50;
static NSString *VEShortDramaSelectionCellReuseID = @"VEShortDramaSelectionCellReuseID";

@interface ShortDramaSelectionViewController () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) NSArray<VEDramaVideoInfoModel *> *dramaVideoModels;
@property (nonatomic, strong) VEDramaVideoInfoModel *curPlayDramaVideoInfo;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, assign) NSInteger pageOffset;

@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *desLabel;
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) UIButton *backButton;

@end

@implementation ShortDramaSelectionViewController

- (instancetype)initWtihDramaVideoInfo:(VEDramaVideoInfoModel *)dramaVideoInfo {
    self = [super init];
    if (self) {
        self.curPlayDramaVideoInfo = dramaVideoInfo;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configuratoinCustomView];
    [self loadData];
}

- (void)configuratoinCustomView {
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.collectionView];
    [self.view addSubview:self.headerView];
    [self.view addSubview:self.backButton];
    self.titleLabel.text = self.curPlayDramaVideoInfo.dramaEpisodeInfo.dramaInfo.dramaTitle;
    self.desLabel.text = [NSString stringWithFormat:@"全%@集丨29.3w", @(self.curPlayDramaVideoInfo.dramaEpisodeInfo.dramaInfo.totalEpisodeNumber)];

    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.height.mas_equalTo(85);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.headerView);
        make.left.equalTo(self.headerView).with.offset(16);
        make.right.equalTo(self.headerView).with.offset(80);
        make.height.mas_equalTo(52);
    }];
    
    [self.desLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.headerView).with.offset(50);
        make.left.equalTo(self.headerView).with.offset(16);
    }];
    
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(_headerView);
        make.left.equalTo(_headerView).with.offset(16);
        make.right.equalTo(_headerView).with.offset(-16);
        make.height.mas_equalTo(1);
    }];
    
    [self.collectionView registerClass:[ShortDramaSelectionCell class] forCellWithReuseIdentifier:VEShortDramaSelectionCellReuseID];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.headerView.mas_bottom);
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
    
    [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(52, 52));
    }];
}

- (void)loadData {
    NSString *dramaId = self.curPlayDramaVideoInfo.dramaEpisodeInfo.dramaInfo.dramaId;
    __weak typeof(self) weak_self = self;
    [VEDramaDataManager requestDramaEpisodeList:dramaId offset:self.pageOffset pageSize:VEShortDramaSelectionPageCount result:^(id  _Nullable responseData, NSString * _Nullable errorMsg) {
        typeof(weak_self) strong_self = weak_self;
        if (!errorMsg) {
            NSArray *resArray = (NSArray *)responseData;
            strong_self.dramaVideoModels = resArray;
            strong_self.pageOffset = strong_self.dramaVideoModels.count;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [strong_self.collectionView reloadData];
            });
        } else {
            
        }
    }];
    
    
}

#pragma mark - Event

- (void)backButtonHandle {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark ----- UICollectionView Delegate & DataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dramaVideoModels.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    VEDramaVideoInfoModel *dramaVideoModel = [self.dramaVideoModels objectAtIndex:indexPath.row];
    ShortDramaSelectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:VEShortDramaSelectionCellReuseID forIndexPath:indexPath];
    cell.dramaVideoInfo = dramaVideoModel;
    cell.curPlayDramaVideoInfo = self.curPlayDramaVideoInfo;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    VEDramaVideoInfoModel *dramaVideoInfo = [self.dramaVideoModels objectAtIndex:indexPath.row];
    if (self.delegate && [self.delegate respondsToSelector:@selector(onDramaSelectionCallback:)]) {
        self.curPlayDramaVideoInfo = dramaVideoInfo;
        [self.delegate onDramaSelectionCallback:dramaVideoInfo];
        [self backButtonHandle];
    }
}

#pragma mark ----- lazy load

- (UIView *)headerView {
    if (_headerView == nil) {
        _headerView = [[UIView alloc] init];
        _headerView.backgroundColor = [UIColor clearColor];
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = [UIColor colorWithRGB:0x161823 alpha:1.0];
        _titleLabel.font = [UIFont systemFontOfSize:17];
        
        _desLabel = [[UILabel alloc] init];
        _desLabel.textColor = [UIColor colorWithRGB:0x161823 alpha:1.0];
        _desLabel.font = [UIFont systemFontOfSize:12];
        
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = [UIColor colorWithRGB:0xF1F1F2 alpha:1];
        
        [_headerView addSubview:_titleLabel];
        [_headerView addSubview:_desLabel];
        [_headerView addSubview:_lineView];
    }
    return _headerView;
}

- (UIButton *)backButton {
    if (_backButton == nil) {
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backButton setImage:[UIImage imageNamed:@"icon_close"] forState:UIControlStateNormal];
        [_backButton addTarget:self action:@selector(backButtonHandle) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backButton;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *collectionViewlayout = [UICollectionViewFlowLayout new];
        
        CGFloat width = ([UIScreen mainScreen].bounds.size.width - 16 * 2 - 5 * 10) / 6.0;
        CGFloat height = width;
        
        collectionViewlayout.itemSize = CGSizeMake(width, height);
        collectionViewlayout.sectionInset = UIEdgeInsetsMake(0, 16, 0, 16);
        collectionViewlayout.minimumLineSpacing = 12.0;
        collectionViewlayout.minimumInteritemSpacing = 10.0;
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

@end
