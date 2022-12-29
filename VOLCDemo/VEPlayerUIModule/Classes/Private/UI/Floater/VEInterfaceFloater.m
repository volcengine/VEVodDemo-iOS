//
//  VEInterfaceFloater.m
//  VEPlayerUIModule
//
//  Created by real on 2021/11/1.
//

#import "VEInterfaceFloater.h"
#import "VEInterfaceProtocol.h"
#import "VEInterfaceElementDescription.h"
#import "VEEventConst.h"
#import "VEInterfaceSelectionMenu.h"
#import "VEInterfaceSlideMenuArea.h"
#import "Masonry.h"

NSString *const VEUIEventShowMoreMenu = @"VEUIEventShowMoreMenu";

NSString *const VEUIEventShowResolutionMenu = @"VEUIEventShowResolutionMenu";

NSString *const VEUIEventShowPlaySpeedMenu = @"VEUIEventShowPlaySpeedMenu";

NSString *const VEPlayEventResolutionChanged = @"VEPlayEventResolutionChanged";

NSString *const VEPlayEventPlaySpeedChanged = @"VEPlayEventPlaySpeedChanged";

@interface VEInterfaceFloater ()

@property (nonatomic, strong) VEInterfaceSlideMenuArea *slideMenu;

@property (nonatomic, strong) VEInterfaceSelectionMenu *selectionMenu; // language, defination and so on

@end

@implementation VEInterfaceFloater

- (instancetype)initWithScene:(id<VEInterfaceElementDataSource>)scene {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        [self.slideMenu fillElements:[scene customizedElements]];
        [self registEvents];
        [self initializeAction];
        
    }
    return self;
}

- (void)initializeAction {
    [self addTarget:self action:@selector(singleTapAction) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark ----- Message / Action

- (void)registEvents {
    [[VEEventMessageBus universalBus] registEvent:VEUIEventShowMoreMenu withAction:@selector(showMoreMenuAction:) ofTarget:self];
    [[VEEventMessageBus universalBus] registEvent:VEUIEventShowPlaySpeedMenu withAction:@selector(showSpeedMenuAction:) ofTarget:self];
    [[VEEventMessageBus universalBus] registEvent:VEUIEventShowResolutionMenu withAction:@selector(showResolutionMenuAction:) ofTarget:self];
}

- (void)showMoreMenuAction:(id)param {
    [self.slideMenu show:YES];
}

- (void)showSpeedMenuAction:(id)param {
    NSMutableArray<VEInterfaceDisplayItem *> *playSpeedItems = [NSMutableArray array];
    for (NSDictionary *playSpeedDic in [[VEEventPoster currentPoster] playSpeedSet]) {
        VEInterfaceDisplayItem *item = [VEInterfaceDisplayItem new];
        item.title = playSpeedDic.allKeys.firstObject;
        item.itemAction = VEPlayEventChangePlaySpeed;
        item.actionParam = playSpeedDic.allValues.firstObject;
        [playSpeedItems addObject:item];
    }
    self.selectionMenu.items = playSpeedItems;
    [self.selectionMenu show:YES];
}

- (void)showResolutionMenuAction:(id)param {
    NSMutableArray<VEInterfaceDisplayItem *> *resolutionItems = [NSMutableArray array];
    for (NSDictionary *resolutionDic in [[VEEventPoster currentPoster] resolutionSet]) {
        VEInterfaceDisplayItem *item = [VEInterfaceDisplayItem new];
        item.title = resolutionDic.allKeys.firstObject;
        item.itemAction = VEPlayEventChangeResolution;
        item.actionParam = resolutionDic.allValues.firstObject;
        [resolutionItems addObject:item];
    }
    self.selectionMenu.items = resolutionItems;
    [self.selectionMenu show:YES];
}

- (void)singleTapAction {
    [self hideAllFloater];
}

- (void)hideAllFloater {
    [self.selectionMenu show:NO];
    [self.slideMenu show:NO];
}


#pragma mark ----- lazy load

- (VEInterfaceSelectionMenu *)selectionMenu {
    if (!_selectionMenu) {
        _selectionMenu = [VEInterfaceSelectionMenu new];
        _selectionMenu.hidden = YES;
        [self addSubview:_selectionMenu];
        [_selectionMenu mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.trailing.equalTo(self).offset(0);
            make.leading.equalTo(self.mas_centerX);
        }];
    }
    return _selectionMenu;
}

- (VEInterfaceSlideMenuArea *)slideMenu {
    if (!_slideMenu) {
        _slideMenu = [VEInterfaceSlideMenuArea new];
        _slideMenu.hidden = YES;
        [self addSubview:_slideMenu];
        [_slideMenu mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.trailing.equalTo(self).offset(0);
            make.leading.equalTo(self.mas_centerX);
        }];
    }
    return _slideMenu;
}


#pragma mark ----- Response Chain

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    CGRect selectionMenuArea = [self.selectionMenu enableZone];
    CGRect slideMenuArea = [self.slideMenu enableZone];
    if (!CGRectEqualToRect(selectionMenuArea, CGRectZero) || !CGRectEqualToRect(slideMenuArea, CGRectZero)) {
        if (CGRectContainsPoint(selectionMenuArea, point)) {
            return [super hitTest:point withEvent:event];
        } else if (CGRectContainsPoint(slideMenuArea, point)) {
            return [super hitTest:point withEvent:event];
        } else {
            return self;
        }
    } else {
        return nil;
    }
}

@end
