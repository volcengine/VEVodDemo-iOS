// Copyright (c) 2025 Beijing Volcano Engine Technology Co., Ltd.
// SPDX-License-Identifier: MIT
//
//  ViewController.m
//  ApiDemo-iOS
//
//  Created by ByteDance on 2025/4/21.
//

#import "RootViewController.h"
#import "VEAPIButton.h"
#import "VEAPIVideoModel.h"
#import "VEAPIConstants.h"
#import "VEVodPlayerAPIExample-Swift.h"
#import <Masonry/Masonry.h>
#import <TTSDKFramework/TTSDKFramework.h>

static NSString *const kCellReuseIdentifier = @"ApiDemo-iOS-Root";

@interface RootTableCell : UITableViewCell
@end

@implementation RootTableCell
- (void)setFrame:(CGRect)frame {
    frame.origin.y += 10;
    frame.size.height -= 10;
    frame.origin.x = 10;
    frame.size.width -= 20;
    [super setFrame:frame];
}
@end

@interface RootTableSection : NSObject
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSArray<NSDictionary *> *items;
+ (instancetype)sectionWithTitle:(NSString *)title items:(NSArray<NSDictionary *> *)items;
@end

@implementation RootTableSection
+ (instancetype)sectionWithTitle:(NSString *)title items:(NSArray<NSDictionary *> *)items {
    RootTableSection *section = [RootTableSection new];
    section.title = title;
    section.items = items;
    return section;
}
@end

@interface RootViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSArray<RootTableSection *> *sections;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self constructViews];
}

#pragma mark - UI
- (void)constructViews {
    CGFloat topOffset = UIApplication.sharedApplication.statusBarFrame.size.height + self.navigationController.navigationBar.bounds.size.height;
    
    [self.view addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(12);
        make.right.equalTo(self.view).offset(12);
        make.top.equalTo(self.view).offset(topOffset);
        make.height.mas_equalTo(40);
    }];
    
    [self setupDataSource];
    [self.view addSubview:self.tableView];
    [self.tableView registerClass:[RootTableCell class] forCellReuseIdentifier:kCellReuseIdentifier];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom).offset(5);
        make.left.right.equalTo(self.view).inset(10);
        make.bottom.equalTo(self.view);
    }];
}

- (UILabel *)titleLabel {
  if (!_titleLabel) {
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.text = NSLocalizedString(@"root_title", NULL);
    _titleLabel.font = [UIFont systemFontOfSize:24];
    _titleLabel.textColor = UIColor.blackColor;
  }
  return _titleLabel;
}

- (UITableView *)tableView {
    if (_tableView == NULL) {
        _tableView = [[UITableView alloc] init];
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.tag = 0;
        _tableView.sectionHeaderHeight = 44.0;
        _tableView.rowHeight = 50.0;
    }
    return _tableView;
}

