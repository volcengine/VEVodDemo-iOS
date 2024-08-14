//
//  VEVideoPlayerController+DisRecordScreen.h
//  VEPlayerKit
//
//  Created by zyw on 2024/4/18.
//

#import "VEVideoPlayerController.h"

NS_ASSUME_NONNULL_BEGIN

@interface VEVideoPlayerController (DIsRecordScreen)

@property (nonatomic, strong, nullable) UIView *disRecondScreenView;

- (void)registerScreenCapturedDidChangeNotification;

- (void)showRecordScreenView;

- (void)removeecordScreenView;

@end

NS_ASSUME_NONNULL_END
