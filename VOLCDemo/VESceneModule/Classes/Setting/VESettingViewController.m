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
#import "VEPlayUrlConfigViewController.h"
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
    self.title = NSLocalizedStringFromTable(@"title_video_setting", @"VodLocalizable", nil);
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
            headerLabel.backgroundColor = [UIColor colorWithRed:247.0/255.0 green:248.0/255.0 blue:250.0/255.0 alpha:1.0];
            headerLabel.text = [NSString stringWithFormat:@"    %@", sectionKey];
            headerLabel.font = [UIFont systemFontOfSize:14.0];
            headerLabel.textColor = [UIColor colorWithRed:134.0/255.0 green:144.0/255.0 blue:136.0/255.0 alpha:1.0];
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
    
    /// select play source
    if (model.settingKey == VESettingKeyUniversalPlaySourceType) {
        [self alertUrlViewWithCurrentSettingsModel:model];
    } else if (model.settingKey == VESettingKeyAdPreloadCount || model.settingKey == VESettingKeyAdInterval) {
        [self alertAdViewWithCurrentSettingsModel:model];
    } else if (model.settingKey == VESettingKeyDebugCustomPlaySourceType) {
        VEPlayUrlConfigViewController *playUrlViewController = [VEPlayUrlConfigViewController new];
        [self.navigationController pushViewController:playUrlViewController animated:YES];
    }
}


- (void)alertUrlViewWithCurrentSettingsModel:(VESettingModel *)settingsModel {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedStringFromTable(@"title_setting_Source_Type_Select", @"VodLocalizable", nil) message:@"support vid and url play source" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *vidSource = [UIAlertAction actionWithTitle:@"Vid Play Source" style:[settingsModel.currentValue integerValue] == VEPlaySourceType_Vid ? UIAlertActionStyleDestructive : UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        settingsModel.currentValue = @(VEPlaySourceType_Vid);
        settingsModel.detailText = NSLocalizedStringFromTable(@"title_setting_Source_Type_Vid", @"VodLocalizable", nil);
        [self.tableView reloadData];
    }];
    UIAlertAction *urlSource = [UIAlertAction actionWithTitle:@"Url Play Source" style:[settingsModel.currentValue integerValue] == VEPlaySourceType_Url ? UIAlertActionStyleDestructive : UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        settingsModel.currentValue = @(VEPlaySourceType_Url);
        settingsModel.detailText = NSLocalizedStringFromTable(@"title_setting_Source_Type_Url", @"VodLocalizable", nil);
        [self.tableView reloadData];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [alert addAction:vidSource];
    [alert addAction:urlSource];
    [alert addAction:cancel];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)alertAdViewWithCurrentSettingsModel:(VESettingModel *)settingsModel {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:settingsModel.displayText message:@"" preferredStyle:UIAlertControllerStyleAlert];
    NSArray* nums = @[@"2", @"5", @"10"];
    for (NSString *num in nums) {
        UIAlertAction *action = [UIAlertAction actionWithTitle:num style:[settingsModel.currentValue integerValue] == [num integerValue] ? UIAlertActionStyleDestructive : UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            settingsModel.currentValue = @([num integerValue]);
            settingsModel.detailText = num;
            [self.tableView reloadData];
        }];
        [alert addAction:action];
    }
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {

    }];

    [alert addAction:cancel];

    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark ----- Lazy Load

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.backgroundColor = [UIColor colorWithRed:247.0/255.0 green:248.0/255.0 blue:250.0/255.0 alpha:1.0];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.estimatedRowHeight = 0.0;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _tableView;
}


@end
