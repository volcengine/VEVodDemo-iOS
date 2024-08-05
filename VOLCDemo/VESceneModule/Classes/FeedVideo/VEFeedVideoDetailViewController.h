//
//  VEFeedVideoDetailViewController.h
//  VEPlayModule
//
//  Created by real on 2022/10/9.
//

#import "VEViewController.h"
@class VEVideoPlayerController;
@class VEVideoModel;

@protocol VEFeedVideoDetailProtocol <NSObject>
// playing player
- (VEVideoPlayerController *)currentPlayerController:(VEVideoModel *)videoModel;

@end

@interface VEFeedVideoDetailViewController : VEViewController

@property (nonatomic, strong) VEVideoModel *videoModel;

@property (nonatomic, weak) id<VEFeedVideoDetailProtocol> delegate;

@end
