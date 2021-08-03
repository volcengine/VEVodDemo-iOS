//
//  VOLCUserGlobalConfigViewController.m
//  VOLCDemo
//
//  Created by wangzhiyong on 2021/5/31.
//  Copyright © 2021 ByteDance. All rights reserved.
//

#import "VOLCUserGlobalConfigViewController.h"
#import "VOLCGlobalConfigSwitchViewCell.h"
#import "VOLCGlobalConfigModel.h"
#import "VOLCUserGlobalConfiguration.h"
#import "VOLCGlobalConfigDeviceIdViewCell.h"
#import <RangersAppLog.h>
#import <TTSDK/TTVideoEngine+Preload.h>

NSString *const kSettingSwitchViewCellIdentifier = @"kSettingSwitchViewCellIdentifie";
NSString *const kSettingDeviceIdViewCellIdentifier = @"kSettingDeviceIdViewCellIdentifier";

@interface VOLCUserGlobalConfigViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, copy) NSArray<NSArray <VOLCGlobalConfigModel *>*> *datasource;

@end

@implementation VOLCUserGlobalConfigViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configuratoinCustomView];
    [self.tableView reloadData];
}

- (void)configuratoinCustomView {
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self.tableView registerClass:[VOLCGlobalConfigSwitchViewCell class] forCellReuseIdentifier:kSettingSwitchViewCellIdentifier];
    [self.tableView registerClass:[VOLCGlobalConfigDeviceIdViewCell class] forCellReuseIdentifier:kSettingDeviceIdViewCellIdentifier];
}

- (NSString *)getTableCellIdentifier:(nonnull NSIndexPath *)indexPath {
    VOLCGlobalConfigModel *hardDecode = [[self.datasource objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    NSString *identifier = kSettingSwitchViewCellIdentifier;
    if (hardDecode.settingType == VOLCSettingTypeCopyDeviceId) {
        identifier = kSettingDeviceIdViewCellIdentifier;
    }
    return identifier;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.datasource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count = 0;
    if (section < self.datasource.count) {
        count = self.datasource[section].count;
    }
    return count;
}

- (UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[self getTableCellIdentifier:indexPath] forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    VOLCGlobalConfigModel *model = [[self.datasource objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    if ([cell isKindOfClass:[VOLCGlobalConfigSwitchViewCell class]]) {
        if (indexPath.section < self.datasource.count && indexPath.row < self.datasource[indexPath.section].count) {
            VOLCGlobalConfigSwitchViewCell *targetCell = (VOLCGlobalConfigSwitchViewCell *)cell;
            targetCell.titleLabel.text = model.title;
            [targetCell.switcher setOn:model.isSwitchOn];
        }
    } else if ([cell isKindOfClass:[VOLCGlobalConfigDeviceIdViewCell class]]) {
        if (indexPath.section < self.datasource.count && indexPath.row < self.datasource[indexPath.section].count) {
            VOLCGlobalConfigDeviceIdViewCell *targetCell = (VOLCGlobalConfigDeviceIdViewCell *)cell;
            targetCell.titleLabel.text = model.title;
            targetCell.deviceIdLabel.text = model.deviceId;;
        }
    }
    return cell;
}


#pragma mark - tableview delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    VOLCGlobalConfigModel *model = self.datasource[indexPath.section][indexPath.row];
    CGFloat height = 50;
    if (model.settingType == VOLCSettingTypeCopyDeviceId) {
        height = 88;
    }
    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section < self.datasource.count && indexPath.row < self.datasource[indexPath.section].count) {
        VOLCGlobalConfigModel *model = self.datasource[indexPath.section][indexPath.row];
        model.isSwitchOn = !model.isSwitchOn;

        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        if ([cell isKindOfClass:[VOLCGlobalConfigSwitchViewCell class]]) {
            [((VOLCGlobalConfigSwitchViewCell *)cell).switcher setOn:model.isSwitchOn];
            VOLCUserGlobalConfiguration *globalConfigs = [VOLCUserGlobalConfiguration sharedInstance];
            switch (model.settingType) {
                case VOLCSettingTypeHardDecode:
                    [globalConfigs setSwitch:model.isSwitchOn forType:UserGlobalConfigHardDecode];
                    break;
                case VOLCSettingTypeH265:
                    [globalConfigs setSwitch:model.isSwitchOn forType:UserGlobalConfigH265];
                    break;
                case VOLCSettingTypePreload:
                    [globalConfigs setSwitch:model.isSwitchOn forType:UserGlobalConfigisMDLPreloadOn];
                    break;
                case VOLCSettingTypeEngineReportLog:
                    [globalConfigs setSwitch:model.isSwitchOn forType:UserGlobalConfigEngineReportLog];
                    break;
                case VOLCSettingTypeMDLReportLog: {
                    [globalConfigs setSwitch:model.isSwitchOn forType:UserGlobalConfigMDLReportLog];
                    [TTVideoEngine ls_localServerConfigure].reportNetLogEnable = model.isSwitchOn;
                }
                    break;
                default:
                    break;
            }
            [globalConfigs serializeData];
        } else if ([cell isKindOfClass:[VOLCGlobalConfigDeviceIdViewCell class]]) {
            [UIPasteboard generalPasteboard].string = model.deviceId;
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.mode = MBProgressHUDModeText;
            hud.label.text = NSLocalizedString(@"tip_copy_success", nil);
            [hud hideAnimated:YES afterDelay:2.0];
        }
    }
}

#pragma mark - lazy load

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero];
        _tableView.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _tableView;
}

