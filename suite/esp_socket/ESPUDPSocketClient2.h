//
//  ESPUDPSocketClient.h
//  MeshProxy
//
//  Created by 白 桦 on 4/7/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ESPUDPSocketClient2 : NSObject

/**
 * init ESPUDPSocketClient with random socket fd
 *
 * @return ESPUDPSocketClient
 */
- (id) init;

/**
 * init ESPUDPSocketClient with specific socket fd
 *
 * @return ESPUDPSocketClient
 */
- (id) initWithUdpSocketFd: (int) udpSocketFd;

/**
 *  socket read timeout in milliseconds
 */
@property (nonatomic, assign) int soTimeout;

#pragma check
/**
 * check whether the udp socket is closed
 *
 * @return whether the udp socket is closed
 */
- (BOOL) isClosed;

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

#pragma write
/**
 * write data to the udp socket
 *
 * @param data the data to be sent
 * @param offset offset to be sent
 * @param nBytes number of bytes to be sent
 * @param remoteAddr remote ip inetAddress
 * @param port remote port
 * @return whether the data is sent suc
 */
- (BOOL) writeData: (NSData *)data Offset:(NSUInteger) offset NBytes:(NSUInteger) nBytes ToRemoteAddr :(NSString *) remoteAddr Port:(int) port;
/**
 * write data to the udp socket
 *
 * @param data the data to be sent
 * @param remoteAddr remote ip inetAddress
 * @param port remote port
 * @return whether the data is sent suc
 *
 */
- (BOOL) writeData: (NSData *)data ToRemoteAddr :(NSString *) remoteAddr Port:(int) port;
/**
 * write NSString to the udp socket
 *
 * @param dataStr the data String to be sent
 * @param offset offset to be sent
 * @param nStr number of String to be sent
 * @param remoteAddr remote ip inetAddress
 * @param port remote port
 * @return whehter the data String to be sent suc
 */
- (BOOL) writeStr: (NSString *)dataStr Offset:(NSUInteger) offset NStr:(NSUInteger) nStr ToRemoteAddr :(NSString *) remoteAddr Port:(int) port;
/**
 * write NSString to the udp socket
 *
 * @param dataStr the data String to be sent
 * @param remoteAddr remote ip inetAddress
 * @param port remote port
 * @return whether the data String to be sent suc
 */
- (BOOL) writeStr: (NSString *)dataStr ToRemoteAddr :(NSString *) remoteAddr Port:(int) port;

#pragma close
/**
 * close ESPUDPSocketClient
 *
 */
- (void) close;

@end
