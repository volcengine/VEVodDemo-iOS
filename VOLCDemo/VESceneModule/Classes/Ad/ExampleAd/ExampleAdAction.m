//
//  ExampleAdAction.m
//  VESceneModule
//
//  Created by litao.he on 2024/11/12.
//

#import "ExampleAdAction.h"

@interface ExampleAdAction()

@end

@implementation ExampleAdAction

- (instancetype) initWithAction:(NSString*)action andParams:(NSDictionary*)params {
    self = [super init];
    if (self) {
        self.action = action;
        self.params = [params copy];
    }
    return self;
}

@end
