//
//  TTVideoEngineVidSource+VEVidSource.m
//  VOLCDemo
//
//  Created by wangzhiyong on 2021/12/5.
//

#import "TTVideoEngineVidSource+VEVidSource.h"
#import <objc/runtime.h>

@implementation TTVideoEngineVidSource (VEVidSource)

@dynamic title, cover;


#pragma mark - Setter && getter

- (void)setTitle:(NSString *)title {
    objc_setAssociatedObject(self, @selector(title), title, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)title {
    return objc_getAssociatedObject(self, @selector(title));
}

- (void)setCover:(NSString *)cover {
    objc_setAssociatedObject(self, @selector(cover), cover, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)cover {
    return objc_getAssociatedObject(self, @selector(cover));
}

@end
