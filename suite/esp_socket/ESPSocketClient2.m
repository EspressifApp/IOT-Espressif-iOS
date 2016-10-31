//
//  ESPSocket.m
//  MeshProxy
//
//  Created by 白 桦 on 3/31/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import "ESPSocketClient2.h"
#include "esp_csocket.h"

@interface ESPSocketClient2()

@property (nonatomic, assign) BOOL _isConnected;
@property (nonatomic, assign) BOOL _isClosed;
@property (nonatomic, assign) BOOL isSoTimeoutSet;
@property (nonatomic, assign) int socket_fd;

@property (nonatomic, assign) char *socket_buffer;

@property (nonatomic, strong) NSObject *lock_write;
@property (nonatomic, strong) NSObject *lock_read;

@end

#define ESP_CONN_TIMEOUT_DEFAULT    2000
#define ESP_SOCKET_BUFFER_LENGTH    4096
#define ESP_SO_RCV_TIMEOUT_DEFAULT  4000

@implementation ESPSocketClient2

- (void)_initWithSocketFd:(int)socketFd isConnected:(BOOL)isConnected
{
    __isConnected = isConnected;
    __isClosed = NO;
    _connTimeout = ESP_CONN_TIMEOUT_DEFAULT;
    _socket_buffer = malloc(ESP_SOCKET_BUFFER_LENGTH);
    _socket_fd = socketFd;
    _isSoTimeoutSet = NO;
    _soTimeout = ESP_SO_RCV_TIMEOUT_DEFAULT;
    _lock_write = [[NSObject alloc]init];
    _lock_read = [[NSObject alloc]init];
}

/**
 * init ESPSocketClient with random socket fd
 *
 * @return ESPSocketClient
 */
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self _initWithSocketFd:-1 isConnected:NO];
    }
    return self;
}

/**
 * init ESPSocketClient with specific socket fd
 *
 * @return ESPSocketClient
 */
- (instancetype)initWithSocketFd:(int)socketFd
{
    self = [super init];
    if (self) {
        [self _initWithSocketFd:socketFd isConnected:YES];
    }
    return self;
}

- (void) setSoTimeout:(int)soTimeout
{
    @synchronized(self)
    {
        if (_soTimeout!=soTimeout || !_isSoTimeoutSet) {
            _soTimeout = soTimeout;
            if (_socket_fd != -1) {
                _isSoTimeoutSet = esp_socket_setopt_rcv_timeout(_socket_fd, soTimeout)==0;
            }
        }
    }
}

/**
 * check whether the socket is connected
 *
 * @return whether the socket is connected
 */
- (BOOL) isConnected
{
    @synchronized(self)
    {
        return __isConnected;
    }
}

/**
 * check whether the socket is closed
 *
 * @return whether the socket is closed
 */
- (BOOL) isClosed
{
    @synchronized(self)
    {
        return __isClosed;
    }
}

/**
 * check whether the socket has new data available
 *
 * @return whether the socket has new data available
 */
- (BOOL) isAvailable
{
    @synchronized(self)
    {
        int available = esp_socket_getopt_rcv_buffer(_socket_fd);
        return available > 0;
    }
}

/**
 * check how many bytes available when read
 *
 * @return how many bytes available when read
 */
- (NSUInteger) available
{
    @synchronized(self)
    {
        int available = esp_socket_getopt_rcv_buffer(_socket_fd);
        return available > 0 ? available : 0;
    }
}

/**
 * get local port
 *
 * @return local port
 */
- (int) localPort
{
    @synchronized(self) {
        return esp_socket_getsockname_local_port(_socket_fd);
    }
}

/**
 * get local IPv4 addr
 *
 * @return local IPv4 addr
 */
- (NSString *) localInetAddr4
{
    unsigned int ipv4;
    @synchronized(self) {
        ipv4 = esp_socket_getsockname_local_addr4(_socket_fd);
    }
    if (ipv4==-1) {
        return nil;
    } else {
        NSMutableString *mstr = [[NSMutableString alloc]init];
        for (int i=0; i<4; i++) {
            if (i!=0) {
                [mstr appendString:@"."];
            }
            int value = ipv4&0xff;
            [mstr appendFormat:@"%d",value];
            ipv4>>=8;
        }
        return mstr;
    }
}

