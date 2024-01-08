//
//  VEInterfaceSelectionMenu.m
//  VEPlayerUIModule
//
//  Created by real on 2021/10/09.
//

#import "VEInterfaceSelectionMenu.h"
#import "VEEventConst.h"
#import "Masonry.h"

static NSString *VESelectionMenuCellIdentifier = @"VESelectionMenuCellIdentifier";

@interface VEInterfaceSelectionCell : UITableViewCell

@property (nonatomic, strong) VEInterfaceDisplayItem *item;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UIView *highlightBackgroundView;

@end

@implementation VEInterfaceSelectionCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initializeElements];
    }
    return self;
}

- (void)initializeElements {
    self.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = [UIColor clearColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.highlightBackgroundView];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
    [self.highlightBackgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(5);
        make.bottom.equalTo(self.contentView).offset(-5);
        make.leading.equalTo(self.contentView).offset(15);
        make.trailing.equalTo(self.contentView).offset(-15);
    }];
}


#pragma mark ----- variable setter

- (void)setItem:(VEInterfaceDisplayItem *)item {
    _item = item;
    self.titleLabel.text = item.title;
    if ([item.itemAction isEqualToString:VEPlayEventChangeResolution]) {
        NSInteger currentResolution = [[VEEventPoster currentPoster] currentResolution];
        self.highlightBackgroundView.hidden = !([item.actionParam integerValue] == currentResolution);
    } else if ([item.itemAction isEqualToString:VEPlayEventChangePlaySpeed]) {
        CGFloat currentSpeed = [[VEEventPoster currentPoster] currentPlaySpeed];
        self.highlightBackgroundView.hidden = !([item.actionParam floatValue] == currentSpeed);
    }
}


#pragma mark ----- lazy load

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont systemFontOfSize:15.0];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.highlightedTextColor = [UIColor blueColor];
        _titleLabel.backgroundColor = [UIColor clearColor];
    }
    return _titleLabel;
}

- (UIView *)highlightBackgroundView {
    if (!_highlightBackgroundView) {
        _highlightBackgroundView = [UIView new];
        _highlightBackgroundView.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.12];
        _highlightBackgroundView.layer.borderColor = [[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.3] CGColor];
        _highlightBackgroundView.layer.borderWidth = 1;
        _highlightBackgroundView.layer.cornerRadius = 1;
        _highlightBackgroundView.hidden = YES;
    }
    return _highlightBackgroundView;
}

@end

@implementation VEInterfaceDisplayItem

@end

API_AVAILABLE(ios(8.0))
@interface VEInterfaceSelectionMenu () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *menuView;

@property (nonatomic, strong) UIVisualEffectView *backView;

@end

@implementation VEInterfaceSelectionMenu

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initializeElements];
        [[VEEventMessageBus universalBus] registEvent:VEPlayEventChangePlaySpeed withAction:@selector(shouldReload:) ofTarget:self];
        [[VEEventMessageBus universalBus] registEvent:VEPlayEventChangeResolution withAction:@selector(shouldReload:) ofTarget:self];
    }
    return self;
}

- (void)initializeElements {
    [self.menuView registerClass:[VEInterfaceSelectionCell class] forCellReuseIdentifier:VESelectionMenuCellIdentifier];
    [self addSubview:self.backView];
    [self addSubview:self.menuView];
    [self.backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    [self.menuView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self).offset(10);
    }];
}

- (void)reloadData {
    [self.menuView reloadData];
}

#pragma mark ----- UITableView Delegate & DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    VEInterfaceSelectionCell *cell = [tableView dequeueReusableCellWithIdentifier:VESelectionMenuCellIdentifier];
    cell.item = [self.items objectAtIndex:indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    return ((tableView.frame.size.height - 20.0) / 5);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    VEInterfaceDisplayItem *item = [self.items objectAtIndex:indexPath.row];
    [[VEEventMessageBus universalBus] postEvent:item.itemAction withObject:item.actionParam rightNow:YES];
    [self show:NO];
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

- (UITableView *)menuView {
    if (!_menuView) {
        _menuView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _menuView.backgroundColor = [UIColor clearColor];
        _menuView.delegate = self;
        _menuView.dataSource = self;
        _menuView.showsVerticalScrollIndicator = NO;
        _menuView.showsHorizontalScrollIndicator = NO;
        _menuView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _menuView;
}

- (void)setItems:(NSMutableArray<VEInterfaceDisplayItem *> *)items {
    _items = items;
    [self reloadData];
}

- (void)shouldReload:(id)param {
    [self reloadData];
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


