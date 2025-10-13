//
//  VEPlayerVisibleModule.m
//  VEPlayerKit
//
//  Created by zys on 2025/10/14.
//

#import "VEPlayerVisibleModule.h"
#import "VEPlayerContextKeyDefine.h"
#import "VEPlayerGestureServiceInterface.h"

@interface VEPlayerVisibleModule () <VEPlayerGestureHandlerProtocol>

@property (nonatomic, weak) id<VEPlayerGestureServiceInterface> gestureService;
@property (nonatomic, assign) BOOL isShown;

@end

@implementation VEPlayerVisibleModule

VEPlayerContextDILink(gestureService, VEPlayerGestureServiceInterface, self.context);

#pragma mark - Life Cycle

- (void)moduleDidLoad {
    [super moduleDidLoad];
    self.isShown = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.gestureService addGestureHandler:self forType:VEGestureType_SingleTap];
    
    @weakify(self);
    [self.context addKey:VEPlayerContextKeyViewVisible withObserver:self handler:^(NSNumber * _Nullable shown, NSString * _Nullable key) {
        @strongify(self);
        self.isShown = [shown boolValue];
    }];
    
    [self.context addKey:VEPlayerContextKeyGestureEnabled withObserver:self handler:^(NSNumber * _Nullable enabled, NSString * _Nullable key) {
        @strongify(self);
        BOOL value = [enabled boolValue];
        if (value) {
            [self.gestureService addGestureHandler:self forType:VEGestureType_SingleTap];
        }else {
            [self.gestureService removeGestureHandler:self forType:VEGestureType_SingleTap];
        }
    }];
}

- (void)controlViewTemplateDidUpdate {
    [super controlViewTemplateDidUpdate];
}

- (void)moduleDidUnLoad {
    [super moduleDidUnLoad];
}

#pragma mark - VEPlayerGestureHandlerProtocol

- (void)handleGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer gestureType:(VEGestureType)gestureType {
    if (gestureType == VEGestureType_SingleTap) {
        [self.context post:@(!self.isShown) forKey:VEPlayerContextKeyViewVisible];
    }
}

@end

