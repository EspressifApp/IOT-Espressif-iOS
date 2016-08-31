//
//  esp_csocket.c
//  MeshProxy
//
//  Created by 白 桦 on 4/7/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#include "esp_csocket.h"
#include <stdio.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <sys/ioctl.h>
#include <assert.h>
#include <unistd.h>
#include <string.h>
#include <time.h>
#include <sys/timeb.h>

/**
 * set socket read timeout
 *
 * @param sckfd socket fd
 * @param soTimeout socket read timeout in milliseconds
 * @return 0 means suc or -1 means fail
 */
int esp_socket_setopt_rcv_timeout(int sckfd, int soTimeout)
{
    assert(sckfd>0);
    struct timeval timeout;
    timeout.tv_sec = soTimeout/1000;
    timeout.tv_usec = soTimeout%1000*1000;
    return setsockopt(sckfd, SOL_SOCKET, SO_RCVTIMEO, (char *)&timeout, sizeof(struct timeval));
}

/**
 * get how many data have been received already
 *
 * @param sckfd socket fd
 * @return how many data have been received already
 */
int esp_socket_getopt_rcv_buffer(int sckfd)
{
    assert(sckfd>0);
    int optval;
    unsigned int optlen = sizeof(int);
    int result = getsockopt(sckfd, SOL_SOCKET, SO_NREAD, &optval, &optlen);
    return result==0 ? optval : 0;
}

/**
 * wait data received until timeout
 *
 * @param sckfd socket fd
 * @param timeout timeout in milliseconds
 * @return how many data received or 0 when timeout
 */
int esp_socket_wait_available(int sckfd, int timeout)
{
    struct timeval timeoutval;
    fd_set set;
    timeoutval.tv_sec = timeout/1000;
    timeoutval.tv_usec = timeout%1000*1000;
    FD_ZERO(&set);
    FD_SET(sckfd, &set);
    if (select(sckfd + 1, &set, NULL, NULL, &timeoutval) > 0) {
        return esp_socket_getopt_rcv_buffer(sckfd);
    }
    else {
        return 0;
    }
}


/**
 * build new socket
 *
 * @return new socket's fd or -1(if fail)
 */
int esp_tsocket_create()
{
    int socket_fd = socket(AF_INET, SOCK_STREAM, 0);
    return socket_fd;
}

/**
 * close socket
 *
 * @param sckfd socket fd
 * @return 0 means suc or -1 means fail
 */
int esp_socket_close(int sckfd)
{
    return sckfd > 0 ? close(sckfd) : 0;
}

/**
 * connect to remote by specific connTimeout
 *
 * @param sckfd socket fd
 * @param remoteAddr remote inetAddress in char* format
 * @param remotePort remote port
 * @param connTimeout connection timeout in milliseconds
 * @return 0 means suc or -1 means fail
 */
int esp_tsocket_connect(int sckfd, const char* remoteAddr,const int remotePort, const int connTimeout)
{
    assert(sckfd>0);
    int ret = -1;
    int error = -1;
    int len = sizeof(int);
    int ioctl_ret = -1;
    fd_set set;
    // set dest address
    struct sockaddr_in dest_addr;
    dest_addr.sin_family = AF_INET;
    dest_addr.sin_port = htons(remotePort);
    dest_addr.sin_addr.s_addr = inet_addr(remoteAddr);
    bzero(&dest_addr.sin_zero, sizeof(dest_addr.sin_zero));
    // set nonblock mode
    unsigned long ul = 1;
    ioctl_ret = ioctl(sckfd, FIONBIO, &ul);
    if (ioctl_ret==-1) {
        esp_socket_close(sckfd);
        ret = -1;
        perror("esp_csocket esp_tsocket_connect() set nonblock mode fail");
        return ret;
    }
    // connect by nonblock mode
    if (connect(sckfd, (struct sockaddr *)&dest_addr, sizeof(struct sockaddr))==-1) {
        struct timeval timeout;
        timeout.tv_sec = connTimeout/1000;
        timeout.tv_usec = connTimeout%1000*1000;
        FD_ZERO(&set);
        FD_SET(sckfd, &set);
        // select until timeout
        if (select(sckfd + 1, NULL, &set, NULL, &timeout) > 0) {
            getsockopt(sckfd, SOL_SOCKET, SO_ERROR, &error, (socklen_t *)&len);
            if (error == 0) {
                ret = 0;
            } else {
                ret = -1;
            }
        }
    } else {
        ret = 0;
    }
    if (!ret) {
        // set block mode
        ul = 0;
        ioctl(sckfd, FIONBIO, &ul);
        if (ioctl_ret==-1) {
            esp_socket_close(sckfd);
            ret = -1;
            perror("esp_csocket esp_tsocket_connect() set block mode fail");
            return ret;
        }
    } else {
        perror("esp_csocket esp_tsocket_connect() timeout");
        esp_socket_close(sckfd);
    }
    return ret;
}

/**
 * send message
 *
 * @param sckfd socket fd
 * @param msg mssage in char* format to be sent
 * @return 0 means suc or -1 means fail
 */
int esp_tsocket_send(int sckfd, const char* msg, int len)
{
    assert(sckfd>0);
    long bytesSentToTal = 0;
    long bytesSentOnce;
    while (bytesSentToTal < len) {
        bytesSentOnce = send(sckfd, msg+bytesSentToTal, len-bytesSentToTal, 0);
        if (bytesSentOnce > 0) {
            if (bytesSentToTal > 0) {
                perror("esp_csocket WARNING esp_tsocket_send() send more than once");
            }
            bytesSentToTal += bytesSentOnce;
        } else {
            perror("esp_csocket esp_tsocket_send() send fail");
            return -1;
        }
    }
    return 0;
}

