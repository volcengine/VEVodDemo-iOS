//
//  VEPlayerContext.h
//  VEPlayerKit
//

#import <Foundation/Foundation.h>
#import "VEPlayerContextInterface.h"
#import "VEPlayerContextDIInterface.h"
#import <TTSDKFramework/TTSDKFramework.h>

NS_ASSUME_NONNULL_BEGIN

#define VEPlayerContextDIBind(OBJECT, PROTOCOL, CONTEXT) ve_player_di_bind(OBJECT, @protocol(PROTOCOL), (VEPlayerContext *)CONTEXT);

#define VEPlayerContextDIUnBind(PROTOCOL, CONTEXT) ve_player_di_unbind(@protocol(PROTOCOL), (VEPlayerContext *)CONTEXT);

#define VEPlayerContextDILink(PROPERTY, PROTOCOL, CONTEXT) - (id<PROTOCOL>)PROPERTY { \
    if (!_##PROPERTY) { \
        _##PROPERTY = ve_playerLink_get_property(@protocol(PROTOCOL), (VEPlayerContext *)CONTEXT); \
    }\
    return _##PROPERTY;\
}

#define VEPlayerObserveKey(key,handler) VEPlayerContextObserveKey(self.context,key,handler)
#define VEPlayerObserveKeys(keys,handler) VEPlayerContextObserveKeys(self.context,keys,handler)
#define VEPlayerContextObserveKey(context,key,handler) VEPlayerObserveKeyFunction(context,key,self,handler)
#define VEPlayerContextObserveKeys(context,keys,handler) VEPlayerObserveKeysFunction(context,keys,self,handler)

/**
 * player context, after adding the listener through 'addKey', 
 * if the user sends a new object for this key through post, then notify each listening handler to receive the change.
 **/
@interface VEPlayerContext : NSObject

/// whether to store the Object carried by the event when sending the event, the default is YES.
@property(nonatomic, assign) BOOL enableStorageCache;

@end

@interface VEPlayerContext (Handler) <VEPlayerContextHandler>

@end

@interface VEPlayerContext (HandlerAdditions) <VEPlayerContextHandlerAdditions>

@end

@interface VEPlayerContext (DIService) <TTPlayerContextDIService>

@end

inline void ve_player_di_bind(NSObject *prop, Protocol *p, VEPlayerContext *context);
inline void ve_player_di_unbind(Protocol *p, VEPlayerContext *context);
inline id ve_playerLink_get_property(Protocol *p, VEPlayerContext *context);

inline id VEPlayerObserveKeyFunction(VEPlayerContext *context, NSString *key, NSObject *observer, VEPlayerContextHandler handler);
inline id VEPlayerObserveKeysFunction(VEPlayerContext *context, NSArray<NSString *> *keys, NSObject *observer, VEPlayerContextHandler handler);

NS_ASSUME_NONNULL_END
