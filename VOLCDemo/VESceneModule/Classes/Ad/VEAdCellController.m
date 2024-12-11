//
//  VEAdsCellController.m
//  VESceneModule
//
//  Created by litao.he on 2024/11/6.
//

#import "VEAdCellController.h"
#import "VEAdManagerDelegate.h"

@interface VEAdCellController()

@property (nonatomic, strong, nonnull, readwrite) VEAdInfoModel* adInfoModel;

@end

@implementation VEAdCellController

@synthesize reuseIdentifier;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if (self.adDelegate && [self.adDelegate respondsToSelector:@selector(showAdInRootViewController:byId:andResponder:)]) {
        [self.adDelegate showAdInRootViewController:self byId:self.adInfoModel.uniqueId andResponder:self.responderDelegate];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.adDelegate && [self.adDelegate respondsToSelector:@selector(didAppear:)]) {
        [self.adDelegate didAppear:self.adInfoModel.uniqueId];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if (self.adDelegate && [self.adDelegate respondsToSelector:@selector(removeAdFromRootViewController:byId:)]) {
        [self.adDelegate removeAdFromRootViewController:self byId:self.adInfoModel.uniqueId];
    }
}

-(void)loadAd:(VEAdInfoModel* _Nonnull)adInfoModel {
    self.adInfoModel = adInfoModel;
    if (self.adDelegate && [self.adDelegate respondsToSelector:@selector(prepareAdById:andSceneType:)]) {
        [self.adDelegate prepareAdById:self.adInfoModel.uniqueId andSceneType:self.hostSceneType];
    }
}
@end
