//
//  ExampleAd.m
//  VESceneModule
//
//  Created by litao.he on 2024/11/7.
//

#import "ExampleAdManager.h"
#import "VEAdActionResponderDelegate.h"
#import "VEAdManagerDelegate.h"
#import <Masonry/Masonry.h>
#import "VEVideoModel.h"
#import "ExampleAdViewController.h"
#import "ExampleAdProvider.h"

static NSInteger AdPreloadThreshold = 8;
@interface ExampleAdManager () <VEAdManagerDelegate>

@property (nonatomic, strong) NSDictionary* config;
@property (nonatomic, strong) NSMutableDictionary* adIndexes;
@property (nonatomic, assign) NSInteger nextModelIndex;
@property (nonatomic, strong) NSMutableDictionary* adVCs;

@property (nonatomic, strong) NSMutableArray<VEVideoModel *> *adModels;

@end

@implementation ExampleAdManager

- (instancetype)initWithConfig:(NSDictionary*)config; {
    self = [super init];
    if (self) {
        _config = [config copy];
        _adIndexes = [NSMutableDictionary dictionary];
        _adVCs = [NSMutableDictionary dictionary];
        _nextModelIndex = 0;
        NSMutableArray<VEVideoModel *> * adModels = [[ExampleAdProvider sharedInstance] getAdModels];
        if (adModels) {
            self.adModels = [adModels mutableCopy];
        } else {
            self.adModels = [NSMutableArray array];
        }
    }
    return self;
}

#pragma mark - VEAdEntityDelegate

- (NSString* _Nullable)getNextAdUniqueId {
    if (self.adModels.count - self.nextModelIndex <= AdPreloadThreshold) {
        [[ExampleAdProvider sharedInstance] getAdModels:YES completion:^(NSMutableArray<VEVideoModel *> * _Nonnull adModels) {
            if (adModels) {
                self.adModels = [adModels mutableCopy];
            }
        }];
    }

    if (self.adModels.count == 0) {
        return nil;
    }

    NSString* adId = [NSString stringWithFormat:@"%lu", (unsigned long)self.nextModelIndex];
    NSNumber* numIndex = [self.adIndexes objectForKey:adId];
    if (!numIndex) {
        [self.adIndexes setObject:@(self.nextModelIndex) forKey:adId];
    }

    if (self.nextModelIndex == [self.adModels count] - 1) {
        self.nextModelIndex = 0;
    } else {
        self.nextModelIndex += 1;
    }
    return adId;
}

- (void)prepareAdById:(NSString* _Nonnull)adId andSceneType:(NSInteger)sceneType {
    UIViewController* vc = [self.adVCs objectForKey:adId];
    if (!vc) {
        NSNumber* numIndex = [self.adIndexes objectForKey:adId];
        if (!numIndex) {
            return;
        }

        ExampleAdViewController* adVC = [[ExampleAdViewController alloc] init];
        if (!adVC) {
            return;
        }

        [adVC reloadData:[self.adModels objectAtIndex:numIndex.integerValue] forAdId:adId andSceneType:sceneType];
        [self.adVCs setObject:adVC forKey:adId];
    }
}

- (void)showAdInRootViewController:(UIViewController * _Nonnull)viewController byId:(NSString* _Nonnull)adId andResponder:(id _Nullable)delegate {
    UIViewController* vc = [self.adVCs objectForKey:adId];
    if (!vc) {
        return;
    }

    ExampleAdViewController* adVC = (ExampleAdViewController*)vc;
    adVC.delegate = delegate;
    [viewController addChildViewController:adVC];
    [viewController.view addSubview:adVC.view];

    [adVC.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.bottom.equalTo(viewController.view);
    }];

    [adVC didMoveToParentViewController:viewController];
}

- (void)removeAdFromRootViewController:(UIViewController * _Nonnull)viewController byId:(NSString* _Nonnull)adId {
    UIViewController* vc = [self.adVCs objectForKey:adId];
    if (!vc) {
        return;
    }

    [vc beginAppearanceTransition:NO animated:NO];
    [vc willMoveToParentViewController:nil];
    [vc.view removeFromSuperview];
    [vc removeFromParentViewController];
    [vc endAppearanceTransition];
}

- (void)didAppear:(NSString* _Nonnull)adId {
    UIViewController* vc = [self.adVCs objectForKey:adId];
    if (!vc) {
        return;
    }

    ExampleAdViewController* adVC = (ExampleAdViewController*)vc;
    [adVC play];
}

@end
