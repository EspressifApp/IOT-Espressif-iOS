//
//  ESPSocketServer.m
//  MeshProxy
//
//  Created by 白 桦 on 4/6/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import "ESPSocketServer2.h"
#include "esp_csocket.h"

@interface ESPSocketServer2()

@property (nonatomic, assign) BOOL _isClosed;
@property (nonatomic, assign) int socket_fd;
@property (nonatomic, assign) NSUInteger localPort;

@end

#define ESP_SERVER_BACKLOG  20

/**
 * init ESPSocketServer with random local port
 *
 * @return ESPSocketServer or nil
 */
@implementation ESPSocketServer2

- (instancetype)init
{
    // 0 means random unused port
    return [self initWithPort:0];
}

/**
 * init ESPSocketServer with local port
 *
 * @param port local port
 * @return ESPSocketServer or nil
 */
- (instancetype)initWithPort:(NSUInteger)port
{
    self = [super init];
    if (self) {
        __isClosed = NO;
        _localPort = port;
        _socket_fd = esp_tsocket_create();
        if (_socket_fd < 0) {
            perror("ESPSocketServer init esp_socket() fail");
            return nil;
        }
        if (esp_socket_bind(_socket_fd, (int)port)!=0) {
            perror("ESPSocketServer init esp_socket_bind() fail");
            return nil;
        }
        if (esp_tsocket_listen(_socket_fd, ESP_SERVER_BACKLOG)) {
            perror("ESPSocketServer init esp_tsocket_listen() fail");
            return nil;
        }
    }
    return self;
}

/**
 * get ESPSocketServer local port
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
        if (_localPort==0)
        {
            _localPort = esp_socket_getsockname_local_port(_socket_fd);
        }
        return _localPort;
    }
}

/**
 * close ESPSocketServer
 *
 */
- (void) close
{
    @synchronized(self)
    {
        if (!__isClosed) {
            __isClosed = YES;
            esp_socket_close(_socket_fd);
        }
    }
}

- (void) dealloc
{
    [self close];
}

/**
 * check whether ESPSocketServer is closed
 *
 * @return whether ESPSocketServer is closed
 */
- (BOOL) isClosed
{
    @synchronized(self)
    {
        return __isClosed;
    }
}

/**
 * accept a ESPSocketClient from remote
 *
 * @return ESPSocketClient(it won't return except ESPSocketServer is closed)
 */
- (ESPSocketClient2 *) accept
{
    if (__isClosed) {
        return nil;
    }
    int remoteFd = esp_tsocket_accept(_socket_fd);
    if (__isClosed) {
        return nil;
    } else if(remoteFd < 0) {
        perror("ESPSocketServer accept fail");
        return nil;
    } else {
        return [[ESPSocketClient2 alloc]initWithSocketFd:remoteFd];
    }
 }

@end