#pragma mark - UITableViewDataSource and UITableViewDelegate
- (void)setupDataSource {
    self.sections = @[
        [RootTableSection sectionWithTitle:NSLocalizedString(@"quick_start_oc", NULL)
                                     items:@[@{@"title": NSLocalizedString(@"direct_url_play", NULL),
                                                  @"vc": kDirectUrlSourceOCVC},
                                             @{@"title": NSLocalizedString(@"vid_play", NULL),
                                                  @"vc": kVidSourceSourceOCVC},
                                           ]],
        [RootTableSection sectionWithTitle:NSLocalizedString(@"quick_start_swift", NULL)
                                     items:@[@{@"title": NSLocalizedString(@"direct_url_play", NULL),
                                                  @"vc": kDirectUrlSourceSwiftVC},
                                             @{@"title": NSLocalizedString(@"vid_play", NULL),
                                                  @"vc": kVidSourceSourceSwiftVC},
                                           ]],
        [RootTableSection sectionWithTitle:NSLocalizedString(@"basic_featuers_oc", NULL)
                                     items:@[@{@"title": NSLocalizedString(@"basic_feature", NULL),
                                                  @"vc": kBasicPlaybackSourceOCVC},
                                             @{@"title": NSLocalizedString(@"display_mode", NULL),
                                                  @"vc": kDisplayModeSourceOCVC},
                                             @{@"title": NSLocalizedString(@"clear_caches", NULL),
                                                  @"vc": kClearCaches},
                                           ]],
        [RootTableSection sectionWithTitle:NSLocalizedString(@"basic_featuers_swift", NULL)
                                     items:@[@{@"title": NSLocalizedString(@"basic_feature", NULL),
                                                  @"vc": kBasicPlaybackSourceSwiftVC},
                                             @{@"title": NSLocalizedString(@"display_mode", NULL),
                                                  @"vc": kDisplayModeSourceSwiftVC},
                                             @{@"title": NSLocalizedString(@"clear_caches", NULL),
                                                  @"vc": kClearCaches},
                                           ]],
        [RootTableSection sectionWithTitle:NSLocalizedString(@"best_practice_oc", NULL)
                                     items:@[@{@"title": NSLocalizedString(@"dy_best_practice", NULL),
                                                  @"vc": kShortVideoSourceOCVC},
                                             ]],
        [RootTableSection sectionWithTitle:NSLocalizedString(@"best_practice_swift", NULL)
                                     items:@[@{@"title": NSLocalizedString(@"dy_best_practice", NULL),
                                                  @"vc": kShortVideoSourceSwiftVC},
                                             ]],
        [RootTableSection sectionWithTitle:NSLocalizedString(@"advanced_features_oc", NULL)
                                     items:@[@{@"title": NSLocalizedString(@"vid_subtitle", NULL),
                                                  @"vc": kVidSubtitleSourceOCVC},
                                             @{@"title": NSLocalizedString(@"direct_url_subtitle", NULL),
                                                  @"vc": kDirectUrlSubtitleSourceOCVC},
                                             @{@"title": NSLocalizedString(@"debug_tool", NULL),
                                                  @"vc": kDebugToolSourceOCVC},
                                             ]],
        [RootTableSection sectionWithTitle:NSLocalizedString(@"advanced_features_swift", NULL)
                                     items:@[@{@"title": NSLocalizedString(@"vid_subtitle", NULL),
                                                  @"vc": kVidSubtitleSourceSwiftVC},
                                             @{@"title": NSLocalizedString(@"direct_url_subtitle", NULL),
                                                  @"vc": kDirectUrlSubtitleSourceSwiftVC},
                                             @{@"title": NSLocalizedString(@"debug_tool", NULL),
                                                  @"vc": kDebugToolSourceSwiftVC},
                                             ]],
    ];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.sections[section].items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellReuseIdentifier forIndexPath:indexPath];
    cell.textLabel.text = self.sections[indexPath.section].items[indexPath.row][@"title"];
    cell.textLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.backgroundColor = [UIColor colorWithRed:230/255.0 green:230/255.0 blue:230/255.0 alpha:1.0];
    cell.layer.cornerRadius = 8;
    cell.layer.masksToBounds = YES;
    cell.selectedBackgroundView.layer.cornerRadius = 8;
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UILabel *label = [UILabel new];
    label.text = self.sections[section].title;
    label.font = [UIFont systemFontOfSize:14 weight:UIFontWeightSemibold];
    label.backgroundColor = [UIColor whiteColor];
    label.textColor = [UIColor blueColor];
    return label;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if (indexPath.section == 2 && indexPath.row == 2) {
        NSLog(@"VEVodPlayerAPIExample - clear caches use OC interface");
        [VEAPIVideoModel removeAllCaches:YES];
    }else if (indexPath.section == 3 && indexPath.row == 2) {
        NSLog(@"VEVodPlayerAPIExample - clear caches use swift interface");
        [VEAPISwiftVideoModel removeAllCachesSwift:YES];
    }
    
    Class vcClass;
    vcClass = NSClassFromString(self.sections[indexPath.section].items[indexPath.row][@"vc"]);
    if (!vcClass) {
        NSLog(@"VEVodPlayerAPIExample - viewController doesn't exist");
        return;
    }
        
    UIViewController *targetVC = [[vcClass alloc] init];
    if ([self.navigationController respondsToSelector:@selector(pushViewController:animated:)]) {
        [self.navigationController pushViewController:targetVC animated:YES];
    }else {
        NSLog(@"VEVodPlayerAPIExample - target viewController can't jump");
    }
}

@end