/**
 * receive message
 * 
 * @param sckfd socket fd
 * @param buffer char* buffer to receive message
 * @param len how many data to be read
 * @return 0 means suc or -1 means fail
 */
int esp_socket_recv(int sckfd, char* buffer, int len)
{
    assert(sckfd>0);
    long bytesRecvTotal = 0;
    long bytesRecvOnce;
    while (bytesRecvTotal < len) {
        bytesRecvOnce = recv(sckfd, buffer+bytesRecvTotal, len-bytesRecvTotal, 0);
        if (bytesRecvOnce > 0) {
            if (bytesRecvTotal > 0) {
                perror("esp_csocket WARNING esp_socket_recv() recv more than once");
            }
            bytesRecvTotal += bytesRecvOnce;
        }
        else {
            perror("esp_csocket esp_socket_recv() recv fail");
            return -1;
        }
    }
    if (bytesRecvTotal != len) {
        perror("esp_csocket WARNING esp_socket_recv() recv more bytes");
        return -1;
    }
    return 0;
}

/**
 * get socket local IPv4 addr
 *
 * @param sckfd socket fd
 * @return socket local IPv4 addr or -1 when fail
 */
unsigned int esp_socket_getsockname_local_addr4(int sckfd)
{
    assert(sckfd>0);
    struct sockaddr_in local_addr;
    socklen_t len = sizeof(local_addr);
    if (getsockname(sckfd, (struct sockaddr *)&local_addr, &len)==0) {
        return local_addr.sin_addr.s_addr;
    } else {
        return -1;
    }
}

/**
 * get socket local port
 *
 * @param sckfd socket fd
 * @return socket local port or -1 when fail
 */
int esp_socket_getsockname_local_port(int sckfd)
{
    assert(sckfd>0);
    struct sockaddr_in local_addr;
    socklen_t len = sizeof(local_addr);
    if(getsockname(sckfd, (struct sockaddr *)&local_addr, &len)==0){
        return ntohs(local_addr.sin_port);
    } else {
        return -1;
    }
}

/**
 * bind local port to be listened
 *
 * @param sckfd socket fd
 * @param localPort local port to be listened
 * @return 0 means suc or -1 means fail
 */
int esp_socket_bind(int sckfd, int localPort)
{
    assert(sckfd>0);
    struct sockaddr_in local_addr;
    local_addr.sin_family = AF_INET;
    local_addr.sin_port = htons(localPort);
    local_addr.sin_addr.s_addr = INADDR_ANY;
    bzero(&local_addr.sin_zero, sizeof(local_addr.sin_zero));
    int result = bind(sckfd, (struct sockaddr *)&local_addr, sizeof(struct sockaddr));
    return result;
}

/**
 * listen
 *
 * @param sckfd socket fd
 * @param backlog how many client can the server hold before accept
 * @return 0 means suc or -1 means fail
 */
int esp_tsocket_listen(int sckfd, int backlog)
{
    assert(sckfd>0);
    return listen(sckfd, backlog);
}

/**
 * accept new socket
 *
 * @param sckfd server socket fd
 * @return accepted client socket fd
 */
int esp_tsocket_accept(int sckfd)
{
    assert(sckfd>0);
    struct sockaddr_in remote_addr;
    socklen_t sin_size = sizeof(remote_addr);
    return accept(sckfd, (struct sockaddr *)&remote_addr, &sin_size);
}

/**
 * build new udp socket
 *
 * @return new udp socket's fd or -1(if fail)
 */
int esp_usocket_create()
{
    int udpsocket_fd = socket(AF_INET, SOCK_DGRAM, 0);
    return udpsocket_fd;
}

/**
 * set udp socket broadcast
 *
 * @udpsckfd udp socket fd
 * @opt 1 means set or 0 means clear
 * @return 0 means suc or -1 means fail
 */
int esp_usocket_setopt_broadcast(int udpsckfd, int opt)
{
    assert(udpsckfd>0);
    assert(opt==1||opt==0);
    return setsockopt(udpsckfd, SOL_SOCKET, SO_BROADCAST, (char *)&opt, sizeof(opt));
}

/**
 * send message to udp socket
 *
 * @udpsckfd udp socket fd
 * @param msg mssage in char* format to be sent
 * @param len length of message
 * @param remoteAddr remote inetAddress in char* format
 * @param remotePort remote port
 * @return 0 means suc or -1 means fail
 */
int esp_usocket_sendto(int udpsckfd, const char* msg, int len, const char* remoteAddr,const int remotePort)
{
    assert(udpsckfd>0);
    struct sockaddr_in remote_addr;
    remote_addr.sin_family = AF_INET;
    remote_addr.sin_addr.s_addr = inet_addr(remoteAddr);
    remote_addr.sin_port = htons(remotePort);
    socklen_t addr_len = sizeof(remote_addr);
    long bytesSentToTal = 0;
    long bytesSentOnce;
    while (bytesSentToTal < len) {
        bytesSentOnce = sendto(udpsckfd, msg+bytesSentToTal, len-bytesSentToTal, 0, (struct sockaddr*)&remote_addr, addr_len);
        if (bytesSentOnce > 0) {
            if (bytesSentToTal > 0) {
                perror("esp_csocket WARNING esp_usocket_sendto() send more than once");
            }
            bytesSentToTal += bytesSentOnce;
        } else {
            perror("esp_csocket esp_usocket_sendto() send fail");
            return -1;
        }
    }
    return 0;
}


