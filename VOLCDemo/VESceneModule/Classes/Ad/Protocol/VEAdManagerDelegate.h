//
//  VEAdEntityDelegate.h
//  VESceneModule
//
//  Created by litao.he on 2024/11/7.
//

#import <Foundation/Foundation.h>

@protocol VEAdManagerDelegate <NSObject>

- (NSString* _Nullable)getNextAdUniqueId;

- (void)prepareAdById:(NSString* _Nonnull)adId andSceneType:(NSInteger)sceneType;

- (void)showAdInRootViewController:(UIViewController * _Nonnull)viewController byId:(NSString* _Nonnull)adId andResponder:(id _Nullable)delegate;

- (void)removeAdFromRootViewController:(UIViewController * _Nonnull)viewController byId:(NSString* _Nonnull)adId;

- (void)didAppear:(NSString* _Nonnull)adId;

@end
