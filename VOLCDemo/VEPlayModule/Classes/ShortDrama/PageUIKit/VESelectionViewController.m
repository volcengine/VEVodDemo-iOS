//
//  VESelectionViewController.m
//  VOLCDemo
//

#import "VESelectionViewController.h"

static const NSInteger MXPreloadViewControllers = 1;
static void *KVOContext_VESelectionViewController = &KVOContext_VESelectionViewController;

@interface VESelectionViewController ()

@property (nonatomic, strong) NSMutableArray *viewControllers;

@end

@implementation VESelectionViewController {
    NSInteger _currentPage, _numberOfPages;
}

#pragma mark - Life Cycle

- (void)dealloc {
    [self.scrollView removeObserver:self
                         forKeyPath:NSStringFromSelector(@selector(contentInset))
                            context:KVOContext_VESelectionViewController];
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        if ([self respondsToSelector:@selector(setAutomaticallyAdjustsScrollViewInsets:)]) {
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.scrollView.pagingEnabled = YES;
    self.scrollView.scrollsToTop = NO;
    self.scrollView.bounces = YES;
    self.scrollView.bouncesZoom = NO;
    self.scrollView.directionalLockEnabled = YES;
    self.scrollView.alwaysBounceHorizontal = YES;
    self.scrollView.alwaysBounceVertical = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    
    [self.scrollView addObserver:self forKeyPath:NSStringFromSelector(@selector(contentInset)) options:0 context:KVOContext_VESelectionViewController];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.scrollView.contentInset = [self scrollViewInsets];
    self.scrollView.scrollIndicatorInsets = self.scrollView.contentInset;
    
    [self updateScrollViewContentSize];
    
    [self scrollToPage:self.currentPage animated:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    for (NSInteger i = 0; i < [self.viewControllers count]; i++) {
        if (i < self.currentPage - MXPreloadViewControllers || i > self.currentPage + MXPreloadViewControllers) {
            [self unloadChildViewControllerOfPage:i];
        }
    }
}

#pragma mark -

- (void)setupWithNumberOfPages:(NSInteger)numberOfPages {
    _numberOfPages = numberOfPages;
    
    for (UIViewController *viewController in self.viewControllers) {
        [self _removeFromParentViewController:viewController];
    }
    
    self.viewControllers = [NSMutableArray array];
    for (NSInteger index = 0; index < self.numberOfPages; index++) {
        [self.viewControllers addObject:[NSNull null]];
    }
    [self scrollToPage:self.currentPage animated:NO];
}

- (UIViewController *)viewControllerOfPage:(NSInteger)page {
    UIViewController *retViewController = [self.viewControllers objectAtIndex:page];
    if ([retViewController isKindOfClass:[UIViewController class]]) {
        return retViewController;
    }
    return nil;
}

- (UIViewController *)generateViewControllerOfPage:(NSInteger)page {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (UIEdgeInsets)viewInsetsOfPage:(NSInteger)page {
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (UIEdgeInsets)scrollViewInsets {
    return UIEdgeInsetsMake(self.topLayoutGuide.length, 0, self.bottomLayoutGuide.length, 0);
}

- (void)scrollToPage:(NSInteger)page animated:(BOOL)animated {
    NSInteger lastPage = self.currentPage;
    [self setCurrentPage:page animated:animated];
    if (self.currentPage != lastPage) {
        [self removeChildViewControllerOfPage:lastPage];
    }
    
    CGRect visibleBounds = UIEdgeInsetsInsetRect(self.scrollView.bounds, self.scrollView.contentInset);
    visibleBounds.origin.x = CGRectGetWidth(visibleBounds) * page;
    visibleBounds.origin.y = 0;
    [self.scrollView scrollRectToVisible:visibleBounds animated:NO];
}

- (void)willScrollToPage:(NSInteger)page animated:(BOOL)animated {
    
}

- (void)didScrollToPage:(NSInteger)page animated:(BOOL)animated {
    
}

#pragma mark - Private

- (void)setCurrentPage:(NSInteger)page {
    [self setCurrentPage:page animated:NO];
}

- (void)setCurrentPage:(NSInteger)page animated:(BOOL)animated {
    if ((page == self.currentPage && [self viewControllerOfPage:page]) || page >= self.numberOfPages) {
        return;
    }
    
    [self loadChildViewControllerOfPage:page];
    [self willScrollToPage:page animated:animated];
    _currentPage = page;
    [self addChildViewControllerOfPage:page];
    [self didScrollToPage:page animated:animated];
    
    [self setNeedsStatusBarAppearanceUpdate];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        for (NSInteger i = 1; i <= MXPreloadViewControllers; i++) {
            [self loadChildViewControllerOfPage:page + i];
            [self loadChildViewControllerOfPage:page - i];
        }
    });
}

- (void)loadChildViewControllerOfPage:(NSInteger)page {
    if (page < 0 || page >= self.numberOfPages) {
        return;
    }
    
    UIViewController *viewController = [self viewControllerOfPage:page];
    if (!viewController) {
        viewController = [self generateViewControllerOfPage:page];
        if ([viewController respondsToSelector:@selector(setAutomaticallyAdjustsScrollViewInsets:)]) {
            viewController.automaticallyAdjustsScrollViewInsets = NO;
        }
        if (!viewController) {
            return;
        }
        if (!viewController.isViewLoaded) {
            [viewController view];
        }
        [self _replaceViewControllers:self.viewControllers atIndex:page withObject:viewController];
    }
}

- (void)addChildViewControllerOfPage:(NSInteger)page {
    UIViewController *viewController = [self viewControllerOfPage:page];
    if (viewController && viewController.view.superview != self.scrollView) {
        [self _addChildController:viewController container:self.scrollView];
        [self updateChildViewControllerOfPage:page];
    }
}

- (void)updateChildViewControllerOfPage:(NSInteger)page {
    UIViewController *viewController = [self viewControllerOfPage:page];
    if (![viewController isKindOfClass:[UIViewController class]] || viewController.view.superview != self.scrollView) {
        return;
    }
    
    UIEdgeInsets viewInset = [self viewInsetsOfPage:page];
    CGFloat left = CGRectGetWidth(self.scrollView.bounds) * page + viewInset.left;
    CGFloat top = viewInset.top;
    CGFloat width = CGRectGetWidth(self.scrollView.bounds) - viewInset.left - viewInset.right;
    CGFloat height = self.scrollView.contentSize.height - viewInset.top - viewInset.bottom;
    viewController.view.frame = CGRectMake(left, top, width, height);
}

- (void)removeChildViewControllerOfPage:(NSInteger)page {
    UIViewController *viewController = [self viewControllerOfPage:page];
    [self _removeFromParentViewController:viewController];
}

- (void)unloadChildViewControllerOfPage:(NSInteger)page {
    UIViewController *viewController = [self viewControllerOfPage:page];
    if (viewController) {
        [self _removeFromParentViewController:viewController];
        [self _replaceViewControllers:self.viewControllers atIndex:page withObject:[NSNull null]];
    }
}

#pragma mark - Private

- (void)_addChildController:(UIViewController *)childController container:(UIView *)containerView {
    if (!childController || ![childController isKindOfClass:[UIViewController class]]) {
        return;
    }
    [self addChildViewController:childController];
    [containerView addSubview:childController.view];
    [childController didMoveToParentViewController:self];
}

- (void)_removeFromParentViewController:(UIViewController *)targetViewController {
    if (!targetViewController || ![targetViewController isKindOfClass:[UIViewController class]]) {
        return;
    }
    [targetViewController willMoveToParentViewController:nil];
    [targetViewController.view removeFromSuperview];
    [targetViewController removeFromParentViewController];
}

- (BOOL)_replaceViewControllers:(NSMutableArray *)targetControllers atIndex:(NSUInteger)index withObject:(id)object {
    if (object && index < [targetControllers count]) {
        [targetControllers replaceObjectAtIndex:index withObject:object];
        return YES;
    }
    return NO;
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context != KVOContext_VESelectionViewController) {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        return;
    }
    
    if (object != self.scrollView) {
        return;
    }
    
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(contentInset))]) {
        [self updateScrollViewContentSize];
    }
}

