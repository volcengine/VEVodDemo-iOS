//
//  VEPageViewController.h
//  VOLCDemo
//
//  Created by real on 2022/7/12.
//  Copyright © 2022 ByteDance. All rights reserved.
//

@import UIKit;

typedef enum : NSUInteger {
    VEPageItemMoveDirectionUnknown,
    VEPageItemMoveDirectionPrevious,
    VEPageItemMoveDirectionNext
} VEPageItemMoveDirection;

@class VEPageViewController;

@protocol VEPageItem <NSObject>

@optional

@property (nonatomic, copy) NSString *reuseIdentifier;

- (void)prepareForReuse;

- (void)itemDidLoad;

@end

@protocol VEPageDataSource <NSObject>

@required

- (__kindof UIViewController<VEPageItem> *)pageViewController:(VEPageViewController *)pageViewController
                                           pageForItemAtIndex:(NSUInteger)index;

- (NSInteger)numberOfItemInPageViewController:(VEPageViewController *)pageViewController;

@optional
- (BOOL)shouldScrollVertically:(VEPageViewController *)pageViewController;

@end

@protocol VEPageDelegate <NSObject>

@optional

- (void)pageViewController:(VEPageViewController *)pageViewController
  didScrollChangeDirection:(VEPageItemMoveDirection)direction
            offsetProgress:(CGFloat)progress;

- (void)pageViewController:(VEPageViewController *)pageViewController
           willDisplayItem:(id<VEPageItem>)viewController;

- (void)pageViewController:(VEPageViewController *)pageViewController
            didDisplayItem:(id<VEPageItem>)viewController;

@end

@interface VEPageViewController : UIViewController

@property (nonatomic, assign) NSUInteger currentIndex;

@property (nonatomic, weak) id<VEPageDelegate>delegate;

@property (nonatomic, weak) id<VEPageDataSource>dataSource;

@property (nonatomic, strong, readonly) UIScrollView *scrollView;

- (__kindof UIViewController<VEPageItem> *)dequeueItemForReuseIdentifier:(NSString *)reuseIdentifier;

- (void)reloadData;
- (void)reloadNextData;
- (void)reloadPreData;
- (void)reloadDataWithPageIndex:(NSInteger)index animated:(BOOL)animated;

- (void)invalidateLayout;

- (void)reloadContentSize;

@end
