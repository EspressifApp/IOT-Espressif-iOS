//
//  ESPSocket.h
//  MeshProxy
//
//  Created by 白 桦 on 3/31/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * ESPSocketClient is a bridge between BSDSocket and Objective-C class.
 *
 * It supports connect() write() read() close() and etc.
 * When connect() fail, it will close automatically.
 * When write() fail or read() fail, you should close it by yourself.
 * It will be closed automatically in dealloc() callback, so it will be closed in sometime forever.
 *
 */
@interface ESPSocketClient2 : NSObject
/**
 * init ESPSocketClient with random socket fd
 *
 * @return ESPSocketClient
 */
- (id) init;

/**
 * init ESPSocketClient with specific socket fd
 *
 * @return ESPSocketClient
 */
- (id) initWithSocketFd: (int) socketFd;

/**
 *  socket read timeout in milliseconds
 */
@property (nonatomic, assign) int soTimeout;
/**
 *  socket connect timeout in milliseconds
 */
@property (nonatomic, assign) int connTimeout;

#pragma check
/**
 * check whether the socket is connected
 *
 * @return whether the socket is connected
 */
- (BOOL) isConnected;

/**
 * check whether the socket is closed
 *
 * @return whether the socket is closed
 */
- (BOOL) isClosed;

/**
 * check whether the socket has new data available
 *
 * @return whether the socket has new data available
 */
- (BOOL) isAvailable;

/**
 * check how many bytes available when read
 *
 * @return how many bytes available when read
 */
- (NSUInteger) available;

/**
 * get local port
 *
 * @return local port
 */
- (int) localPort;

/**
 * get local IPv4 addr
 *
 * @return local IPv4 addr
 */
- (NSString *) localInetAddr4;

#pragma connect
/**
 * connect to remote by ip inetAddress
 *
 * @param remoteAddr remote ip inetAddress
 * @param port remote port
 * @return whether the socket connect to remoteAddr suc
 */
- (BOOL) connect: (NSString *) remoteAddr Port:(int) port;

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
 * write data to the socket
 * 
 * @param data the data to be sent
 * @param offset offset to be sent
 * @param nBytes number of bytes to be sent
 * @return whether the data is sent suc
 */
- (BOOL) writeData: (NSData *)data Offset:(NSUInteger) offset NBytes:(NSUInteger) nBytes;
/**
 * write data to the socket
 *
 * @param data the data to be sent
 * @return whether the data is sent suc
 *
 */
- (BOOL) writeData: (NSData *)data;
/**
 * write NSString to the socket
 *
 * @param dataStr the data String to be sent
 * @param offset offset to be sent
 * @param nStr number of String to be sent
 * @return whehter the data String to be sent suc
 */
- (BOOL) writeStr: (NSString *)dataStr Offset:(NSUInteger) offset NStr:(NSUInteger) nStr;
/**
 * write NSString to the socket
 *
 * @param dataStr the data String to be sent
 * @return whether the data String to be sent suc
 */
- (BOOL) writeStr: (NSString *)dataStr;

#pragma close
/**
 * close ESPSocketClient
 *
 */
- (void) close;

@end
