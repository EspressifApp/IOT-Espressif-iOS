//
//  ESPMeshSocket.h
//  MeshProxy
//
//  Created by 白 桦 on 4/13/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESPProxyTask.h"

@interface ESPMeshSocket : NSObject

/**
 * init ESPMeshSocket with InetAddress
 *
 * @param inetAddr target InetAddress
 */
- (instancetype) initWithInetAddr:(NSString *) inetAddr;

/**
 * get local inet address
 *
 * @return local inet address
 */
- (NSString *) getInetAddress;

/**
 * get the refresh proxy task list which hasn't been sent
 *
 * @return the refresh proxy task(ESPProxyTask) array which hasn't been sent
 */
- (NSArray *) getRefreshProxyTaskArray;

/**
 * offer the new proxy task
 *
 * @param proxyTask the new proxy task
 */
- (void) offer: (ESPProxyTask *) proxyTask;

/**
 * close the EspMeshSocket half, don't accept more new request
 */
- (void) halfClose;

/**
 * close the EspMeshSocket
 */
- (void) close;

/**
 * check whether the EspSocket is expired
 *
 * @return whether the EspSocket is expired
 */
- (BOOL) isExpired;

/**
 * check the proxy tasks' states and proceed them
 */
- (void) checkProxyTaskStateAndProc;

/**
 * get whether the EspMeshSocket is connected to remote device
 *
 * @return whether the EspMeshSocket is connected to remote device
 */
- (BOOL) isConnected;

/**
 * get whether the EspMeshSocket is closed
 *
 * @return whether the EspMeshSocket is closed
 */
- (BOOL) isClosed;

@end
