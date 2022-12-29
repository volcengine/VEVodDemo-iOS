//
//  VEInterfaceSlideMenuArea.m
//  VEPlayerUIModule
//
//  Created by real on 2021/9/24.
//

#import "VEInterfaceSlideMenuArea.h"
#import "VEInterfaceSlideMenuCell.h"
#import "VEInterfaceElementDescription.h"
#import "Masonry.h"
#import "VEEventConst.h"

static NSString *VEInterfaceSlideMenuCellIdentifier = @"VEInterfaceSlideMenuCellIdentifier";

NSString *const VEPlayEventChangeLoopPlayMode = @"VEPlayEventChangeLoopPlayMode";

@interface VEInterfaceSlideMenuArea () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *menuView;

@property (nonatomic, strong) UIVisualEffectView *backView;

@property (nonatomic, strong) NSArray *menuElements;

@end

@implementation VEInterfaceSlideMenuArea

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initializeMenu];
    }
    return self;
}

- (void)initializeMenu {
    [self.menuView registerClass:[VEInterfaceSlideMenuCell class] forCellWithReuseIdentifier:VEInterfaceSlideMenuCellIdentifier];
    [self addSubview:self.backView];
    [self addSubview:self.menuView];
    [self.menuView reloadData];
    [self.menuView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self).offset(20);
    }];
    [self.backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}

- (void)fillElements:(NSArray<VEInterfaceElementDescription *> *)elements {
    [self checkMenuElements:elements];
    [self.menuView reloadData];
}

- (void)checkMenuElements:(NSArray<id<VEInterfaceElementDescription>> *)elements {
    NSMutableArray *menuElements = [NSMutableArray array];
    [elements enumerateObjectsUsingBlock:^(id<VEInterfaceElementDescription> elementDes, NSUInteger idx, BOOL * _Nonnull stop) {
        if (elementDes.type == VEInterfaceElementTypeMenuNormalCell) {
            [menuElements addObject:elementDes];
        }
    }];
    self.menuElements = [NSArray arrayWithArray:menuElements];
}


#pragma mark ----- UICollectionView Delegate & DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.menuElements.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    VEInterfaceSlideMenuCell *cell = [collectionView
                                                dequeueReusableCellWithReuseIdentifier:VEInterfaceSlideMenuCellIdentifier forIndexPath:indexPath];
    id<VEInterfaceElementDescription> elementDes = [self.menuElements objectAtIndex:indexPath.item];
    if (elementDes.elementDisplay) elementDes.elementDisplay(cell);
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    id<VEInterfaceElementDescription> elementDes = [self.menuElements objectAtIndex:indexPath.item];
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    NSString *eventKey = elementDes.elementAction(cell);
    if ([eventKey isKindOfClass:[NSString class]]) {
        [[VEEventMessageBus universalBus] postEvent:eventKey withObject:nil rightNow:YES];
    } else if ([eventKey isKindOfClass:[NSDictionary class]]) {
        NSDictionary *eventDic = (NSDictionary *)eventKey;
        [[VEEventMessageBus universalBus] postEvent:eventDic.allKeys.firstObject withObject:eventDic.allValues.firstObject rightNow:YES];
    }
    [collectionView reloadData];
}


#pragma mark ----- lazy load

- (UIVisualEffectView *)backView {
    if (!_backView) {
        if (@available(iOS 8.0, *)) {
            UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
            _backView = [[UIVisualEffectView alloc] initWithEffect:blur];
        }
    }
    return _backView;
}

- (UICollectionView *)menuView {
    if (!_menuView) {
        _menuView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:({
            UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
            layout.scrollDirection = UICollectionViewScrollDirectionVertical;
            layout.itemSize = CGSizeMake(60.0, 60.0);
            layout;
        })];
        _menuView.showsVerticalScrollIndicator = NO;
        _menuView.showsHorizontalScrollIndicator = NO;
        _menuView.backgroundColor = [UIColor clearColor];
        _menuView.delegate = self;
        _menuView.dataSource = self;
    }
    return _menuView;
}


#pragma mark ----- VEInterfaceFloaterPresentProtocol

- (CGRect)enableZone {
    if (self.hidden) {
        return CGRectZero;
    } else {
        return self.frame;
    }
}

- (void)show:(BOOL)show {
    [[VEEventPoster currentPoster] setScreenIsClear:show];
    [[VEEventMessageBus universalBus] postEvent:VEUIEventScreenClearStateChanged withObject:nil rightNow:YES];
    self.hidden = !show;
}

@end
