//
//  ShortDramaPraiseViewController.m
//  JSONModel
//

#import "ShortDramaPraiseViewController.h"
#import <Masonry/Masonry.h>

@interface ShortDramaPraiseViewController ()

@property (nonatomic, strong) UIButton *praiseButton;
@property (nonatomic, strong) UIButton *praiseCountButton;

@end

@implementation ShortDramaPraiseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configuratoinCustomView];
    [self reloadData];
}

- (void)reloadData {
    CGFloat random = (arc4random() % 99) / 3.0 + 1;
    [self.praiseCountButton setTitle:[NSString stringWithFormat:@"%.1f万", random] forState:UIControlStateNormal];
}

#pragma mark - UI

- (void)configuratoinCustomView {
    self.view.backgroundColor = [UIColor clearColor];
    
    [self.view addSubview:self.praiseButton];
    [self.view addSubview:self.praiseCountButton];
    
    [self.praiseCountButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.equalTo(self.view);
        make.height.mas_equalTo(18);
    }];
    [self.praiseButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.bottom.equalTo(self.praiseCountButton.mas_top);
    }];
}

#pragma mark - Private

- (void)praiseButtonHandle:(UIButton *)button {
    [button setSelected:!button.isSelected];
}

#pragma mark - lazy load

- (UIButton *)praiseButton {
    if (_praiseButton == nil) {
        _praiseButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _praiseButton.backgroundColor = [UIColor clearColor];
        [_praiseButton setImage:[UIImage imageNamed:@"icon_praise_nor"] forState:UIControlStateNormal];
        [_praiseButton setImage:[UIImage imageNamed:@"icon_praise_sel"] forState:UIControlStateSelected];
        [_praiseButton addTarget:self action:@selector(praiseButtonHandle:) forControlEvents:UIControlEventTouchUpInside];;
    }
    return _praiseButton;
}

- (UIButton *)praiseCountButton {
    if (_praiseCountButton == nil) {
        _praiseCountButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _praiseCountButton.backgroundColor = [UIColor clearColor];
        _praiseCountButton.titleLabel.font = [UIFont systemFontOfSize:13];
        [_praiseCountButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_praiseCountButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [_praiseCountButton addTarget:self action:@selector(praiseButtonHandle:) forControlEvents:UIControlEventTouchUpInside];;
    }
    return _praiseCountButton;
}

@end
