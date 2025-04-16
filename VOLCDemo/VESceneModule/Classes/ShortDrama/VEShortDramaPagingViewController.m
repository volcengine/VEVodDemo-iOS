//
//  MXMyProgramViewController.m
//  VOLCDemo
//

#import "VEShortDramaPagingViewController.h"
#import "VESelectionBarView.h"
#import "VEShortDramaListViewController.h"
#import "VEShortVideoViewController.h"
#import "VEShortDramaVideoFeedViewController.h"
#import "VELongVideoViewController.h"
#import "VEVideoPlayerController+Strategy.h"
#import <Masonry/Masonry.h>
#import "UIColor+RGB.h"
#import "VEVideoPlayerPipController.h"

#define kHeaderBarHeight (MXCustomNavigationHeaderHeight+MXSafeTopMarginWithStatusBar)

@interface VEShortDramaPagingViewController ()

@property (nonatomic, strong) UIView *selectionView;
@property (nonatomic, strong) VESelectionBarView *selectionBar;
@property (nonatomic, strong) VESelectionBarView *recommendSelectionBar;
@property (nonatomic, assign) VEShortDramaType defaultType;
@property (nonatomic, assign) BOOL scrollToDefaultPage;
@property (nonatomic, strong) UIButton *backButton;

@end

@implementation VEShortDramaPagingViewController

#pragma mark - Life Cycle

- (instancetype)initWithDefaultType:(VEShortDramaType)type {
    self = [super init];
    if (self) {
        self.defaultType = type;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureCustomViews];
    [self setupWithNumberOfPages:VEShortDramaTypeCount];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (void)viewWillLayoutSubviews
{
    if (!self.scrollToDefaultPage) {
        [self scrollToPage:self.defaultType animated:NO];
        self.scrollToDefaultPage = YES;
    }
    [super viewWillLayoutSubviews];
}

#pragma mark - VESelectionViewController

- (UIViewController *)generateViewControllerOfPage:(NSInteger)page {
    UIViewController *viewController = nil;
    if (page == VEShortDramaTypeDrama) {
        viewController = [[VEShortDramaListViewController alloc] init];
    } else if (page == VEShortDramaTypeRecommend) {
        viewController = [VEShortDramaVideoFeedViewController new];
    }
    return viewController;
}

- (void)willScrollToPage:(NSInteger)page animated:(BOOL)animated {
    self.selectionBar.hidden = (page == VEShortDramaTypeRecommend);
    self.recommendSelectionBar.hidden = (page == VEShortDramaTypeDrama);
    [self.backButton setImage:[UIImage imageNamed:(page == VEShortDramaTypeDrama) ? @"back" : @"video_page_back"] forState:UIControlStateNormal];
}

- (void)didScrollToPage:(NSInteger)page animated:(BOOL)animated {
    self.selectionBar.selectedIndex = page;
    self.recommendSelectionBar.selectedIndex = page;
}

- (UIEdgeInsets)scrollViewInsets {
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

#pragma mark - Private

- (void)configureCustomViews {
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = [UIColor whiteColor];
    self.scrollView.bounces = NO;
    
    [self.view addSubview:self.selectionView];
    [self.selectionView addSubview:self.selectionBar];
    [self.selectionView addSubview:self.recommendSelectionBar];

    [self.selectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        } else {
            make.top.equalTo(self.view).offset(24);
        }
        make.left.and.right.equalTo(self.view);
        make.height.mas_equalTo(44);
    }];
    [self.selectionBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.left.and.right.equalTo(self.selectionView);
    }];
    [self.recommendSelectionBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.left.and.right.equalTo(self.selectionView);
    }];
    
    [self.selectionView addSubview:self.backButton];
    [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.selectionView).with.offset(5);
        make.centerY.equalTo(self.selectionView);
        make.size.mas_equalTo(CGSizeMake(40, 40));
    }];
    
    self.selectionView.backgroundColor = [UIColor clearColor];
    self.selectionBar.backgroundColor = [UIColor clearColor];
    self.recommendSelectionBar.backgroundColor = [UIColor clearColor];
    self.recommendSelectionBar.hidden = YES;
    NSString *allDramaTitle = NSLocalizedStringFromTable(@"title_short_drama_list", @"VodLocalizable", nil);
    NSString *hotDramaTitle = NSLocalizedStringFromTable(@"title_short_drama_hot", @"VodLocalizable", nil);
    [self.selectionBar updateWithTitles:@[ allDramaTitle, hotDramaTitle ]];
    [self.recommendSelectionBar updateWithTitles:@[ allDramaTitle, hotDramaTitle ]];
    
    UIGestureRecognizer *interactivePopGestureRecognizer = self.navigationController.interactivePopGestureRecognizer;
    [self.scrollView.panGestureRecognizer requireGestureRecognizerToFail:interactivePopGestureRecognizer];
}

