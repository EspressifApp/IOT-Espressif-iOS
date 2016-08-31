//
//  esp_csocket.h
//  MeshProxy
//
//  Created by 白 桦 on 4/7/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#ifndef esp_csocket_h
#define esp_csocket_h

/**
 * esp_csocket.h and esp_csocket.c are used to encapsulate espressif's BSD socket in C language
 * esp_socket_xxx means the api is used by tcp socket and udp socket altoggether
 * esp_tsocket_xxx means the api is uaed only by tcp socket
 * esp_usocket_xxx means the api is used only by udp socket
 */

/**
 * set socket read timeout
 *
 * @param sckfd socket fd
 * @param soTimeout socket read timeout in milliseconds
 * @return 0 means suc or -1 means fail
 */
int esp_socket_setopt_rcv_timeout(int sckfd, int soTimeout);

/**
 * get how many data have been received already
 *
 * @param sckfd socket fd
 * @return how many data have been received already
 */
int esp_socket_getopt_rcv_buffer(int sckfd);

/**
 * build new socket
 *
 * @return new socket's fd or -1(if fail)
 */
int esp_tsocket_create();

/**
 * close socket
 *
 * @param sckfd socket fd
 * @return 0 means suc or -1 means fail
 */
int esp_socket_close(int sckfd);

/**
 * connect to remote by specific connTimeout
 *
 * @param sckfd socket fd
 * @param remoteAddr remote inetAddress in char* format
 * @param remotePort remote port
 * @param connTimeout connection timeout in milliseconds
 * @return 0 means suc or -1 means fail
 */
int esp_tsocket_connect(int sckfd, const char* remoteAddr,const int remotePort, const int connTimeout);

/**
 * send message
 *
 * @param sckfd socket fd
 * @param msg mssage in char* format to be sent
 * @param len length of message
 * @return 0 means suc or -1 means fail
 */
int esp_tsocket_send(int sckfd, const char* msg, int len);

/**
 * receive message
 *
 * @param sckfd socket fd
 * @param buffer char* buffer to receive message
 * @param len how many data to be read
 * @return 0 means suc or -1 means fail
 */
int esp_socket_recv(int sckfd, char* buffer, int len);

/**
 * wait data received until timeout
 *
 * @param sckfd socket fd
 * @param timeout timeout in milliseconds
 * @return how many data received or 0 when timeout
 */
int esp_socket_wait_available(int sckfd, int timeout);

/**
 * get socket local IPv4 addr
 *
 * @param sckfd socket fd
 * @return socket local IPv4 addr or -1 when fail
 */
unsigned int esp_socket_getsockname_local_addr4(int sckfd);

/**
 * get socket local port
 *
 * @param sckfd socket fd
 * @return socket local port or -1 when fail
 */
int esp_socket_getsockname_local_port(int sckfd);

/**
 * bind local port to be listened
 *
 * @param sckfd socket fd
 * @param localPort local port to be listened
 * @return 0 means suc or -1 means fail
 */
int esp_socket_bind(int sckfd, int localPort);

/**
 * listen
 *
 * @param sckfd socket fd
 * @param backlog how many client can the server hold before accept
 * @return 0 means suc or -1 means fail
 */
int esp_tsocket_listen(int sckfd, int backlog);

/**
 * accept new socket
 *
 * @param sckfd server socket fd
 * @return accepted client socket fd
 */
int esp_tsocket_accept(int sckfd);

/**
 * build new udp socket
 *
 * @return new udp socket's fd or -1(if fail)
 */
int esp_usocket_create();

/**
 * set udp socket broadcast
 *
 * @udpsckfd udp socket fd
 * @opt 1 means set or 0 means clear
 */
int esp_usocket_setopt_broadcast(int udpsckfd, int opt);

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
int esp_usocket_sendto(int udpsckfd, const char* msg, int len, const char* remoteAddr,const int remotePort);
#endif /* esp_csocket_h */
