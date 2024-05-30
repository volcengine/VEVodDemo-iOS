//
//  ShortDramaCollectViewController.m
//  JSONModel
//

#import "ShortDramaCollectViewController.h"
#import <Masonry/Masonry.h>

@interface ShortDramaCollectViewController ()

@property (nonatomic, strong) UIButton *collectButton;
@property (nonatomic, strong) UIButton *collectCountButton;

@end

@implementation ShortDramaCollectViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configuratoinCustomView];
    [self reloadData];
}

- (void)reloadData {
    CGFloat random = (arc4random() % 99) / 3.0 + 1;
    [self.collectCountButton setTitle:[NSString stringWithFormat:@"%.1f万", random] forState:UIControlStateNormal];
}

#pragma mark - UI

- (void)configuratoinCustomView {
    self.view.backgroundColor = [UIColor clearColor];
    
    [self.view addSubview:self.collectButton];
    [self.view addSubview:self.collectCountButton];
    
    [self.collectCountButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.equalTo(self.view);
        make.height.mas_equalTo(18);
    }];
    [self.collectButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.bottom.equalTo(self.collectCountButton.mas_top);
    }];
}

#pragma mark - Private

- (void)collectButtonHandle:(UIButton *)button {
    [button setSelected:!button.isSelected];
}

#pragma mark - lazy load

- (UIButton *)collectButton {
    if (_collectButton == nil) {
        _collectButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _collectButton.backgroundColor = [UIColor clearColor];
        [_collectButton setImage:[UIImage imageNamed:@"icon_collect_nor"] forState:UIControlStateNormal];
        [_collectButton setImage:[UIImage imageNamed:@"icon_collect_sel"] forState:UIControlStateSelected];
        [_collectButton addTarget:self action:@selector(collectButtonHandle:) forControlEvents:UIControlEventTouchUpInside];;
    }
    return _collectButton;
}

- (UIButton *)collectCountButton {
    if (_collectCountButton == nil) {
        _collectCountButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _collectCountButton.backgroundColor = [UIColor clearColor];
        _collectCountButton.titleLabel.font = [UIFont systemFontOfSize:13];
        [_collectCountButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_collectCountButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [_collectCountButton addTarget:self action:@selector(collectButtonHandle:) forControlEvents:UIControlEventTouchUpInside];;
    }
    return _collectCountButton;
}

@end
