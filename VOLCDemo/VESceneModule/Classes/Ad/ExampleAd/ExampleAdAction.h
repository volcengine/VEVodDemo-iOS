//
//  ExampleAdAction.h
//  VESceneModule
//
//  Created by litao.he on 2024/11/12.
//

#import <Foundation/Foundation.h>

@interface ExampleAdAction : NSObject

@property (nonatomic, strong) NSString* action;
@property (nonatomic, strong) NSDictionary* params;

- (instancetype) initWithAction:(NSString*)action andParams:(NSDictionary*)params;

@end
