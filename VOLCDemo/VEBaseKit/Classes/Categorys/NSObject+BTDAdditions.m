//
//  NSObject+BTDAdditions.m
//

#import "NSObject+BTDAdditions.h"
#import "BTDMacros.h"
#import <QuartzCore/CoreAnimation.h>
#import <objc/objc.h>
#import <objc/runtime.h>
#import <pthread/pthread.h>

#define INIT_INV(_last_arg_, _sel_, _return_) \
NSMethodSignature * sig = [self methodSignatureForSelector:_sel_]; \
if (!sig) { [self doesNotRecognizeSelector:sel]; return _return_; } \
NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sig]; \
if (!inv) { [self doesNotRecognizeSelector:sel]; return _return_; } \
[inv setTarget:self]; \
[inv setSelector:_sel_]; \
va_list args; \
va_start(args, _last_arg_); \
[NSObject btd_setInv:inv withSig:sig andArgs:args]; \
va_end(args);

#define INIT_INV_VALIST(_last_arg_, _sel_, _return_) \
NSMethodSignature * sig = [self methodSignatureForSelector:_sel_]; \
if (!sig) { [self doesNotRecognizeSelector:sel]; return _return_; } \
NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sig]; \
if (!inv) { [self doesNotRecognizeSelector:sel]; return _return_; } \
[inv setTarget:self]; \
[inv setSelector:_sel_]; \
[NSObject btd_setInv:inv withSig:sig andArgs:args];

// Block的结构表示，来自官方Clang文档 https://clang.llvm.org/docs/Block-ABI-Apple.html
struct Block_literal_1 {
    void *isa;
    int flags;
    int reserved;
    void (*invoke)(void *, ...);
};

@interface NSObject ()

@property(nonatomic, strong, class) NSMutableDictionary<NSString *, NSMutableArray<Class> *> *btd_subclassesCache;

@end

@implementation NSObject (BTDAdditions)

- (id)btd_performSelectorWithArgs:(SEL)sel, ...
{
    INIT_INV(sel,sel,nil);
    [inv invoke];
    return [NSObject btd_getReturnFromInv:inv withSig:sig];
}

- (id)btd_performSelector:(SEL)sel withArgs:(va_list)args
{
    INIT_INV_VALIST(sel,sel,nil);
    [inv invoke];
    return [NSObject btd_getReturnFromInv:inv withSig:sig];
}

- (void)btd_performSelectorWithArgs:(SEL)sel afterDelay:(NSTimeInterval)delay, ...
{
    INIT_INV(delay,sel, );
    [inv retainArguments];
    [inv performSelector:@selector(invoke) withObject:nil afterDelay:delay];
}

- (void)btd_performSelector:(SEL)sel afterDelay:(NSTimeInterval)delay withArgs:(va_list)args
{
    INIT_INV_VALIST(delay,sel, );
    [inv retainArguments];
    [inv performSelector:@selector(invoke) withObject:nil afterDelay:delay];
}

- (id)btd_performSelectorWithArgsOnMainThread:(SEL)sel waitUntilDone:(BOOL)wait, ...
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wvarargs"
    INIT_INV(wait,sel,nil);
#pragma clang diagnostic pop
    if (!wait) [inv retainArguments];
    [inv performSelectorOnMainThread:@selector(invoke) withObject:nil waitUntilDone:wait];
    return wait ? [NSObject btd_getReturnFromInv:inv withSig:sig] : nil;
}

- (id)btd_performSelectorOnMainThread:(SEL)sel waitUntilDone:(BOOL)wait withArgs:(va_list)args
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wvarargs"
    INIT_INV_VALIST(wait,sel,nil);
#pragma clang diagnostic pop
    if (!wait) [inv retainArguments];
    [inv performSelectorOnMainThread:@selector(invoke) withObject:nil waitUntilDone:wait];
    return wait ? [NSObject btd_getReturnFromInv:inv withSig:sig] : nil;
}

- (id)btd_performSelectorWithArgs:(SEL)sel onThread:(NSThread *)thread waitUntilDone:(BOOL)wait, ...
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wvarargs"
    INIT_INV(wait,sel,nil);
