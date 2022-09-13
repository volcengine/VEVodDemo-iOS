//
//  VEInterfaceProtocol.h
//  Pods
//
//  Created by real on 2021/9/10.
//

/**
 * This file helps you to give a scene detail elements.
 * The protocol 'VEInterfaceElementDataSource' describes all the elements of the scene you would create.
 */
@protocol VEInterfaceElementDescription;

@protocol VEInterfaceElementDataSource <NSObject>
// Return all the elements you want, which you will fill into the scene would be create.
- (NSArray<id<VEInterfaceElementDescription>> *)customizedElements;

@end
