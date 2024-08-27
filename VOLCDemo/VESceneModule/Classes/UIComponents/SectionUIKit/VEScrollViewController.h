//
//  VEScrollViewController.h
//  VOLCDemo
//

#import <UIKit/UIKit.h>

@protocol VEScrollViewDelegate <UITableViewDelegate>

- (void)scrollViewDidEndScrolling:(UIScrollView * _Nonnull)scrollView;

@end

@interface VEScrollViewController : UIViewController <UIScrollViewDelegate, VEScrollViewDelegate>

@property (nonatomic, readonly, strong, nonnull) UIScrollView *scrollView;

- (Class _Nullable)scrollViewClass;

@end