/**
 * read data from the socket
 *
 * @return data from the socket in NSData format or nil if fail
 */
- (NSData *) readData
{
    @synchronized(_lock_read)
    {
        NSUInteger nBytes = esp_socket_wait_available(_socket_fd,_soTimeout);
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
    @synchronized(_lock_read)
    {
        if (nBytes > ESP_SOCKET_BUFFER_LENGTH) {
            NSLog(@"ESPSocketClient readData() nBytes = %lu is too large",(unsigned long)nBytes);
            return nil;
        }
        if (!_isSoTimeoutSet) {
            [self setSoTimeout:_soTimeout];
        }
        int result = esp_socket_recv(_socket_fd, _socket_buffer, (int)nBytes);
        if (result!=0) {
            NSLog(@"ESPSocketClient readData() fail, result is %d",result);
            return nil;
        }
        else {
            return [NSData dataWithBytes:_socket_buffer length:nBytes];
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
    @synchronized(_lock_read)
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
    @synchronized(_lock_read)
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
 * connect to remote by ip inetAddress
 *
 * @param remoteAddr remote ip inetAddress
 * @param port remote port
 * @return whether the socket connect to remoteAddr suc
 */
- (BOOL) connect:(NSString *)remoteAddr Port:(int)port
{
    @synchronized(self)
    {
        if (_socket_fd > 0) {
            [self close];
        }
        _socket_fd = esp_tsocket_create();
        if (_socket_fd < 0) {
            NSLog(@"ESPSocketClient connect() fail for socket_fd is %d < 0", _socket_fd);
            [self close];
            return NO;
        }
        const char* _remoteAddr = [remoteAddr UTF8String];
        int result = esp_tsocket_connect(_socket_fd, _remoteAddr, port, _connTimeout);
        if (esp_socket_setopt_rcv_timeout(_socket_fd, _soTimeout)!=0) {
            NSLog(@"ESPSocketClient esp_socket_opt_rcv_timeout fail");
            [self close];
            return NO;
        }
        __isConnected = result == 0;
        return __isConnected;
    }
}

/**
 * write NSString to the socket
 *
 * @param dataStr the data String to be sent
 * @param offset offset to be sent
 * @param nStr number of String to be sent
 * @return whehter the data String to be sent suc
 */
- (BOOL) writeStr:(NSString *)dataStr Offset:(NSUInteger)offset NStr:(NSUInteger)nStr
{
    @synchronized(_lock_write)
    {
        NSData *data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
        return [self writeData:data Offset:offset NBytes:nStr];
    }
}

/**
 * write NSString to the socket
 *
 * @param dataStr the data String to be sent
 * @return whether the data String to be sent suc
 */
- (BOOL) writeStr:(NSString *)dataStr
{
    @synchronized(_lock_write)
    {
        NSData *data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
        return [self writeData:data];
    }
}

/**
 * write data to the socket
 *
 * @param data the data to be sent
 * @param offset offset to be sent
 * @param nBytes number of bytes to be sent
 * @return whether the data is sent suc
 */
- (BOOL) writeData:(NSData *)data Offset:(NSUInteger)offset NBytes:(NSUInteger)nBytes
{
    @synchronized(_lock_write)
    {
        long result = esp_tsocket_send(_socket_fd, [data bytes], (int)nBytes);
        return result==0;

    }
}

/**
 * write data to the socket
 *
 * @param data the data to be sent
 * @return whether the data is sent suc
 *
 */
- (BOOL) writeData:(NSData *)data
{
    @synchronized(_lock_write)
    {
        return [self writeData:data Offset:0 NBytes:[data length]];
    }
}

/**
 * close ESPSocketClient
 *
 */
- (void) close
{
    @synchronized(_lock_write)
    {
        if (!__isClosed) {
            // set close state
            __isClosed = YES;
            __isConnected = NO;
            // close socket
            esp_socket_close(_socket_fd);
        }
    }
}

- (void) dealloc
{
    [self close];
}

@end
