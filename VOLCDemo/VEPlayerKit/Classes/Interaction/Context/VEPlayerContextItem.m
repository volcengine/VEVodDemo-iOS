//
//  VEPlayerContextItem.m
//  VEPlayerKit
//

#import "VEPlayerContextItem.h"

@interface VEPlayerContextItem ()

@property (nonatomic, strong) NSMutableArray<VEPlayerContextItemHandler *> *handlerArray;

@end

@implementation VEPlayerContextItem

- (void)addHandler:(VEPlayerContextItemHandler *)handler {
    if (!handler) {
        return;
    }
    [self.handlerArray addObject:handler];
}

- (void)removeHandler:(VEPlayerContextItemHandler *)handler {
    if (!handler || !_handlerArray) {
        return;
    }
    [self.handlerArray removeObject:handler];
    if (self.handlerArray.count <= 0) {
        [self _closeHandlerArray];
    }
}

- (void)removeAllHandler {
    [self.handlerArray removeAllObjects];
    [self _closeHandlerArray];
}

- (void)notify:(id)value {
    if (!_handlerArray) {
        return;
    }
    for (VEPlayerContextItemHandler *itemHandler in self.handlerArray.copy) {
        if (itemHandler.handler) {
            [itemHandler executeHandlerWithKey:self.key andValue:value];
        } else {
            [self.handlerArray removeObject:itemHandler];
        }
    }
}

#pragma mark - Setter & Getter Method
- (NSMutableArray *)handlerArray {
    if (!_handlerArray) {
        _handlerArray = [NSMutableArray array];
    }
    return _handlerArray;
}

#pragma mark - Private Method
- (void)_closeHandlerArray {
    _handlerArray = nil;
}

@end