#pragma clang diagnostic pop
    if (!wait) [inv retainArguments];
    [inv performSelector:@selector(invoke) onThread:thread withObject:nil waitUntilDone:wait];
    return wait ? [NSObject btd_getReturnFromInv:inv withSig:sig] : nil;
}

- (id)btd_performSelector:(SEL)sel onThread:(NSThread *)thread waitUntilDone:(BOOL)wait withArgs:(va_list)args
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wvarargs"
    INIT_INV_VALIST(wait,sel,nil);
#pragma clang diagnostic pop
    if (!wait) [inv retainArguments];
    [inv performSelector:@selector(invoke) onThread:thread withObject:nil waitUntilDone:wait];
    return wait ? [NSObject btd_getReturnFromInv:inv withSig:sig] : nil;
}

- (void)btd_performSelectorWithArgsInBackground:(SEL)sel, ...
{
    INIT_INV(sel,sel, );
    [inv retainArguments];
    [inv performSelectorInBackground:@selector(invoke) withObject:nil];
}

- (void)btd_performSelectorInBackground:(SEL)sel withArgs:(va_list)args
{
    INIT_INV_VALIST(sel,sel, );
    [inv retainArguments];
    [inv performSelectorInBackground:@selector(invoke) withObject:nil];
}

static pthread_mutex_t _subclassesLock;

+ (NSMutableDictionary<Class,NSMutableArray<Class> *> *)btd_subclassesCache {
    static NSMutableDictionary *cache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cache = NSMutableDictionary.dictionary;
        pthread_mutex_init(&_subclassesLock, NULL);

    });
    return cache;
}


+ (NSMutableArray<Class> *)btd_getSubclasses {
    int numClasses = objc_getClassList(NULL, 0);
    Class *classes = NULL;

    classes = (__unsafe_unretained Class *)malloc(sizeof(Class) * numClasses);
    numClasses = objc_getClassList(classes, numClasses);

    NSMutableArray *result = [NSMutableArray arrayWithCapacity:500];
    for (NSInteger i = 0; i < numClasses; i++) {
        Class superClass = classes[i];
        do {
          superClass = class_getSuperclass(superClass);
        } while(superClass && superClass != self);
        if (superClass == nil) {
            continue;
        }
        [result addObject:classes[i]];
    }
    free(classes);
    return result;
}

+ (void)btd_performAllSubclassSelector:(SEL)selector {
    __auto_type className = NSStringFromClass(self);
    pthread_mutex_lock(&_subclassesLock);
    NSArray<Class> *subclasses = self.btd_subclassesCache[className].copy;
    if (!subclasses) {
        self.btd_subclassesCache[className] = [self btd_getSubclasses];
        subclasses = self.btd_subclassesCache[className].copy;
    }
    pthread_mutex_unlock(&_subclassesLock);
    [subclasses enumerateObjectsUsingBlock:^(Class  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj respondsToSelector:selector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [obj performSelector:selector];
#pragma clang diagnostic pop
        }
    }];
}

+ (id)btd_getReturnFromInv:(NSInvocation *)inv withSig:(NSMethodSignature *)sig {
    NSUInteger length = [sig methodReturnLength];
    if (length == 0) return nil;
    
    char *type = (char *)[sig methodReturnType];
    while (*type == 'r' || // const
           *type == 'n' || // in
           *type == 'N' || // inout
           *type == 'o' || // out
           *type == 'O' || // bycopy
           *type == 'R' || // byref
           *type == 'V') { // oneway
        type++; // cutoff useless prefix
    }
    
#define return_with_number(_type_) \
do { \
_type_ ret; \
[inv getReturnValue:&ret]; \
return @(ret); \
} while (0)
    
    switch (*type) {
        case 'v': return nil; // void
        case 'B': return_with_number(bool);
        case 'c': return_with_number(char);
        case 'C': return_with_number(unsigned char);
        case 's': return_with_number(short);
        case 'S': return_with_number(unsigned short);
        case 'i': return_with_number(int);
        case 'I': return_with_number(unsigned int);
        case 'l': return_with_number(int);
        case 'L': return_with_number(unsigned int);
        case 'q': return_with_number(long long);
        case 'Q': return_with_number(unsigned long long);
        case 'f': return_with_number(float);
        case 'd': return_with_number(double);
        case 'D': { // long double
            long double ret;
            [inv getReturnValue:&ret];
            return [NSNumber numberWithDouble:ret];
        };
            
        case '@': { // id
            void *tempRet;
            [inv getReturnValue:&tempRet];
            id ret = (__bridge id)tempRet;
            return ret;
        };
            
        case '#': { // Class
            Class ret = nil;
            [inv getReturnValue:&ret];
            return ret;
        };
            
        default: { // struct / union / SEL / void* / unknown
            const char *objCType = [sig methodReturnType];
            char *buf = calloc(1, length);
            if (!buf) return nil;
            [inv getReturnValue:buf];
            NSValue *value = [NSValue valueWithBytes:buf objCType:objCType];
            free(buf);
            return value;
        };
    }
#undef return_with_number
}

