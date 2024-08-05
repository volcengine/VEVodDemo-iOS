//
//  VEPlayerActionView.h
//  VEPlayerKit
//


#import <UIKit/UIKit.h>
#import "VEPlayerControlView.h"
#import "VEPlayerControlViewDefine.h"

NS_ASSUME_NONNULL_BEGIN

@interface VEPlayerActionView : UIView

- (void)addPlayerControlView:(VEPlayerControlView * _Nullable)controlView viewType:(VEPlayerControlViewType)viewType;

- (void)removePlayerControlView:(VEPlayerControlViewType)viewType;

- (VEPlayerControlView * _Nullable)getPlayerControlView:(VEPlayerControlViewType)viewType;

@end

NS_ASSUME_NONNULL_END
