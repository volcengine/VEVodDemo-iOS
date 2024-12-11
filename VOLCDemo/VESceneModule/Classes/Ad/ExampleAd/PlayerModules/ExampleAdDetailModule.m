//
//  ExampleAdDetailModule.m
//  VESceneModule
//
//  Created by litao.he on 2024/11/11.
//

#import "ExampleAdDetailModule.h"
#import "ExampleAdContextKeyDefine.h"
#import "VEPlayerContext.h"
#import "VEPlayerActionViewInterface.h"
#import <Masonry/Masonry.h>
#import "VEVideoModel.h"
#import "UIColor+Hex.h"
#import "ExampleAdAction.h"

@interface ExampleAdDetailModule ()

@property (nonatomic, strong) UIView* background;
@property (nonatomic, strong) UILabel* title;
@property (nonatomic, strong) UIImageView *tag;
@property (nonatomic, strong) UILabel* detail;
@property (nonatomic, strong) UIButton* more;

@property (nonatomic, weak) id<VEPlayerActionViewInterface> actionViewInterface;
@property (nonatomic, strong) VEVideoModel *adInfo;

@end

@implementation ExampleAdDetailModule

VEPlayerContextDILink(actionViewInterface, VEPlayerActionViewInterface, self.context);

#pragma mark - Life Cycle

- (void)moduleDidLoad {
    [super moduleDidLoad];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self configuratoinCustomView];

    @weakify(self);
    [self.context addKey:ExampleAdContextKeyDataModelChanged withObserver:self handler:^(VEVideoModel *adInfo, NSString *key) {
        @strongify(self);
        self.adInfo = adInfo;
        self.detail.text = self.adInfo.title;
    }];
}

- (void)controlViewTemplateDidUpdate {
    [super controlViewTemplateDidUpdate];
}

- (void)configuratoinCustomView {
    [self.actionViewInterface.underlayControlView addSubview:self.background];
    [self.actionViewInterface.underlayControlView addSubview:self.title];
    [self.actionViewInterface.underlayControlView addSubview:self.tag];
    [self.actionViewInterface.underlayControlView addSubview:self.detail];
    [self.actionViewInterface.underlayControlView addSubview:self.more];
    [self.actionViewInterface.underlayControlView sendSubviewToBack:self.background];

    [self.more mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.actionViewInterface.underlayControlView).offset(32);
        make.right.equalTo(self.actionViewInterface.underlayControlView).offset(-32);
        make.top.equalTo(self.actionViewInterface.underlayControlView.mas_bottom).offset(-68);
        make.bottom.equalTo(self.actionViewInterface.underlayControlView).offset(-32);
    }];

    [self.detail mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.more);
        make.right.equalTo(self.more);
        make.bottom.equalTo(self.more.mas_top).offset(-10);
    }];

    [self.title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.more);
        make.bottom.equalTo(self.detail.mas_top).offset(-10);
    }];
    [self.title sizeToFit];

    [self.tag mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.title.mas_right).offset(5);
        make.top.equalTo(self.title).offset(2);
    }];

    [self.background mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.actionViewInterface.underlayControlView).offset(16);
        make.right.equalTo(self.actionViewInterface.underlayControlView).offset(-16);
        make.top.equalTo(self.title).offset(-16);
        make.bottom.equalTo(self.more).offset(16);
    }];
}

- (void)moduleDidUnLoad {
    [super moduleDidUnLoad];
    if (self.background) {
        [self.background removeFromSuperview];
        self.background = nil;
    }
    if (self.title) {
        [self.title removeFromSuperview];
        self.title = nil;
    }
    if (self.tag) {
        [self.tag removeFromSuperview];
        self.tag = nil;
    }
    if (self.detail) {
        [self.detail removeFromSuperview];
        self.detail = nil;
    }
    if (self.more) {
        [self.more removeFromSuperview];
        self.more = nil;
    }
}

#pragma mark - Event Action

- (void)onClickMoreButton:(UIButton *)sender {
    ExampleAdAction* action = [[ExampleAdAction alloc] initWithAction:@"MoreDetail" andParams:@{@"url": @"https://www.volcengine.com/product/vod"}];
    [self.context post:action forKey:ExampleAdContextKeyActionTriggered];
}

#pragma mark - Setter & Getter

- (UIView *)background {
    if (_background == nil) {
        _background = [[UIView alloc] init];
        _background.backgroundColor = [UIColor colorWithHexString:@"#61616157"];
        _background.layer.cornerRadius = 8.0;
        _background.layer.masksToBounds = YES;
    }
    return _background;
}

- (UILabel *)title {
    if (_title == nil) {
        _title = [[UILabel alloc] init];
        _title.text = @"火山引擎视频点播";
        _title.textColor = [UIColor colorWithHexString:@"#FFFFFFE5"];
        _title.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
        _title.backgroundColor = [UIColor clearColor];
    }
    return _title;
}

- (UIImageView *)tag {
    if (_tag == nil) {
        UIImage* image = [UIImage imageNamed:@"ad_detail_tag"];
        _tag = [[UIImageView alloc] initWithImage:image];
        _tag.frame = CGRectMake(0, 0, image.size.width, image.size.height);
    }
    return _tag;
}

- (UILabel *)detail {
    if (_detail == nil) {
        _detail = [[UILabel alloc] init];
        _detail.text = @"专业一站式解决方案，最低 1 折搭建音视频业务！";
        _detail.textColor = [UIColor colorWithHexString:@"#FFFFFFBF"];
        _detail.font = [UIFont systemFontOfSize:13];
        _detail.backgroundColor = [UIColor clearColor];
        _detail.numberOfLines = 0;
    }
    return _detail;
}

- (UIButton *)more {
    if (_more == nil) {
        _more = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.more setTitle:@"查看详情" forState:UIControlStateNormal];
        [self.more setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.more setBackgroundColor:[UIColor colorWithHexString:@"#FFFFFF26"]];
        _more.titleLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightBold];
        _more.layer.cornerRadius = 6.0;
        _more.layer.masksToBounds = YES;
        [self.more addTarget:self action:@selector(onClickMoreButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _more;
}
@end