+ (void)btd_setInv:(NSInvocation *)inv withSig:(NSMethodSignature *)sig andArgs:(va_list)args {
    NSUInteger count = [sig numberOfArguments];
    for (int index = 2; index < count; index++) {
        char *type = (char *)[sig getArgumentTypeAtIndex:index];
        while (*type == 'r' || // const
               *type == 'n' || // in
               *type == 'N' || // inout
               *type == 'o' || // out
               *type == 'O' || // bycopy
               *type == 'R' || // byref
               *type == 'V') { // oneway
            type++; // cutoff useless prefix
        }
        
        BOOL unsupportedType = NO;
        switch (*type) {
            case 'v': // 1: void
            case 'B': // 1: bool
            case 'c': // 1: char / BOOL
            case 'C': // 1: unsigned char
            case 's': // 2: short
            case 'S': // 2: unsigned short
            case 'i': // 4: int / NSInteger(32bit)
            case 'I': // 4: unsigned int / NSUInteger(32bit)
            case 'l': // 4: long(32bit)
            case 'L': // 4: unsigned long(32bit)
            { // 'char' and 'short' will be promoted to 'int'.
                int arg = va_arg(args, int);
                [inv setArgument:&arg atIndex:index];
            } break;
                
            case 'q': // 8: long long / long(64bit) / NSInteger(64bit)
            case 'Q': // 8: unsigned long long / unsigned long(64bit) / NSUInteger(64bit)
            {
                long long arg = va_arg(args, long long);
                [inv setArgument:&arg atIndex:index];
            } break;
                
            case 'f': // 4: float / CGFloat(32bit)
            { // 'float' will be promoted to 'double'.
                double arg = va_arg(args, double);
                float argf = arg;
                [inv setArgument:&argf atIndex:index];
            } break;
                
            case 'd': // 8: double / CGFloat(64bit)
            {
                double arg = va_arg(args, double);
                [inv setArgument:&arg atIndex:index];
            } break;
                
            case 'D': // 16: long double
            {
                long double arg = va_arg(args, long double);
                [inv setArgument:&arg atIndex:index];
            } break;
                
            case '*': // char *
            case '^': // pointer
            {
                void *arg = va_arg(args, void *);
                [inv setArgument:&arg atIndex:index];
            } break;
                
            case ':': // SEL
            {
                SEL arg = va_arg(args, SEL);
                [inv setArgument:&arg atIndex:index];
            } break;
                
            case '#': // Class
            {
                Class arg = va_arg(args, Class);
                [inv setArgument:&arg atIndex:index];
            } break;
                
            case '@': // id
            {
                id arg = va_arg(args, id);
                [inv setArgument:&arg atIndex:index];
            } break;
                
            case '{': // struct
            {
                if (strcmp(type, @encode(CGPoint)) == 0) {
                    CGPoint arg = va_arg(args, CGPoint);
                    [inv setArgument:&arg atIndex:index];
                } else if (strcmp(type, @encode(CGSize)) == 0) {
                    CGSize arg = va_arg(args, CGSize);
                    [inv setArgument:&arg atIndex:index];
                } else if (strcmp(type, @encode(CGRect)) == 0) {
                    CGRect arg = va_arg(args, CGRect);
                    [inv setArgument:&arg atIndex:index];
                } else if (strcmp(type, @encode(CGVector)) == 0) {
                    CGVector arg = va_arg(args, CGVector);
                    [inv setArgument:&arg atIndex:index];
                } else if (strcmp(type, @encode(CGAffineTransform)) == 0) {
                    CGAffineTransform arg = va_arg(args, CGAffineTransform);
                    [inv setArgument:&arg atIndex:index];
                } else if (strcmp(type, @encode(CATransform3D)) == 0) {
                    CATransform3D arg = va_arg(args, CATransform3D);
                    [inv setArgument:&arg atIndex:index];
                } else if (strcmp(type, @encode(NSRange)) == 0) {
                    NSRange arg = va_arg(args, NSRange);
                    [inv setArgument:&arg atIndex:index];
#if TARGET_OS_IPHONE
                } else if (strcmp(type, @encode(UIOffset)) == 0) {
                    UIOffset arg = va_arg(args, UIOffset);
                    [inv setArgument:&arg atIndex:index];
                } else if (strcmp(type, @encode(UIEdgeInsets)) == 0) {
                    UIEdgeInsets arg = va_arg(args, UIEdgeInsets);
                    [inv setArgument:&arg atIndex:index];
#else
                } else if (strcmp(type, @encode(NSEdgeInsets)) == 0) {
                    NSEdgeInsets arg = va_arg(args, NSEdgeInsets);
                    [inv setArgument:&arg atIndex:index];
#endif
                } else {
                    unsupportedType = YES;
                }
            } break;
                
            case '(': // union
            {
                unsupportedType = YES;
            } break;
                
            case '[': // array
            {
                unsupportedType = YES;
            } break;
                
            default: // what?!
            {
                unsupportedType = YES;
            } break;
        }
        
        if (unsupportedType) {
            // Try with some dummy type...
            
            NSUInteger size = 0;
            NSGetSizeAndAlignment(type, &size, NULL);
            
#define case_size(_size_) \
else if (size <= 4 * _size_ ) { \
struct dummy { char tmp[4 * _size_]; }; \
struct dummy arg = va_arg(args, struct dummy); \
[inv setArgument:&arg atIndex:index]; \
}
            if (size == 0) { }
            case_size( 1) case_size( 2) case_size( 3) case_size( 4)
            case_size( 5) case_size( 6) case_size( 7) case_size( 8)
            case_size( 9) case_size(10) case_size(11) case_size(12)
            case_size(13) case_size(14) case_size(15) case_size(16)
            case_size(17) case_size(18) case_size(19) case_size(20)
            case_size(21) case_size(22) case_size(23) case_size(24)
            case_size(25) case_size(26) case_size(27) case_size(28)
            case_size(29) case_size(30) case_size(31) case_size(32)
            case_size(33) case_size(34) case_size(35) case_size(36)
            case_size(37) case_size(38) case_size(39) case_size(40)
            case_size(41) case_size(42) case_size(43) case_size(44)
            case_size(45) case_size(46) case_size(47) case_size(48)
            case_size(49) case_size(50) case_size(51) case_size(52)
            case_size(53) case_size(54) case_size(55) case_size(56)
            case_size(57) case_size(58) case_size(59) case_size(60)
            case_size(61) case_size(62) case_size(63) case_size(64)
            else {
                /*
                 Larger than 256 byte?! I don't want to deal with this stuff up...
                 Ignore this argument.
                 */
                struct dummy {char tmp;};
                for (int i = 0; i < size; i++) va_arg(args, struct dummy);
                NSLog(@"performSelectorWithArgs unsupported type:%s (%lu bytes)",
                      [sig getArgumentTypeAtIndex:index],(unsigned long)size);
            }
#undef case_size
            
        }
    }
}

