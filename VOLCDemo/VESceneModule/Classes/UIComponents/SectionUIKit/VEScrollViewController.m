//
//  VEScrollViewController.m
//  VOLCDemo
//

#import "VEScrollViewController.h"
#import <Masonry/Masonry.h>

@interface VEScrollViewController ()

@property (nonatomic, strong) UIScrollView *scrollView;

@end

@implementation VEScrollViewController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    Class scrollViewClass = [self scrollViewClass];
    UIScrollView *scrollView = nil;
    if (scrollViewClass) {
        scrollView = [scrollViewClass new];
    }
    if (!scrollView) {
        scrollView = [UIScrollView new];
        self.scrollView = scrollView;
    }
    
    self.scrollView.delegate = self;
    [self.view addSubview:self.scrollView];
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.width.height.equalTo(self.view);
    }];
}

- (void)dealloc {
    _scrollView.delegate = nil;
}

- (Class _Nullable)scrollViewClass {
    return nil;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        if ([self respondsToSelector:@selector(scrollViewDidEndScrolling:)]) {
            [self scrollViewDidEndScrolling:scrollView];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if ([self respondsToSelector:@selector(scrollViewDidEndScrolling:)]) {
        [self scrollViewDidEndScrolling:scrollView];
    }
}

#pragma mark - VEScrollViewDelegate

- (void)scrollViewDidEndScrolling:(UIScrollView * _Nonnull)scrollView {
    
}

@end
