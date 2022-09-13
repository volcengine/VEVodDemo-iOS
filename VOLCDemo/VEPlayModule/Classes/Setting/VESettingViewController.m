//
//  VESettingViewController.m
//  VOLCDemo
//
//  Created by real on 2022/8/22.
//  Copyright © 2022 ByteDance. All rights reserved.
//

#import "VESettingViewController.h"
#import "VESettingDisplayCell.h"
#import "VESettingSwitcherCell.h"
#import "VESettingDisplayDetailCell.h"
#import "VESettingTypeMutilSelectorCell.h"
#import "VESettingManager.h"
#import <Masonry/Masonry.h>
#import "UIColor+RGB.h"

extern NSString *universalActionSectionKey;

@interface VESettingViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation VESettingViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initialUI];
}

- (void)initialUI {
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.tableView];
    [self.tableView registerNib:[UINib nibWithNibName:@"VESettingDisplayCell" bundle:nil] forCellReuseIdentifier:VESettingDisplayCellReuseID];
    [self.tableView registerNib:[UINib nibWithNibName:@"VESettingSwitcherCell" bundle:nil] forCellReuseIdentifier:VESettingSwitcherCellReuseID];
    [self.tableView registerNib:[UINib nibWithNibName:@"VESettingDisplayDetailCell" bundle:nil] forCellReuseIdentifier:VESettingDisplayDetailCellReuseID];
    [self.tableView registerNib:[UINib nibWithNibName:@"VESettingTypeMutilSelectorCell" bundle:nil] forCellReuseIdentifier:VESettingTypeMutilSelectorCellReuseID];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    self.title = NSLocalizedString(@"title_video_setting", nil);
    self.navigationItem.leftBarButtonItem = ({
        UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(close)];
        leftItem.tintColor = [UIColor blackColor];
        leftItem;
    });
}


#pragma mark ----- UITableViewDelegate & DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[[VESettingManager universalManager] settingSections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString *sectionKey = [[[VESettingManager universalManager] settingSections] objectAtIndex:section];
    NSArray *settings = [[[VESettingManager universalManager] settings] valueForKey:sectionKey];
    return settings.count;
}

- (VESettingCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *sectionKey = [[[VESettingManager universalManager] settingSections] objectAtIndex:indexPath.section];
    NSArray *settings = [[[VESettingManager universalManager] settings] valueForKey:sectionKey];
    VESettingModel *model = [settings objectAtIndex:indexPath.row];
    VESettingCell *cell = [tableView dequeueReusableCellWithIdentifier:model.cellInfo.allKeys.firstObject];
    cell.showTopLine = !indexPath.row;
    [cell performSelector:@selector(setSettingModel:) withObject:model];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *sectionKey = [[[VESettingManager universalManager] settingSections] objectAtIndex:indexPath.section];
    NSArray *settings = [[[VESettingManager universalManager] settings] valueForKey:sectionKey];
    VESettingModel *model = [settings objectAtIndex:indexPath.row];
    return model.cellHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *sectionKey = [[[VESettingManager universalManager] settingSections] objectAtIndex:section];
    if ([sectionKey isEqualToString:universalActionSectionKey]) {
        return [UIView new];
    } else {
        return ({
            UILabel *headerLabel = [UILabel new];
            headerLabel.text = [NSString stringWithFormat:@"    %@", sectionKey];
            headerLabel.font = [UIFont systemFontOfSize:14.0];
            headerLabel.textColor = [UIColor colorWithRGB:0x86909C alpha:1.0];
            headerLabel;
        });
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    NSString *sectionKey = [[[VESettingManager universalManager] settingSections] objectAtIndex:section];
    return [sectionKey isEqualToString:universalActionSectionKey] ? 30.0 : 50.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *sectionKey = [[[VESettingManager universalManager] settingSections] objectAtIndex:indexPath.section];
    NSArray *settings = [[[VESettingManager universalManager] settings] valueForKey:sectionKey];
    VESettingModel *model = [settings objectAtIndex:indexPath.row];
    if (model.allAreaAction) model.allAreaAction();
}


#pragma mark ----- Lazy Load

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.backgroundColor = [UIColor colorWithRGB:0xF7F8FA alpha:1.0];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.estimatedRowHeight = 0.0;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _tableView;
}


@end
