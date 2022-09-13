//
//  VEInterfaceContainer.m
//  VEPlayerUIModule
//
//  Created by real on 2021/9/18.
//

#import "VEInterfaceContainer.h"
#import "VEInterfaceProtocol.h"
#import "VEInterfaceVisual.h"
#import "VEInterfaceSensor.h"
#import "VEInterfaceFloater.h"
#import "VEEventConst.h"
#import "Masonry.h"

@interface VEInterfaceContainer ()

@property (nonatomic, strong) VEInterfaceSensor *sensorView;

@property (nonatomic, strong) VEInterfaceVisual *visualView;

@property (nonatomic, strong) VEInterfaceFloater *floaterView;

@end

@implementation VEInterfaceContainer

- (instancetype)initWithScene:(id<VEInterfaceElementDataSource>)scene {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        [self initializeSublayers:scene];
        [self registEvents];
    }
    return self;
}

- (void)registEvents {
    [[VEEventMessageBus universalBus] registEvent:VEUIEventLockScreen withAction:@selector(lockScreenAction:) ofTarget:self];
    [[VEEventMessageBus universalBus] registEvent:VEUIEventClearScreen withAction:@selector(clearScreenAction:) ofTarget:self];
}

- (void)initializeSublayers:(id<VEInterfaceElementDataSource>)scene {
    if (!self.sensorView) {
        self.sensorView = [[VEInterfaceSensor alloc] initWithScene:scene];
    }
    [self addSubview:self.sensorView];
    if (!self.visualView) {
        self.visualView = [[VEInterfaceVisual alloc] initWithScene:scene];
    }
    [self addSubview:self.visualView];
    if (!self.floaterView) {
        self.floaterView = [[VEInterfaceFloater alloc] initWithScene:scene];
    }
    [self addSubview:self.floaterView];
    [self layoutSubModules];
}

- (void)layoutSubModules {
    [self.visualView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self).offset(0);
    }];
    
    [self.sensorView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self).offset(0);
    }];

    [self.floaterView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self).offset(0);
    }];
}

- (void)lockScreenAction:(id)param {
    BOOL screenIsLocking = [[VEEventPoster currentPoster] screenIsLocking];
    [[VEEventPoster currentPoster] setScreenIsLocking:!screenIsLocking];
    [[VEEventMessageBus universalBus] postEvent:VEUIEventScreenLockStateChanged withObject:nil rightNow:YES];
}

- (void)clearScreenAction:(id)param {
    if ([param isKindOfClass:[NSDictionary class]]) {
        NSDictionary *paramDic = (NSDictionary *)param;
        id value = paramDic.allValues.firstObject;
        if ([value isKindOfClass:[NSNumber class]]) {
            [[VEEventPoster currentPoster] setScreenIsClear:[value boolValue]];
        } else {
            BOOL screenIsClear = [[VEEventPoster currentPoster] screenIsClear];
            [[VEEventPoster currentPoster] setScreenIsClear:!screenIsClear];
        }
        [[VEEventMessageBus universalBus] postEvent:VEUIEventScreenClearStateChanged withObject:nil rightNow:YES];
    }
}

@end
