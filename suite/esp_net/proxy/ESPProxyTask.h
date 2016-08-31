//
//  ESPProxyTask.h
//  MeshProxy
//
//  Created by 白 桦 on 4/14/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESPSocketClient2.h"

#define M_PROTO_NONE    0
#define M_PROTO_HTTP    1
#define M_PROTO_JSON    2
#define M_PROTO_MQTT    3

@interface ESPProxyTask : NSObject

-(instancetype) initWithHost:(NSString *)host Bssid:(NSString *)bssid RequestData:(NSData *)requestBuff Timeout:(int)timeout;

#pragma public method

+ (ESPProxyTask *) CLOSE_PROXYTASK;

/**
 * set the response buffer by other
 *
 * @param buffer the response buffer
 */
-(void) setResponseBuffer:(NSData *)buffer;

/**
 * get the response buffer set by other
 *
 * @return the response buffer set by other
 */
-(NSData *) getResponseBuffer;

/**
 * get the request from the source socket
 */
-(NSData *) getRequestData;

/**
 * get the target's timeout in seconds
 *
 * @return the target's timeout in seconds
 */
-(int) getTargetTimeout;

/**
 * get target's inetAddress(the root device's ip address)
 *
 * @return the target's inetAddress(the root device's ip address)
 */
 -(NSString *)getTargetInetAddress;

/**
 * get target's bssid(the device's bssid)
 *
 * @return the target's bssid(the device's bssid)
 */
-(NSString *) getTargetBssid;

/**
 * update the timestamp for the proxy task
 */
-(void) updateTimestamp;

/**
 * get whether the proxy task is expired
 * @return whether the proxy task is expired
 */
-(BOOL) isExpired;

/**
 * reply the response to the source socket, when the task executed finish and suc, including remove the mesh head
 * from the response
 */
-(void) replyResponse;

/**
 * close the source socket when the task encountered some exception
 */
-(void) replyClose;;

/**
 * get whether the EspProxyTask is finished
 *
 * @return whether the EspProxyTask is finished
 */
-(BOOL) isFinished;

/**
 * set the EspProxyTask finished
 */
-(void) setFinished:(BOOL)isFinished;

/**
 * set whether the request is valid
 *
 * @param isRequestValid whether the request is valid
 */
-(void) setRequestValid:(BOOL)isRequestValid;

/**
 * get whether the request is valid
 *
 * @return whether the request is valid
 */
-(BOOL) isRequestValid;

/**
 * set whether the response is valid
 *
 * @param isResponseValid whether the response is valid
 */
-(void) setResponseVaild:(BOOL)isResponseValid;

/**
 * get whether the response is valid
 *
 * @return whether the response is valid
 */
-(BOOL) isResponseValid;

/**
 * Just read response, forbid sending request
 *
 * @return
 */
-(BOOL) isReadOnlyTask;

/**
 * Whether reply response is required
 *
 * @return
 */
-(BOOL) isReplyRequired;

/**
 * Get proto type
 *
 * @return
 */
-(int) getProtoType;

/**
 * Get long socket task serial
 *
 * @return
 */
-(int) getLongSocketSerial;

/**
 * Get task timeout
 *
 * @return
 */
-(int) getTaskTimeout;

/**
 * get group bssid array
 *
 * @return group bssid array
 */
-(NSArray*) getGroupBssidArray;

/**
 * set group bssid array
 *
 * @param groupBssidArray the group bssid array
 */
-(void) setGroupBssidArray:(NSArray *)groupBssidArray;

#pragma pakcage method

-(void) setSourceSocket:(ESPSocketClient2 *)socket;

-(void) setReadOnlyTask:(BOOL)isReadOnlyTask;

-(void) setReplyRequired:(BOOL)isReplyRequired;

-(void) setProtoType:(int)protoType;

-(void) setLongSocketSerial:(int)serial;

-(void) setTaskTimeout:(int)taskTimeout;

@end
