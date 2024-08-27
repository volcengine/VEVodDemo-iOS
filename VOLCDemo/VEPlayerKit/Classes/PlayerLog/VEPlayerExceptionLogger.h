//
//  VEPlayerKitLogger.h
//  VEPlayerKit
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

///抓取异常调用的堆栈信息并上报的block
typedef void(^ThreadExceptionLogBlock)(NSString *type, NSDictionary<NSString *, id> *_Nullable currentParams);

@interface VEPlayerExceptionLogger : NSObject

+ (void)setThreadExceptionLogBlock:(ThreadExceptionLogBlock)threadExceptionLogBlock;


/// 上报异常线程堆栈
/// @param exceptionType 异常类型（自定义字符串）
/// @param currentParams 自定义参数（必须能转成json）
+ (void)trackThreadExceptionLog:(NSString *)exceptionType currentParams:(NSDictionary<NSString *, id> *_Nullable)currentParams;


@end

NS_ASSUME_NONNULL_END
