//
//  VESmallVideoPlaybackPanelViewController.h
//  VOLCDemo
//
//  Created by wangzhiyong on 2021/12/3.
//

#import <UIKit/UIKit.h>
#import "VEVideoPlaybackPanel.h"
#import "VEVideoPlaybackPanel.h"

NS_ASSUME_NONNULL_BEGIN

@interface VESmallVideoPlaybackPanelViewController : UIViewController <VEVideoPlaybackPanelPotocol>

- (instancetype)init UNAVAILABLE_ATTRIBUTE;
+ (instancetype)new UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithVideoPlayer:(id<VEVideoPlayback>)videoPlayer;

@end

NS_ASSUME_NONNULL_END