+ (BOOL)btd_swizzleInstanceMethod:(SEL)origSelector with:(SEL)newSelector
{
    Method originalMethod = class_getInstanceMethod(self, origSelector);
    Method swizzledMethod = class_getInstanceMethod(self, newSelector);
    if (!originalMethod || !swizzledMethod) {
        return NO;
    }
    if (class_addMethod(self,
                        origSelector,
                        method_getImplementation(swizzledMethod),
                        method_getTypeEncoding(swizzledMethod)) ) {
        class_replaceMethod(self,
                            newSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
        
    } else {
        class_replaceMethod(self,
                            newSelector,
                            class_replaceMethod(self,
                                                origSelector,
                                                method_getImplementation(swizzledMethod),
                                                method_getTypeEncoding(swizzledMethod)),
                            method_getTypeEncoding(originalMethod));
    }
    return YES;
}

+ (BOOL)btd_swizzleClassMethod:(SEL)origSelector with:(SEL)newSelector
{
    Class cls = [self class];
    Method originalMethod = class_getClassMethod(cls, origSelector);
    Method swizzledMethod = class_getClassMethod(cls, newSelector);
    if (!originalMethod || !swizzledMethod) {
        return NO;
    }
    Class metacls = objc_getMetaClass(NSStringFromClass(cls).UTF8String);
    if (class_addMethod(metacls,
                        origSelector,
                        method_getImplementation(swizzledMethod),
                        method_getTypeEncoding(swizzledMethod)) ) {
        class_replaceMethod(metacls,
                            newSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
        
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
    return YES;
}

+ (BOOL)btd_safeSwizzleInstanceMethod:(nonnull SEL)origSelector with:(nonnull SEL)newSelector {
    BOOL result = NO;
    @synchronized (self) {
        result = [self btd_swizzleInstanceMethod:origSelector with:newSelector];
    }
    return result;
}

+ (BOOL)btd_safeSwizzleClassMethod:(nonnull SEL)origSelector with:(nonnull SEL)newSelector {
    BOOL result = NO;
    @synchronized (self) {
        result = [self btd_safeSwizzleClassMethod:origSelector with:newSelector];
    }
    return result;
}

+ (NSString *)btd_className
{
    return NSStringFromClass(self);
}

- (NSString *)btd_className
{
    return [NSString stringWithUTF8String:class_getName([self class])];
}

- (id)btd_safeJsonObject
{
    return [self description];
}

#pragma mark - Associated Object

- (const void *)btd_computedKeyFromString:(NSString *)key {
    return (char *)((__bridge void*)self) + [key hash] + [key characterAtIndex:0] + [key characterAtIndex:key.length - 1];
}

- (void)btd_attachObject:(id)obj forKey:(NSString *)key {
    [self btd_attachObject:obj forKey:key isWeak:NO];
}

- (id)btd_getAttachedObjectForKey:(NSString *)key {
    return [self btd_getAttachedObjectForKey:key isWeak:NO];
}

- (void)btd_attachObject:(nullable id)obj forKey:(NSString *)key isWeak:(BOOL)bWeak {
    if (key.length <= 0) {
        return ;
    }
    if (bWeak) {
        id __weak weakObject = obj;
        id (^block)(void) = ^{ return weakObject; };
        objc_setAssociatedObject(self,
                                 [self btd_computedKeyFromString:key],
                                 block,
                                 OBJC_ASSOCIATION_COPY);
        return;
    }
    else {
        objc_setAssociatedObject(self,
                                 [self btd_computedKeyFromString:key],
                                 obj,
                                 OBJC_ASSOCIATION_RETAIN);
    }
}

- (nullable id)btd_getAttachedObjectForKey:(NSString *)key isWeak:(BOOL)bWeak {
    if (key.length <= 0) {
        return nil;
    }
    if (bWeak) {
        id (^block)(void) = objc_getAssociatedObject(self,
                                                     [self btd_computedKeyFromString:key]);
        return (block ? block() : nil);
    }
    else {
        return objc_getAssociatedObject(self,
                                        [self btd_computedKeyFromString:key]);
    }
}


#pragma mark - Execute Once

- (void)btd_executeOnce:(dispatch_block_t)block {
    if (!block) {
        NSLog(@"Executed block is Empty!");
        return;
    }
    const void *funPtr = ((__bridge struct Block_literal_1 *)block) -> invoke; // 取得执行block的函数指针，并检查是否已经执行过这个block
    if (funPtr == NULL) {
        NSLog(@"FunPtr of block is NULL!");
        return;
    }
    BOOL hasExecuted = [objc_getAssociatedObject(self, funPtr) boolValue];
    if (!hasExecuted) {
        block();
        objc_setAssociatedObject(self, funPtr, @(YES), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

@end
