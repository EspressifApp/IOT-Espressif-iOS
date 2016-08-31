//
//  ESPSocketServer.h
//  MeshProxy
//
//  Created by 白 桦 on 4/6/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESPSocketClient2.h"

/**
 * ESPSocketServer is a bridge between BSDSocket and Objective-C class.
 *
 * It supports accept() and close()
 * It will bind() and listen() when ESPSocketServer is init, when fail nil will be gotten
 * It will be closed automatically in dealloc() callback, so it will be closed in sometime forever.
 *
 */
@interface ESPSocketServer2 : NSObject

#pragma init
/**
 * init ESPSocketServer with random local port
 *
 * @return ESPSocketServer or nil
 */
- (id) init;
/**
 * init ESPSocketServer with local port
 * 
 * @param port local port
 * @return ESPSocketServer or nil
 */
- (id) initWithPort: (NSUInteger) port;

#pragma check
/**
 * get ESPSocketServer local port
 *
 * @return local port or -1 when closed
 */
- (NSUInteger) getLocalPort;
/**
 * check whether ESPSocketServer is closed
 *
 * @return whether ESPSocketServer is closed
 */
- (BOOL ) isClosed;

#pragma accept
/**
 * accept a ESPSocketClient from remote
 *
 * @return ESPSocketClient(it won't return except ESPSocketServer is closed)
 */
- (ESPSocketClient2 *) accept;

#pragma close
/**
 * close ESPSocketServer
 *
 */
- (void) close;
@end
