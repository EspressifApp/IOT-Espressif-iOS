//
//  ESPUDPSocketServer.h
//  MeshProxy
//
//  Created by 白 桦 on 4/8/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ESPUDPSocketServer2 : NSObject
#pragma init
/**
 * init ESPUDPSocketServer with random local port
 *
 * @return ESPUDPSocketServer or nil
 */
- (id) init;
/**
 * init ESPUDPSocketServer with local port
 *
 * @param port local port
 * @return ESPUDPSocketServer or nil
 */
- (id) initWithPort: (NSUInteger) port;

/**
 *  socket read timeout in milliseconds
 */
@property (nonatomic, assign) int soTimeout;

#pragma check
/**
 * get ESPUDPSocketServer local port
 *
 * @return local port or -1 when closed
 */
- (NSUInteger) getLocalPort;
/**
 * check whether ESPUDPSocketServer is closed
 *
 * @return whether ESPUDPSocketServer is closed
 */
- (BOOL ) isClosed;

#pragma read
/**
 * read data from the socket
 *
 * @return data from the socket in NSData format or nil if fail
 */
- (NSData *) readData;
/**
 * read data from the socket
 *
 * @param nBytes how many bytes to be read
 * @return data from the socket in NSData format or nil if fail
 */
- (NSData *) readData: (NSUInteger) nBytes;
/**
 * read String from the socket
 *
 * @return NSString from the socket in NSString format or nil if fail
 */
- (NSString *) readStr;
/**
 * read String from the socket
 *
 * @param nBytes how many bytes to be read
 * @return NSString from the socket in NSString format or nil if fail
 */
- (NSString *) readStr: (NSUInteger) nBytes;

#pragma close
/**
 * close ESPUDPSocketServer
 *
 */
- (void) close;

@end
