//
//  NSObject+BTDAdditions.h
//

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#else
#import <Foundation/Foundation.h>
#endif

NS_ASSUME_NONNULL_BEGIN

#define BTDClassSelector(CLASS, METHOD) \
((void)(NO && ((void)[CLASS METHOD], NO)), NSSelectorFromString(@(#METHOD)))

#define BTDClassMethodName(CLASS, METHOD) \
((void)(NO && ((void)[CLASS METHOD], NO)), @(#METHOD))

@interface NSObject (BTDAdditions)

/**
 Perform a selector. If a base data type is returned, it will be converted to a NSNumber. If void is returned, it will be converted to nil.

 @param sel The selector.
  @param ... The variadic parameter list. The param type should be same with the corresponding type defined in the selector. Otherwise some errors may happen.
 @return The result from the selector.
 
 Sample Code:
 
 // no variable args
 [view performSelectorWithArgs:@selector(removeFromSuperView)];
 
 // variable arg is not object
 [view performSelectorWithArgs:@selector(setCenter:), CGPointMake(0, 0)];
 
 // perform and return object
 UIImage *image = [UIImage.class performSelectorWithArgs:@selector(imageWithData:scale:), data, 2.0];
 
 // perform and return wrapped number
 NSNumber *lengthValue = [@"hello" performSelectorWithArgs:@selector(length)];
 NSUInteger length = lengthValue.unsignedIntegerValue;
 
 // perform and return wrapped struct
 NSValue *frameValue = [view performSelectorWithArgs:@selector(frame)];
 CGRect frame = frameValue.CGRectValue;
 */
- (nullable id)btd_performSelectorWithArgs:(nonnull SEL)sel, ...;

/// Similiar to `btd_performSelectorWithArgs:`, but with a CVAList to make Swift compatible
/// @param sel The selector.
/// @param args The args.
- (nullable id)btd_performSelector:(nonnull SEL)sel withArgs:(va_list)args;

/**
 Perform a selector after  some delay in current thread.

 @param sel The selector.
 @param ... The variadic parameter list. The param type should be same with the corresponding type defined in the selector. Otherwise some errors may happen.
 @param delay The delay time (second).
 Sample Code:
 
 // no variable args
 [view performSelectorWithArgs:@selector(removeFromSuperView) afterDelay:2.0];
 
 // variable arg is not object
 [view performSelectorWithArgs:@selector(setCenter:), afterDelay:0, CGPointMake(0, 0)];
 */
- (void)btd_performSelectorWithArgs:(nonnull SEL)sel afterDelay:(NSTimeInterval)delay, ...;

/// Similiar to `btd_performSelectorWithArgs:afterDelay:`, but with a CVAList to make Swift compatible
/// @param sel The selector.
/// @param delay The delay time (second).
/// @param args The args.
- (void)btd_performSelector:(nonnull SEL)sel afterDelay:(NSTimeInterval)delay withArgs:(va_list)args;

/**
 Perform a selector in the main thread. If a base data type is returned, it will be converted to a NSNumber. If void is returned or the param wait is NO, nil be returned finally.

 @param sel The selector.
 @param wait If wait is YES, the method will wait until the job in the main thread is over. Otherwise, the method will not wait.
 @param ... The variadic parameter list. The param type should be same with the corresponding type defined in the selector. Otherwise some errors may happen.
 @return The result from the selector.
 Sample Code:
 
 // no variable args
 [view performSelectorWithArgsOnMainThread:@selector(removeFromSuperView), waitUntilDone:NO];
 
 // variable arg is not object
 [view performSelectorWithArgsOnMainThread:@selector(setCenter:), waitUntilDone:NO, CGPointMake(0, 0)];
 */
- (nullable id)btd_performSelectorWithArgsOnMainThread:(nonnull SEL)sel waitUntilDone:(BOOL)wait, ...;


/// Similiar to `btd_performSelectorWithArgsOnMainThread:waitUntilDone:`, but with a CVAList to make Swift compatible
/// @param sel The selector.
/// @param wait If wait is YES, the method will wait until the job in the main thread is over. Otherwise, the method will not wait.
/// @param args The args.
- (nullable id)btd_performSelectorOnMainThread:(nonnull SEL)sel waitUntilDone:(BOOL)wait withArgs:(va_list)args;

/**
 Perform a selector in a thread. If a base data type is returned, it will be converted to a NSNumber. If void is returned or the param wait is NO, nil be returned finally.

 @param sel The selector.
 @param thread A NSThread.
 @param ... The variadic parameter list. The param type should be same with the  corresponding type defined in the selector. Otherwise some errors may happen.
 @param wait  If wait is YES, the current thread will wait until the job in the param thread is over. Otherwise, the method will not wait.
 @return The result from the selector.
 */
- (nullable id)btd_performSelectorWithArgs:(nonnull SEL)sel onThread:(nonnull NSThread *)thread waitUntilDone:(BOOL)wait, ...;

/// Similiar to `btd_performSelectorWithArgs:onThread:waitUntilDone:`, but with a CVAList to make Swift compatible
/// @param sel The selector.
/// @param thread A NSThread.
/// @param wait If wait is YES, the method will wait until the job in the main thread is over. Otherwise, the method will not wait.
/// @param args The args.
- (nullable id)btd_performSelector:(nonnull SEL)sel onThread:(nonnull NSThread *)thread waitUntilDone:(BOOL)wait withArgs:(va_list)args;

/**
  Perform a selector in the background.

 @param sel The selector.
 @param ... The variadic parameter list. The param type should be same with the  corresponding type defined in the selector. Otherwise some errors may happen.
 */
- (void)btd_performSelectorWithArgsInBackground:(nonnull SEL)sel, ...;

/// Similiar to `btd_performSelectorWithArgsInBackground:`, but with a CVAList to make Swift compatible
/// @param sel The selector.
/// @param args The args.
- (void)btd_performSelectorInBackground:(nonnull SEL)sel withArgs:(va_list)args;



/// Use all subclasses to perform the selector. Be careful to use some classes such as NSObject and UIView, that has many subclasses, to call this method. This method may cause a obvious performance cost in those conditions.
/// @param selector The selector.
+ (void)btd_performAllSubclassSelector:(SEL)selector;

/**
 Swizzle two instance selectors.

 @param origSelector The original selector.
 @param newSelector The new selector.
 @return Return YES if selectors were swizzled successfully.
 */
+ (BOOL)btd_swizzleInstanceMethod:(nonnull SEL)origSelector with:(nonnull SEL)newSelector;

/**
 Swizzle two class selectors.

 @param origSelector The original selector.
 @param newSelector The new selector.
 @return Return YES if selectors were swizzled successfully.
 */
+ (BOOL)btd_swizzleClassMethod:(nonnull SEL)origSelector with:(nonnull SEL)newSelector;

/**
 Swizzle two instance selectors. The method is thread-safe.

 @param origSelector The original selector.
 @param newSelector The new selector.
 @return Return YES if selectors were swizzled successfully.
 */
+ (BOOL)btd_safeSwizzleInstanceMethod:(nonnull SEL)origSelector with:(nonnull SEL)newSelector;

/**
 Swizzle two class selectors. The method is thread-safe.

 @param origSelector The original selector.
 @param newSelector The new selector.
 @return Return YES if selectors were swizzled successfully.
 */
+ (BOOL)btd_safeSwizzleClassMethod:(nonnull SEL)origSelector with:(nonnull SEL)newSelector;

/**
 Return the class name.
 */
- (nonnull NSString *)btd_className;
+ (nonnull NSString *)btd_className;

/**
 Return a new safer object.The method will check objects in NSDictionary or NSArray and return a new NSDictionary or NSArray to make the object safer.
 @return A safer object.
 */
- (nullable id)btd_safeJsonObject;


/**
 Set the associated object.
 */

- (void)btd_attachObject:(nullable id)obj forKey:(NSString *)key;
- (nullable id)btd_getAttachedObjectForKey:(NSString *)key;

- (void)btd_attachObject:(nullable id)obj forKey:(NSString *)key isWeak:(BOOL)bWeak;
- (nullable id)btd_getAttachedObjectForKey:(NSString *)key isWeak:(BOOL)bWeak;


/**
 Execute the block for current object only once. This can avoid dummy flags and put the process logic together.
 @note Note: For example, you can use this in `UIViewController.viewDidAppear(_:)` to manage first visibility logic.
 @param block The execute block.
 */
- (void)btd_executeOnce:(dispatch_block_t)block;


@end

NS_ASSUME_NONNULL_END
