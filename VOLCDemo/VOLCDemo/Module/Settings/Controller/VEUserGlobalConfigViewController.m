//
//  VEUserGlobalConfigViewController.m
//  VOLCDemo
//
//  Created by wangzhiyong on 2021/5/31.
//  Copyright © 2021 ByteDance. All rights reserved.
//

#import "VEUserGlobalConfigViewController.h"
#import "VEGlobalConfigSwitchViewCell.h"
#import "VEGlobalConfigModel.h"
#import "VEUserGlobalConfiguration.h"
#import "VEGlobalConfigDeviceIdViewCell.h"
#import <RangersAppLog.h>
#import <TTSDK/TTVideoEngine+Preload.h>
#import "VESmallVideoViewController.h"

NSString *const kSettingSwitchViewCellIdentifier = @"kSettingSwitchViewCellIdentifie";
NSString *const kSettingDeviceIdViewCellIdentifier = @"kSettingDeviceIdViewCellIdentifier";

@interface VEUserGlobalConfigViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *footerView;
@property (nonatomic, assign) VESenceType sence;
@property (nonatomic, copy) NSArray<NSArray <VEGlobalConfigModel *>*> *datasource;

@end

@implementation VEUserGlobalConfigViewController

- (instancetype)initWithSence:(VESenceType)sence {
    self = [super init];
    if (self) {
        self.sence = sence;
    }
    return self;
}

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
    self.title = NSLocalizedString(@"Setting_Title_Strategy", nil);;
    
    [self.view addSubview:self.footerView];
    [self.footerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.equalTo(self.view);
        make.height.mas_equalTo(80);
    }];
    
    [self.view addSubview:self.tableView];
    [self.tableView registerClass:[VEGlobalConfigSwitchViewCell class] forCellReuseIdentifier:kSettingSwitchViewCellIdentifier];
    [self.tableView registerClass:[VEGlobalConfigDeviceIdViewCell class] forCellReuseIdentifier:kSettingDeviceIdViewCellIdentifier];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.bottom.equalTo(self.footerView.mas_top);
    }];
}

#pragma mark - Private

- (NSString *)_getTableCellIdentifier:(nonnull NSIndexPath *)indexPath {
    VEGlobalConfigModel *hardDecode = [[self.datasource objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    NSString *identifier = kSettingSwitchViewCellIdentifier;
    if (hardDecode.settingType == VESettingTypeCopyDeviceId) {
        identifier = kSettingDeviceIdViewCellIdentifier;
    }
    return identifier;
}

- (void)_goSencePage {
    if (self.sence == VESenceType_SmallVideo) {
        VESmallVideoViewController *smallVideoController = [[VESmallVideoViewController alloc] init];
        [self.navigationController pushViewController:smallVideoController animated:YES];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSMutableArray *array = [NSMutableArray arrayWithArray:[self.navigationController viewControllers]];
            for (UIViewController *controller in array) {
                if ([controller isKindOfClass:[VEUserGlobalConfigViewController class]]) {
                    [array removeObject:controller];
                    [self.navigationController setViewControllers:array];
                    break;
                }
            }
            
        });
    }
}

