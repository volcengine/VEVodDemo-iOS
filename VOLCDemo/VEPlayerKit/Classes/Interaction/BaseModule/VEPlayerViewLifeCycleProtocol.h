//
//  VEPlayerViewLifeCycleProtocol.h
//  VEPlayerKit
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol VEPlayerViewLifeCycleProtocol <NSObject>

- (void)viewDidLoad;

- (void)controlViewTemplateDidUpdate;

@end

NS_ASSUME_NONNULL_END
