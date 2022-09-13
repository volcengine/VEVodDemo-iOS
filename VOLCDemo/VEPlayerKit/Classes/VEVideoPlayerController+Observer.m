//
//  VEVideoPlayerController+Observer.m
//  VOLCDemo
//
//  Created by wangzhiyong on 2021/12/5.
//

#import "VEVideoPlayerController+Observer.h"
#import "VEVideoPlayerController+Tips.h"
#import <Reachability/Reachability.h>
#import <objc/runtime.h>

@implementation VEVideoPlayerController (Observer)

@dynamic needResumePlay;


#pragma mark - Observer

- (void)addObserver {
    [self removeObserver];
    [[Reachability reachabilityForInternetConnection] startNotifier];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(netStatusChanged) name:kReachabilityChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationEnterBackground) name: UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBecomeActiveNotification) name: UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willResignActiveNotification) name: UIApplicationWillResignActiveNotification object:nil];
}

- (void)removeObserver {
    [[Reachability reachabilityForInternetConnection] stopNotifier];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
}

- (void)netStatusChanged {
    dispatch_async(dispatch_get_main_queue(), ^{
        switch ([Reachability reachabilityForInternetConnection].currentReachabilityStatus) {
            case NotReachable: {
                [self.videoEngine pause];
                [self showTips:NSLocalizedString(@"tip_net_not_reachable", nil)];
            }
                break;
                
            case ReachableViaWiFi: {
                [self.videoEngine play];
                [self showTips:NSLocalizedString(@"tip_net_reachable_wifi", nil)];
            }
                break;
                
            case ReachableViaWWAN: {
                [self.videoEngine play];
                [self showTips:NSLocalizedString(@"tip_net_reachable_4g", nil)];
            }
                break;
                
            default:
                break;
        }
    });
}

- (void)applicationEnterBackground {
    if ([self isPlaying]) {
        self.needResumePlay = YES;
    }
    [self.videoEngine pause];
}

- (void)willResignActiveNotification {
    if ([self isPlaying]) {
        self.needResumePlay = YES;
    }
    [self.videoEngine pause];
}

- (void)didBecomeActiveNotification {
    if (self.needResumePlay) {
        [self.videoEngine play];
    }
    self.needResumePlay = NO;
}

#pragma mark - Setter && Getter

- (BOOL)needResumePlay {
    return [objc_getAssociatedObject(self, @selector(needResumePlay)) boolValue];
}

- (void)setNeedResumePlay:(BOOL)needResumePlay {
    objc_setAssociatedObject(self, @selector(needResumePlay), @(needResumePlay), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