#pragma mark - UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40.0;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return NSLocalizedString(@"Setting_Title_Strategy", nil);
    } else if (section == 1) {
        return NSLocalizedString(@"Setting_Title_Common", nil);
    }
    return nil;
}

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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[self _getTableCellIdentifier:indexPath] forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    VEGlobalConfigModel *model = [[self.datasource objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    if ([cell isKindOfClass:[VEGlobalConfigSwitchViewCell class]]) {
        if (indexPath.section < self.datasource.count && indexPath.row < self.datasource[indexPath.section].count) {
            VEGlobalConfigSwitchViewCell *targetCell = (VEGlobalConfigSwitchViewCell *)cell;
            targetCell.titleLabel.text = model.title;
            [targetCell.switcher setOn:model.isSwitchOn];
        }
    } else if ([cell isKindOfClass:[VEGlobalConfigDeviceIdViewCell class]]) {
        if (indexPath.section < self.datasource.count && indexPath.row < self.datasource[indexPath.section].count) {
            VEGlobalConfigDeviceIdViewCell *targetCell = (VEGlobalConfigDeviceIdViewCell *)cell;
            targetCell.titleLabel.text = model.title;
            targetCell.deviceIdLabel.text = model.deviceId;;
        }
    }
    return cell;
}


#pragma mark - tableview delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    VEGlobalConfigModel *model = self.datasource[indexPath.section][indexPath.row];
    CGFloat height = 50;
    if (model.settingType == VESettingTypeCopyDeviceId) {
        height = 88;
    }
    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section < self.datasource.count && indexPath.row < self.datasource[indexPath.section].count) {
        VEGlobalConfigModel *model = self.datasource[indexPath.section][indexPath.row];
        model.isSwitchOn = !model.isSwitchOn;

        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        if ([cell isKindOfClass:[VEGlobalConfigSwitchViewCell class]]) {
            [((VEGlobalConfigSwitchViewCell *)cell).switcher setOn:model.isSwitchOn];
            VEUserGlobalConfiguration *globalConfigs = [VEUserGlobalConfiguration sharedInstance];
            switch (model.settingType) {
                case VESettingTypeHardDecode:
                    [globalConfigs setSwitch:model.isSwitchOn forType:UserGlobalConfigHardDecode];
                    break;
                case VESettingTypeH265:
                    [globalConfigs setSwitch:model.isSwitchOn forType:UserGlobalConfigH265];
                    break;
                case VESettingTypePreloadStrategy:
                    [globalConfigs setSwitch:model.isSwitchOn forType:UserGlobalConfigPreloadStrategy];
                    break;
                case VESettingTypePreRenderStrategy:
                    [globalConfigs setSwitch:model.isSwitchOn forType:UserGlobalConfigPreRenderStrategy];
                    break;
                default:
                    break;
            }
            [globalConfigs serializeData];
        } else if ([cell isKindOfClass:[VEGlobalConfigDeviceIdViewCell class]]) {
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
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _tableView;
}

- (UIView *)footerView {
    if (!_footerView) {
        _footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 80)];
        _footerView.backgroundColor = [UIColor blueColor];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(0, 0, SCREEN_WIDTH, 60);
        [button setTitle:@"Start Play" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(_goSencePage) forControlEvents:UIControlEventTouchUpInside];
        [_footerView addSubview:button];
    }
    return _footerView;
}

- (NSArray<NSArray<VEGlobalConfigModel *> *> *)datasource {
    if (!_datasource) {
        VEUserGlobalConfiguration *globalConfig = [VEUserGlobalConfiguration sharedInstance];
        
        VEGlobalConfigModel *preloadStrategy = [[VEGlobalConfigModel alloc] init];
        preloadStrategy.title = NSLocalizedString(@"Setting_Strategy_Preload", nil);
        preloadStrategy.isSwitchOn = globalConfig.preloadStrategyEnabled;
        preloadStrategy.settingType = VESettingTypePreloadStrategy;
        
        VEGlobalConfigModel *preRenderStrategy = [[VEGlobalConfigModel alloc] init];
        preRenderStrategy.title = NSLocalizedString(@"Setting_Strategy_PreRender", nil);
        preRenderStrategy.isSwitchOn = globalConfig.preRenderStrategyEnabled;
        preRenderStrategy.settingType = VESettingTypePreRenderStrategy;
        
        // hard decode
        VEGlobalConfigModel *hardDecode = [[VEGlobalConfigModel alloc] init];
        hardDecode.title = NSLocalizedString(@"Setting_Hard_Decode", nil);
        hardDecode.isSwitchOn = globalConfig.isHardDecodeOn;
        hardDecode.settingType = VESettingTypeHardDecode;
        
        // H265
        VEGlobalConfigModel *h265Config = [[VEGlobalConfigModel alloc] init];
        h265Config.title = NSLocalizedString(@"Setting_H265", nil);
        h265Config.isSwitchOn = globalConfig.isH265Enabled;
        h265Config.settingType = VESettingTypeH265;
        
        // copy device id
        VEGlobalConfigModel *deviceId = [[VEGlobalConfigModel alloc] init];
        deviceId.title = NSLocalizedString(@"Setting_Device_Id", nil);
        deviceId.deviceId = [[BDAutoTrack trackWithAppID:@"229234"] rangersDeviceID] ?: @"null";
        deviceId.settingType = VESettingTypeCopyDeviceId;
        
        // section 1
        NSArray *sectionSource = nil;
        if (self.sence == VESenceType_SmallVideo) {
            sectionSource = @[preloadStrategy, preRenderStrategy];
        }

        // section 2
        NSArray *sectionSource2 = nil;
        if (self.sence == VESenceType_SmallVideo) {
            sectionSource2 = @[hardDecode, h265Config, deviceId];
        }
        
        _datasource = @[sectionSource, sectionSource2];
    }
    return _datasource;
}

@end
