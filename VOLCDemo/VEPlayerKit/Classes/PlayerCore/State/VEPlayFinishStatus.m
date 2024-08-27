//
//  VEPlayFinishStatus.m
//  VEPlayerKit
//

#import "VEPlayFinishStatus.h"

@implementation VEPlayFinishStatus

- (BOOL)playerFinishedSuccess {
    if (!self.error) {
        return YES;
    }
    return NO;
}

@end
