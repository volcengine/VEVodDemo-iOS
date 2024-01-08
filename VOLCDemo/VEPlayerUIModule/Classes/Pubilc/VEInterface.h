//
//  VEInterface.h
//  VEPlayerUIModule
//
//  Created by real on 2021/9/18.
//

/**
 * This Class gives you a uncomplicated way to build a play control view.
 * To achieve this goal，you should provide a instance which implement protocol 'VEPlayCoreAbilityProtocol' and 'VEInterfaceElementDataSource'.
 * The protocol 'VEPlayCoreAbilityProtocol' describes the play ability of the player you choose.
 * The protocol 'VEInterfaceElementDataSource' describes the play control UI's detail you want.
 * However, this is a universal tool, so we have to ask for the screen rotation and page back method of your global logic by the protocol 'VEInterfaceDelegate'.
 */

@protocol VEPlayCoreAbilityProtocol;
@protocol VEInterfaceElementDataSource;

@protocol VEInterfaceDelegate <NSObject>

- (void)interfaceCallScreenRotation:(UIView *)interface;

- (void)interfaceCallPageBack:(UIView *)interface;

- (void)interfaceShouldEnableSlide:(BOOL)enable;

@end

@interface VEInterface : UIView

/**
 * This method is the only entry to initialize the VEInterface
 * @param core is the class which implement 'VEPlayCoreAbilityProtocol', described the ability of player you choose.
 * @param scene is a config class which implement 'VEInterfaceElementDataSource' to describes UI's detail you want.
 */
- (instancetype)initWithPlayerCore:(id<VEPlayCoreAbilityProtocol>)core scene:(id<VEInterfaceElementDataSource>)scene;
// If you want change the player core of VEInterface, this method will work.
- (void)reloadCore:(id<VEPlayCoreAbilityProtocol>)core;

@property (nonatomic, weak) id<VEInterfaceDelegate> delegate;

- (void)destory;

@end
