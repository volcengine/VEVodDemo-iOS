//
//  VEPlayerContextItemHandler.m
//  VEPlayerKit
//

#import "VEPlayerContextItemHandler.h"
#import "BTDMacros.h"

@interface VEPlayerContextItemHandler ()

@property(nonatomic, copy, readwrite) NSArray<NSString *> *keys;

@property(nonatomic, copy) VEPlayerContextHandler handler;

@property(nonatomic, weak) id observer;

@property(nonatomic, assign) BOOL hasBindObserver;

@end

@implementation VEPlayerContextItemHandler

- (instancetype)initWithObserver:(id)observer keys:(NSArray<NSString *> *)keys handler:(VEPlayerContextHandler)handler {
    if (self = [super init]) {
        self.observer = observer;
        self.keys = keys;
        self.handler = handler;
        self.hasBindObserver = (nil != observer);
    }
    return self;
}

- (void)executeHandlerWithKey:(NSString *)key andValue:(id)value {
    if (BTD_isEmptyString(key)) {
        return;
    }
    if ((self.hasBindObserver && nil == self.observer) || nil == self.handler) {
        self.handler = nil;
        return;
    }
    !self.handler ?: self.handler(value, key);
}

@end
