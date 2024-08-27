//
//  VEPlayerBaseModule.m
//  VEPlayerKit
//

#import "VEPlayerBaseModule.h"
#import "VEPlayerContext.h"

@interface VEPlayerBaseModule ()

@end

@implementation VEPlayerBaseModule

#pragma mark - Life cycle
- (void)moduleDidLoad {
    NSAssert(!self.isLoaded, @"duplicate loading module:%@", self);
    _isLoaded = YES;
}

- (void)viewDidLoad {
    NSAssert(!self.isViewLoaded, @"duplicate loading module:%@", self);
    _isViewLoaded = YES;
}

- (void)controlViewTemplateDidUpdate {
    
}

- (void)moduleDidUnLoad {
    NSAssert(self.isLoaded, @"duplicate loading module:%@", self);
    _isLoaded = NO;
    _isViewLoaded = NO;
}

#pragma mark - Public Mehtod


#pragma mark - Private Mehtod

#pragma mark -- XXX Private Method

#pragma mark - Setter & Getter

@end