- (void)updateScrollViewContentSize {
    CGSize contentSize = UIEdgeInsetsInsetRect(self.view.bounds, self.scrollView.contentInset).size;
    contentSize.width *= self.numberOfPages ?: 1;
    self.scrollView.contentSize = contentSize;
    
    [self.viewControllers enumerateObjectsUsingBlock:^(id object, NSUInteger page, BOOL *stop) {
        [self updateChildViewControllerOfPage:page];
    }];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (scrollView != self.scrollView) {
        return;
    }
    
    for (NSInteger page = 0; page < self.numberOfPages; page++) {
        if (page != self.currentPage) {
            [self addChildViewControllerOfPage:page];
        }
    }
}

- (void)scrollViewDidEndScrolling:(UIScrollView *)scrollView {
    [super scrollViewDidEndScrolling:scrollView];
    
    if (scrollView != self.scrollView) {
        return;
    }
    
    CGFloat width = CGRectGetWidth(scrollView.bounds);
    CGFloat position = self.scrollView.contentOffset.x;
    [self setCurrentPage:round(position / width) animated:YES];
    
    for (NSInteger page = 0; page < self.numberOfPages; page++) {
        if (page != self.currentPage) {
            [self removeChildViewControllerOfPage:page];
        }
    }
}

@end

#pragma mark -

//@interface VESelectionViewController (UIStatusBarStyle)
//
//@end
//
//@implementation VESelectionViewController (UIStatusBarStyle)
//
//- (UIViewController *)childViewControllerForStatusBarStyle {
//    return [self viewControllerOfPage:self.currentPage];
//}
//
//- (UIViewController *)childViewControllerForStatusBarHidden {
//    return [self viewControllerOfPage:self.currentPage];
//}
//
//@end
