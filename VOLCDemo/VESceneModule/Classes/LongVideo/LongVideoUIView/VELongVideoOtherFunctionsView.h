//
//  VELongVideoOtherFunctionsView.h
//  VESceneModule
//
//  Created by zys on 2025/10/15.
//

#import <UIKit/UIKit.h>
#import "VEPlayerContext.h"
#import "VEVideoPlayback.h"

NS_ASSUME_NONNULL_BEGIN

@interface VELongVideoOtherFunctionsView : UIView

@property (nonatomic, weak) VEPlayerContext *context;

@property (nonatomic, weak) id<VEVideoPlayback> playerInterface;

@end

NS_ASSUME_NONNULL_END
