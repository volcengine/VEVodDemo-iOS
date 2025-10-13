//
//  VEPlayerResolutionView.h
//  VEPlayerKit
//
//  Created by zys on 2025/10/21.
//

#import <UIKit/UIKit.h>
#import "VEPlayerContext.h"
#import "VEVideoPlayback.h"

NS_ASSUME_NONNULL_BEGIN

@interface VEPlayerResolutionView : UIView

@property (nonatomic, weak) VEPlayerContext *context;

- (instancetype)initWithResolutionSet:(NSArray<NSDictionary<NSString *, NSString *> *> *)resolutionSet CurResolution:(NSString *)curResolution;

@end

NS_ASSUME_NONNULL_END