#pragma mark - Event Response

- (void)onBackButtonHandle:(UIButton *)button {
    UIViewController *presentingViewController = self.presentingViewController;
    if (presentingViewController) {
        [presentingViewController dismissViewControllerAnimated:NO completion:nil];
    } else if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    [VEVideoPlayerController clearAllEngineStrategy];
    [[VEVideoPlayerPipController shared] stopPip];
}

#pragma mark - Getters & Setters.

- (UIButton *)backButton {
    if (_backButton == nil) {
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
        [_backButton addTarget:self action:@selector(onBackButtonHandle:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backButton;
}

- (UIView *)selectionView {
    if (_selectionView == nil) {
        _selectionView = [UIView new];
        _selectionView.backgroundColor = [UIColor whiteColor];
    }
    return _selectionView;
}

- (VESelectionBarView *)selectionBar {
    if (_selectionBar == nil) {
        NSDictionary *titleAttributes = @{ NSForegroundColorAttributeName : [UIColor colorWithRGB:0x161823 alpha:1.0],
                                                      NSFontAttributeName : [UIFont systemFontOfSize:18] };
        NSDictionary *selectedTitleAttributes = @{ NSForegroundColorAttributeName : [UIColor colorWithRGB:0x161823 alpha:1.0],
                                                               NSFontAttributeName: [UIFont systemFontOfSize:18] };
        _selectionBar = [[VESelectionBarView alloc] initWithStyle:VESelectionBarViewStyleSelectedLine
                                                           titleAttributes:titleAttributes
                                                   selectedTitleAttributes:selectedTitleAttributes];
        _selectionBar.selectedLineWidth = 22.0f;
        _selectionBar.selectedLineHeight = 2.0f;
        CGFloat left = (CGRectGetWidth([UIScreen mainScreen].bounds) - 200) / 2;
        _selectionBar.contentInset = UIEdgeInsetsMake(0, left, 0, left);
        __weak typeof(self) weakSelf = self;
        _selectionBar.selectionCallback = ^(VESelectionBarView * _Nonnull selectionBar, NSUInteger index) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf scrollToPage:index animated:NO];
        };
    }
    return _selectionBar;
}

- (VESelectionBarView *)recommendSelectionBar {
    if (_recommendSelectionBar == nil) {
        NSDictionary *titleAttributes = @{ NSForegroundColorAttributeName : [UIColor colorWithRGB:0xffffff alpha:.6],
                                                      NSFontAttributeName : [UIFont systemFontOfSize:18] };
        NSDictionary *selectedTitleAttributes = @{ NSForegroundColorAttributeName : [UIColor colorWithRGB:0xffffff alpha:1.0],
                                                               NSFontAttributeName: [UIFont systemFontOfSize:18] };
        _recommendSelectionBar = [[VESelectionBarView alloc] initWithStyle:VESelectionBarViewStyleSelectedLine
                                                           titleAttributes:titleAttributes
                                                   selectedTitleAttributes:selectedTitleAttributes];
        _recommendSelectionBar.selectedLineWidth = 22.0f;
        _recommendSelectionBar.selectedLineHeight = 2.0f;
        CGFloat left = (CGRectGetWidth([UIScreen mainScreen].bounds) - 200) / 2;
        _recommendSelectionBar.contentInset = UIEdgeInsetsMake(0, left, 0, left);
        __weak typeof(self) weakSelf = self;
        _recommendSelectionBar.selectionCallback = ^(VESelectionBarView * _Nonnull selectionBar, NSUInteger index) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf scrollToPage:index animated:NO];
        };
    }
    return _recommendSelectionBar;
}


@end
