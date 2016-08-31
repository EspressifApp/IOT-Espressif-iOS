//
//  ESPUDPSocketClient.m
//  MeshProxy
//
//  Created by 白 桦 on 4/7/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import "ESPUDPSocketClient2.h"
#include "esp_csocket.h"

@interface ESPUDPSocketClient2()

@property (nonatomic, assign) BOOL _isClosed;
@property (nonatomic, assign) int udp_socket_fd;

@property (nonatomic, assign) char *udp_socket_buffer;
@property (nonatomic, assign) BOOL isBroadcast;
@property (nonatomic, assign) BOOL isSoTimeoutSet;

@end

#define ESP_UDP_SOCKET_BUFFER_LENGTH    4096
#define ESP_UDP_RCV_TIMEOUT_DEFAULT     2000

@implementation ESPUDPSocketClient2

- (BOOL)_initWithUdpSocketFd:(int)udpSocketFd
{
    _udp_socket_fd = udpSocketFd > 0 ? udpSocketFd : esp_usocket_create();
    if (_udp_socket_fd < 0) {
        perror("ESPUDPSocketClient _initWithSocketFd() esp_usocket_create()");
        return NO;
    }
    __isClosed = NO;
    _udp_socket_buffer = malloc(ESP_UDP_SOCKET_BUFFER_LENGTH);
    _soTimeout = ESP_UDP_RCV_TIMEOUT_DEFAULT;
    if (esp_usocket_setopt_broadcast(_udp_socket_fd, 1) != 0) {
        perror("ESPUDPSocketClient _initWithSocketFd() esp_usocket_setopt_broadcast fail");
        return NO;
    }
    return YES;
}

/**
 * init ESPUDPSocketClient with random socket fd
 *
 * @return ESPUDPSocketClient
 */
- (instancetype)init
{
    self = [super init];
    if (self) {
        if (![self _initWithUdpSocketFd:-1]) {
            return nil;
        };
    }
    return self;
}

/**
 * init ESPUDPSocketClient with specific socket fd
 *
 * @return ESPUDPSocketClient
 */
- (id) initWithUdpSocketFd: (int) socketFd
{
    self = [super init];
    if (self) {
        if (![self _initWithUdpSocketFd:socketFd]) {
            return nil;
        };
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
 * write NSString to the udp socket
 *
 * @param dataStr the data String to be sent
 * @param offset offset to be sent
 * @param nStr number of String to be sent
 * @param remoteAddr remote ip inetAddress
 * @param port remote port
 * @return whehter the data String to be sent suc
 */
- (BOOL) writeStr: (NSString *)dataStr Offset:(NSUInteger) offset NStr:(NSUInteger) nStr ToRemoteAddr :(NSString *) remoteAddr Port:(int) port
{
    @synchronized(self)
    {
        NSData *data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
        return [self writeData:data Offset:offset NBytes:nStr ToRemoteAddr:remoteAddr Port:port];
    }
}

/**
 * write NSString to the udp socket
 *
 * @param dataStr the data String to be sent
 * @param remoteAddr remote ip inetAddress
 * @param port remote port
 * @return whether the data String to be sent suc
 */
- (BOOL) writeStr: (NSString *)dataStr ToRemoteAddr :(NSString *) remoteAddr Port:(int) port
{
    @synchronized(self)
    {
        NSData *data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
        return [self writeData:data ToRemoteAddr:remoteAddr Port:port];
    }
}

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
- (BOOL) writeData: (NSData *)data Offset:(NSUInteger) offset NBytes:(NSUInteger) nBytes ToRemoteAddr :(NSString *) remoteAddr Port:(int) port
{
    @synchronized(self)
    {
        const char* _remoteAddr = [remoteAddr UTF8String];
        int result = esp_usocket_sendto(_udp_socket_fd, [data bytes], (int)nBytes, _remoteAddr, port);
        return result == 0;
    }
    return NO;
}

/**
 * write data to the udp socket
 *
 * @param data the data to be sent
 * @param remoteAddr remote ip inetAddress
 * @param port remote port
 * @return whether the data is sent suc
 *
 */
- (BOOL) writeData: (NSData *)data ToRemoteAddr :(NSString *) remoteAddr Port:(int) port
{
    @synchronized(self)
    {
        return [self writeData:data Offset:0 NBytes:[data length] ToRemoteAddr:remoteAddr Port:port];
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
 * check whether the udp socket is closed
 *
 * @return whether the udp socket is closed
 */
- (BOOL) isClosed
{
    @synchronized(self)
    {
        return __isClosed;
    }
}

/**
 * close ESPUDPSocketClient
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