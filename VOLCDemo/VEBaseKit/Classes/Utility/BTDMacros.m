//
//  BTD_isEmptyFunctions.m
//

#import <Foundation/Foundation.h>
#import "BTDMacros.h"

BOOL BTD_isEmptyString(id param) {
    if(!param){
        return YES;
    }
    if ([param isKindOfClass:[NSString class]]){
        NSString *str = param;
        return (str.length == 0);
    }
    return YES;
}

BOOL BTD_isEmptyArray(id param) {
    if(!param){
        return YES;
    }
    if ([param isKindOfClass:[NSArray class]]){
        NSArray *array = param;
        return (array.count == 0);
    }
    return YES;
}

BOOL BTD_isEmptyDictionary(id param) {
    if(!param){
        return YES;
    }
    if ([param isKindOfClass:[NSDictionary class]]){
        NSDictionary *dict = param;
        return (dict.count == 0);
    }
    return YES;
}

BOOL BTD_isEmptySet(id param) {
    if(!param){
        return YES;
    }
    if ([param isKindOfClass:[NSSet class]]){
        NSSet *set = param;
        return (set.count == 0);
    }
    return YES;
}

bool btd_dispatch_is_main_queue(void) {
    static void *BTDCheckMainQueueKey = &BTDCheckMainQueueKey;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dispatch_queue_set_specific(dispatch_get_main_queue(), BTDCheckMainQueueKey, BTDCheckMainQueueKey, NULL);
    });
    return dispatch_get_specific(BTDCheckMainQueueKey) == BTDCheckMainQueueKey;
}

bool btd_dispatch_is_main_thread(void) {
    return [NSThread isMainThread];
}

void btd_dispatch_async_on_main_queue(void (^block)(void)) {
    if (btd_dispatch_is_main_queue()) {
        block();
    } else {
        dispatch_async(dispatch_get_main_queue(), block);
    }
}

void btd_dispatch_sync_on_main_queue(void (^block)(void)) {
    if (btd_dispatch_is_main_queue()) {
        block();
    } else {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}
