//
//  VEInterface.m
//  VEPlayerUIModule
//
//  Created by real on 2021/9/18.
//

#import "VEInterface.h"
#import <Masonry/Masonry.h>
#import "VEEventConst.h"
#import "VEInterfaceBridge.h"
#import "VEInterfaceFactory.h"

NSString *const VETaskPlayCoreTransfer = @"VETaskPlayCoreTransfer";

NSString *const VEPlayEventPlay = @"VEPlayEventPlay";

NSString *const VEPlayEventPause = @"VEPlayEventPause";

NSString *const VEPlayEventSeek = @"VEPlayEventSeek";

NSString *const VEUIEventScreenOrientationChanged = @"VEUIEventScreenOrientationChanged";

extern NSString *const VEPlayProgressSliderGestureEnable;

@interface VEInterface ()

@end

@implementation VEInterface

- (instancetype)initWithPlayerCore:(id<VEPlayCoreAbilityProtocol>)core scene:(id<VEInterfaceElementDataSource>)scene {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self loadKit];
        [self registEvents];
        [self addObserver];
        [self initializeEventWithCore:core scene:scene];
    }
    return self;
}

- (void)addObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(screenOrientationChanged:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)loadKit {
    [VEInterfaceBridge bridge];
}

- (void)registEvents {
    [[VEEventMessageBus universalBus] registEvent:VEUIEventScreenRotation withAction:@selector(screenRotationAction:) ofTarget:self];
    [[VEEventMessageBus universalBus] registEvent:VEUIEventPageBack withAction:@selector(pageBackAction:) ofTarget:self];
    
    [[VEEventMessageBus universalBus] registEvent:VEPlayProgressSliderGestureEnable withAction:@selector(sliderAction:) ofTarget:self];
}

- (void)initializeEventWithCore:(id<VEPlayCoreAbilityProtocol>)core scene:(id<VEInterfaceElementDataSource>)scene {
    [self reloadCore:core];
    [self buildingScene:scene];
}

- (void)reloadCore:(id<VEPlayCoreAbilityProtocol>)core {
    if ([core conformsToProtocol:@protocol(VEPlayCoreAbilityProtocol)]) {
        [[VEEventMessageBus universalBus] postEvent:VETaskPlayCoreTransfer withObject:core rightNow:YES]; // 外部需要保证core在播放周期内不被释放
    }
}

- (void)buildingScene:(id<VEInterfaceElementDataSource>)scene {
    UIView *interfaceContainer = [VEInterfaceFactory sceneOfMaterial:scene];
    [self addSubview:interfaceContainer];
    [interfaceContainer mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self).offset(0);
    }];
}

- (void)screenRotationAction:(id)param {
    // 让外部旋转屏幕
    if ([self.delegate respondsToSelector:@selector(interfaceCallScreenRotation:)]) {
        [self.delegate interfaceCallScreenRotation:self];
    }
}

- (void)pageBackAction:(id)param {
    if ([self.delegate respondsToSelector:@selector(interfaceCallPageBack:)]) {
        if (normalScreenBehaivor()) {
            [self destory];
        }
        [self.delegate interfaceCallPageBack:self];
    }
}

- (void)sliderAction:(id)param {
    if ([param isKindOfClass:[NSDictionary class]]) {
        NSDictionary *paramDic = (NSDictionary *)param;
        BOOL value = [paramDic.allValues.firstObject boolValue];
        if ([self.delegate respondsToSelector:@selector(interfaceShouldEnableSlide:)]) {
            [self.delegate interfaceShouldEnableSlide:value];
        }
    }
}

- (void)destory {
    @autoreleasepool {
        [VEEventMessageBus destroyUnit];
        [VEEventPoster destroyUnit];
        [VEInterfaceBridge destroyUnit];
        [self removeFromSuperview];
    }
}


#pragma mark ----- UIInterfaceOrientation

- (void)screenOrientationChanged:(NSNotification *)notification {
    [[VEEventMessageBus universalBus] postEvent:VEUIEventScreenOrientationChanged withObject:nil rightNow:YES];
}


#pragma mark ----- Tool

static inline BOOL normalScreenBehaivor () {
    return ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait);
}



@end
