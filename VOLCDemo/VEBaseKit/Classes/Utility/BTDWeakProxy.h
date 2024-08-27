//
//  BTDWeakProxy.h
//  Pods
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
 
@interface BTDWeakProxy : NSProxy

@property (nonatomic, weak, readonly, nullable) id target;

+ (instancetype)proxyWithTarget:(id)target;

@end

NS_ASSUME_NONNULL_END
