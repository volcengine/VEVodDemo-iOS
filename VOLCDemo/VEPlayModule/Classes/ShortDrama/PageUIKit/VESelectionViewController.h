//
//  VESelectionViewController.h
//  VOLCDemo
//

#import "VEScrollViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface VESelectionViewController : VEScrollViewController

@property (nonatomic, readonly, strong) NSMutableArray *viewControllers;

@property (nonatomic, readonly) NSInteger numberOfPages;
@property (nonatomic, readonly) NSInteger currentPage;

- (void)setupWithNumberOfPages:(NSInteger)numberOfPages;

- (UIViewController *)viewControllerOfPage:(NSInteger)page;
- (void)scrollToPage:(NSInteger)page animated:(BOOL)animated;

/**
 *  automaticallyAdjustsScrollViewInsets of the generated viewControllers will be set to NO
 */
- (UIViewController *)generateViewControllerOfPage:(NSInteger)page;

/**
 *  default: UIEdgeInsetsMake(0, 0, 0, 0)
 */
- (UIEdgeInsets)viewInsetsOfPage:(NSInteger)page;
/**
 *  default: UIEdgeInsetsMake(self.topLayoutGuide.length, 0, self.bottomLayoutGuide.length, 0)
 */
- (UIEdgeInsets)scrollViewInsets;

- (void)willScrollToPage:(NSInteger)page animated:(BOOL)animated;
- (void)didScrollToPage:(NSInteger)page animated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
