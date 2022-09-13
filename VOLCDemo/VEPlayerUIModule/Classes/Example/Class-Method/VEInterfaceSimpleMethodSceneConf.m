//
//  VEInterfaceSimpleMethodSceneConf.m
//  VEPlayerUIModule
//
//  Created by real on 2021/12/29.
//

#import "VEInterfaceSimpleMethodSceneConf.h"
#import "VEInterfacePlayElement.h"
#import "VEInterfaceProgressElement.h"

@implementation VEInterfaceSimpleMethodSceneConf

- (NSArray<id<VEInterfaceElementDescription>> *)customizedElements {
    return @[
        [VEInterfacePlayElement playButton],
        [VEInterfacePlayElement playGesture], 
        [VEInterfaceProgressElement progressView],
    ];
}

@end
