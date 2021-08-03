//
//  UITableView+VOLC.m
//  VOLCDemo
//
//  Created by wangzhiyong on 2021/6/30.
//  Copyright © 2021 ByteDance. All rights reserved.
//

#import "UITableView+VOLC.h"

@implementation UITableView (VOLC)

- (NSIndexPath *)currentIndexPathForFullScreenCell {
    CGRect visibleRect = CGRectZero;
    visibleRect.origin = self.contentOffset;
    visibleRect.size = self.frame.size;

    CGPoint visiblePoint = CGPointMake(CGRectGetMidX(visibleRect),
                                       CGRectGetMidY(visibleRect));

    return [self indexPathForRowAtPoint:visiblePoint];
}

@end