- (NSArray<NSArray<VOLCGlobalConfigModel *> *> *)datasource {
    if (!_datasource) {
        VOLCUserGlobalConfiguration *globalConfig = [VOLCUserGlobalConfiguration sharedInstance];
        
        // hard decode
        VOLCGlobalConfigModel *hardDecode = [[VOLCGlobalConfigModel alloc] init];
        hardDecode.title = NSLocalizedString(@"Setting_Hard_Decode", nil);
        hardDecode.isSwitchOn = globalConfig.isHardDecodeOn;
        hardDecode.settingType = VOLCSettingTypeHardDecode;
        
        // H265
        VOLCGlobalConfigModel *h265Config = [[VOLCGlobalConfigModel alloc] init];
        h265Config.title = NSLocalizedString(@"Setting_H265", nil);
        h265Config.isSwitchOn = globalConfig.isH265Enabled;
        h265Config.settingType = VOLCSettingTypeH265;
        
        // preload
        VOLCGlobalConfigModel *preloadNeeded = [[VOLCGlobalConfigModel alloc] init];
        preloadNeeded.title = NSLocalizedString(@"Setting_Preload", nil);
        preloadNeeded.isSwitchOn = globalConfig.isMDLPreloadOn;
        preloadNeeded.settingType = VOLCSettingTypePreload;
        
        // engine report log
        VOLCGlobalConfigModel *engineLog = [[VOLCGlobalConfigModel alloc] init];
        engineLog.title = NSLocalizedString(@"Setting_Engine_ReportLog", nil);
        engineLog.isSwitchOn = globalConfig.isEngineReportLog;
        engineLog.settingType = VOLCSettingTypeEngineReportLog;
        
        // mdl report log
        VOLCGlobalConfigModel *mdlLog = [[VOLCGlobalConfigModel alloc] init];
        mdlLog.title = NSLocalizedString(@"Setting_MDL_ReportLog", nil);
        mdlLog.isSwitchOn = globalConfig.isMDLReportLog;
        mdlLog.settingType = VOLCSettingTypeMDLReportLog;
        
        // copy device id
        VOLCGlobalConfigModel *deviceId = [[VOLCGlobalConfigModel alloc] init];
        deviceId.title = NSLocalizedString(@"Setting_Device_Id", nil);
        deviceId.deviceId = [[BDAutoTrack sharedTrack] rangersDeviceID] ?: @"null";
        deviceId.settingType = VOLCSettingTypeCopyDeviceId;
        
        // section 1
        NSArray *sectionSource = @[hardDecode, h265Config, preloadNeeded, engineLog, mdlLog];
        
        // section 2
        NSArray *sectionSource2 = @[deviceId];
        
        _datasource = @[sectionSource, sectionSource2];
    }
    return _datasource;
}

@end
