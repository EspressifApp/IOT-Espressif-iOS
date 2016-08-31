//
//  ESPUDPSocketServer.m
//  MeshProxy
//
//  Created by 白 桦 on 4/8/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import "ESPUDPSocketServer2.h"
#include "esp_csocket.h"

@interface ESPUDPSocketServer2()

@property (nonatomic, assign) BOOL _isClosed;
@property (nonatomic, assign) int udp_socket_fd;
@property (nonatomic, assign) NSUInteger localPort;

@property (nonatomic, assign) char *udp_socket_buffer;
@property (nonatomic, assign) BOOL isSoTimeoutSet;

@end

#define ESP_UDP_SOCKET_BUFFER_LENGTH    1024
#define ESP_SO_RCV_TIMEOUT_DEFAULT      2000

@implementation ESPUDPSocketServer2

/**
 * init ESPUDPSocketServer with random local port
 *
 * @return ESPUDPSocketServer or nil
 */
- (instancetype)init
{
    // 0 means random unused port
    return [self initWithPort:0];
}

/**
 * init ESPUDPSocketServer with local port
 *
 * @param port local port
 * @return ESPUDPSocketServer or nil
 */
- (instancetype)initWithPort:(NSUInteger)port
{
    self = [super init];
    if (self) {
        __isClosed = NO;
        _localPort = port;
        _soTimeout = ESP_SO_RCV_TIMEOUT_DEFAULT;
        _udp_socket_fd = esp_usocket_create();
        if (_udp_socket_fd < 0) {
            perror("ESPUDPSocketServer init esp_socket() fail");
            return nil;
        }
        if (esp_socket_bind(_udp_socket_fd, (int)port) != 0) {
            perror("ESPUDPSocketServer init esp_socket_bind() fail");
            return nil;
        }
        // it's unnecessary to setopt BROADCAST for UDPSocketServer don't need to send any message
//        if (esp_usocket_setopt_broadcast(_udp_socket_fd, 1) != 0) {
//            perror("ESPUDPSocketServer init esp_usocket_setopt_broadcast() fail");
//            return nil;
//        }
        _udp_socket_buffer = malloc(ESP_UDP_SOCKET_BUFFER_LENGTH);
    }
    return self;
}

- (void) setSoTimeout:(int)soTimeout
{
    @synchronized(self)
    {
        if (_soTimeout!=soTimeout || !_isSoTimeoutSet) {
            _soTimeout = soTimeout;
            if (_udp_socket_fd != -1) {
                _isSoTimeoutSet = esp_socket_setopt_rcv_timeout(_udp_socket_fd, soTimeout)==0;
            }
        }
    }
}

/**
 * get ESPUDPSocketServer local port
 *
 * @return local port or -1 when closed
 */
- (NSUInteger) getLocalPort
{
    @synchronized(self)
    {
        if (__isClosed) {
            return -1;
        }
        if (_localPort == 0)
        {
            _localPort = esp_socket_getsockname_local_port(_udp_socket_fd);
        }
        return _localPort;
    }
}

/**
 * read data from the socket
 *
 * @return data from the socket in NSData format or nil if fail
 */

- (NSData *) readData
{
    @synchronized(self)
    {
        NSUInteger nBytes = esp_socket_wait_available(_udp_socket_fd, _soTimeout);
        return [self readData:nBytes];
    }
}

/**
 * read data from the socket
 *
 * @param nBytes how many bytes to be read
 * @return data from the socket in NSData format or nil if fail
 */
- (NSData *) readData:(NSUInteger)nBytes
{
    @synchronized(self)
    {
        if (nBytes > ESP_UDP_SOCKET_BUFFER_LENGTH) {
            NSLog(@"ESPUDPSocketClient readData() nBytes = %lu is too large",(unsigned long)nBytes);
            return nil;
        }
        if (!_isSoTimeoutSet) {
            [self setSoTimeout:_soTimeout];
        }
        int result = esp_socket_recv(_udp_socket_fd, _udp_socket_buffer, (int)nBytes);
        if (result!=0) {
            NSLog(@"ESPUDPSocketClient readData() fail, result is %d",result);
            return nil;
        }
        else {
            return [NSData dataWithBytes:_udp_socket_buffer length:nBytes];
        }
    }
}

/**
 * read String from the socket
 *
 * @return NSString from the socket in NSString format or nil if fail
 */
- (NSString *) readStr
{
    @synchronized(self)
    {
        NSData *data = [self readData];
        if (data==nil) {
            return nil;
        } else {
            return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        }
    }
}

/**
 * read String from the socket
 *
 * @param nBytes how many bytes to be read
 * @return NSString from the socket in NSString format or nil if fail
 */
- (NSString *) readStr:(NSUInteger)nBytes
{
    @synchronized(self)
    {
        NSData *data = [self readData:nBytes];
        if (data==nil) {
            return nil;
        } else {
            return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        }
    }
}

/**
 * check whether ESPUDPSocketServer is closed
 *
 * @return whether ESPUDPSocketServer is closed
 */
- (BOOL) isClosed
{
    @synchronized(self)
    {
        return __isClosed;
    }
}

/**
 * close ESPUDPSocketServer
 *
 */
- (void) close
{
    @synchronized(self)
    {
        // set close state
        __isClosed = YES;
        // close socket
        esp_socket_close(_udp_socket_fd);
    }
}

- (void) dealloc
{
    [self close];
}

@end
