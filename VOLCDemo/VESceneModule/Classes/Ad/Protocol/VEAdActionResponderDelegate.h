//
//  VEAdActionResponderDelegate.h
//  VESceneModule
//
//  Created by litao.he on 2024/11/8.
//

#import <Foundation/Foundation.h>

@protocol VEAdActionResponderDelegate <NSObject>

- (void)adDidDisplay:(NSString*)adId;

- (void)adPlayFinished:(NSString*)adId;

@end
