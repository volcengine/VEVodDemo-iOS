//
//  TTVideoEngineSourceCategory.m
//  VOLCDemo
//
//  Created by real on 2022/8/22.
//  Copyright © 2022 ByteDance. All rights reserved.
//

#import "TTVideoEngineSourceCategory.h"
#import <objc/message.h>

@implementation TTVideoEngineMultiEncodingUrlSource (VECodecUrlSource)

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


@implementation TTVideoEngineVidSource (VEVidSource)

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


@implementation TTVideoEngineUrlSource (VEUrlSource)

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
