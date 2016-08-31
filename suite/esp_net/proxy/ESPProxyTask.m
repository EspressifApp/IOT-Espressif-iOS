//
//  ESPProxyTask.m
//  MeshProxy
//
//  Created by 白 桦 on 4/14/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import "ESPProxyTask.h"
#import "ESPMeshLog.h"
#import "ESPIllegalStateException.h"

#define DEBUG_ON    NO

@interface ESPProxyTask()

@property (nonatomic, strong) NSString *targetInetAddress;
@property (nonatomic, strong) NSString *targetBssid;
@property (nonatomic, assign) int targetTimeout;
@property (nonatomic, assign) NSTimeInterval timestamp;
@property (nonatomic, strong) NSData *requestBuffer;
@property (nonatomic, strong) NSData *responseBuffer;
@property (nonatomic, strong) ESPSocketClient2 *sourceSocket;
@property (nonatomic, assign) BOOL isRequestValid;
@property (nonatomic, assign) BOOL isResponseValid;
@property (nonatomic, assign) BOOL isReadOnlyTask;
@property (nonatomic, assign) BOOL isReplyRequired;
@property (nonatomic, assign) int protoType;
@property (nonatomic, assign) int longSocketSerial;
@property (nonatomic, assign) int taskTimeout;
@property (nonatomic, assign) NSArray *groupBssidArray;
@property (nonatomic, assign) BOOL isFinished;

@end

@implementation ESPProxyTask

+ (ESPProxyTask *) CLOSE_PROXYTASK
{
    static ESPProxyTask *CLOSE_PROXYTASK;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        CLOSE_PROXYTASK = [[ESPProxyTask alloc]initWithHost:nil Bssid:nil RequestData:nil Timeout:-1];
    });
    return CLOSE_PROXYTASK;
}

- (instancetype)init
{
    abort();
}

-(instancetype) initWithHost:(NSString *)host Bssid:(NSString *)bssid RequestData:(NSData *)requestBuff Timeout:(int)timeout
{
    self = [super init];
    if (self) {
        NSString *msg = [NSString stringWithFormat:@"EspProxyTaskImpl is created, meshBssid: %@",bssid];
        [ESPMeshLog error:DEBUG_ON Class:[self class] Message:msg];
        
        _isReadOnlyTask = NO;
        _isReplyRequired = YES;
        _protoType = M_PROTO_HTTP;
        _longSocketSerial = 0;
        _taskTimeout = 0;
        _groupBssidArray = nil;
        _isFinished = NO;
        
        _targetInetAddress = host;
        _targetBssid = bssid;
        _requestBuffer = requestBuff;
        _targetTimeout = timeout;
    }
    return self;
}

#pragma public method

/**
 * set the response buffer by other
 *
 * @param buffer the response buffer
 */
-(void) setResponseBuffer:(NSData *)buffer
{
    if (self==[ESPProxyTask CLOSE_PROXYTASK]) {
        NSString *msg = @"CLOSE_PROXYTASK shouldn't call setResponseBuffer()";
        [ESPMeshLog error:DEBUG_ON Class:[self class] Message:msg];
        NSString *exceptionName = @"ESPProxyTask-setResponseBuffer";
        NSString *exceptionReaseon = @"CLOSE_PROXYTASK shouldn't call setResponseBuffer()";
        NSException *e = [ESPIllegalStateException exceptionWithName:exceptionName reason:exceptionReaseon userInfo:nil];
        @throw e;
    }
    _responseBuffer = buffer;
}

/**
 * get the response buffer set by other
 *
 * @return the response buffer set by other
 */
-(NSData *) getResponseBuffer
{
    if (self==[ESPProxyTask CLOSE_PROXYTASK]) {
        NSString *msg = @"CLOSE_PROXYTASK shouldn't call getResponseBuffer()";
        [ESPMeshLog error:DEBUG_ON Class:[self class] Message:msg];
        NSString *exceptionName = @"ESPProxyTask-getResponseBuffer";
        NSString *exceptionReaseon = @"CLOSE_PROXYTASK shouldn't call getResponseBuffer()";
        NSException *e = [ESPIllegalStateException exceptionWithName:exceptionName reason:exceptionReaseon userInfo:nil];
        @throw e;
    }
    return _responseBuffer;
}

/**
 * get the request from the source socket
 */
-(NSData *) getRequestData
{
    if (self==[ESPProxyTask CLOSE_PROXYTASK]) {
        NSString *msg = @"CLOSE_PROXYTASK shouldn't call getRequestBytes()";
        [ESPMeshLog error:DEBUG_ON Class:[self class] Message:msg];
        NSString *exceptionName = @"ESPProxyTask-getRequestData";
        NSString *exceptionReaseon = @"CLOSE_PROXYTASK shouldn't call getRequestBytes()";
        NSException *e = [ESPIllegalStateException exceptionWithName:exceptionName reason:exceptionReaseon userInfo:nil];
        @throw e;
    }
    return _requestBuffer;
}

/**
 * get the target's timeout in seconds
 *
 * @return the target's timeout in seconds
 */
-(int) getTargetTimeout
{
    if (self==[ESPProxyTask CLOSE_PROXYTASK]) {
        NSString *msg = @"CLOSE_PROXYTASK shouldn't call getTargetTimeout()";
        [ESPMeshLog error:DEBUG_ON Class:[self class] Message:msg];
        NSString *exceptionName = @"ESPProxyTask-getTargetTimeout";
        NSString *exceptionReaseon = @"CLOSE_PROXYTASK shouldn't call getTargetTimeout()";
        NSException *e = [ESPIllegalStateException exceptionWithName:exceptionName reason:exceptionReaseon userInfo:nil];
        @throw e;
    }
    return _targetTimeout;
}

/**
 * get target's inetAddress(the root device's ip address)
 *
 * @return the target's inetAddress(the root device's ip address)
 */
-(NSString *)getTargetInetAddress
{
    if (self==[ESPProxyTask CLOSE_PROXYTASK]) {
        NSString *msg = @"CLOSE_PROXYTASK shouldn't call getTargetInetAddress()";
        [ESPMeshLog error:DEBUG_ON Class:[self class] Message:msg];
        NSString *exceptionName = @"ESPProxyTask-getTargetInetAddress";
        NSString *exceptionReaseon = @"CLOSE_PROXYTASK shouldn't call getTargetInetAddress()";
        NSException *e = [ESPIllegalStateException exceptionWithName:exceptionName reason:exceptionReaseon userInfo:nil];
        @throw e;
    }
    return _targetInetAddress;
}

/**
 * get target's bssid(the device's bssid)
 *
 * @return the target's bssid(the device's bssid)
 */
-(NSString *) getTargetBssid
{
    if (self==[ESPProxyTask CLOSE_PROXYTASK]) {
        NSString *msg = @"CLOSE_PROXYTASK shouldn't call getTargetBssid()";
        [ESPMeshLog error:DEBUG_ON Class:[self class] Message:msg];
        NSString *exceptionName = @"ESPProxyTask-getTargetBssid";
        NSString *exceptionReaseon = @"CLOSE_PROXYTASK shouldn't call getTargetBssid()";
        NSException *e = [ESPIllegalStateException exceptionWithName:exceptionName reason:exceptionReaseon userInfo:nil];
        @throw e;
    }
    return _targetBssid;
}

/**
 * update the timestamp for the proxy task
 */
-(void) updateTimestamp
{
    if (self==[ESPProxyTask CLOSE_PROXYTASK]) {
        NSString *msg = @"CLOSE_PROXYTASK shouldn't call updateTimestamp()";
        [ESPMeshLog error:DEBUG_ON Class:[self class] Message:msg];
        NSString *exceptionName = @"ESPProxyTask-updateTimestamp";
        NSString *exceptionReaseon = @"CLOSE_PROXYTASK shouldn't call updateTimestamp()";
        NSException *e = [ESPIllegalStateException exceptionWithName:exceptionName reason:exceptionReaseon userInfo:nil];
        @throw e;
    }
    _timestamp = [[NSDate date] timeIntervalSince1970];
}

/**
 * get whether the proxy task is expired
 * @return whether the proxy task is expired
 */
-(BOOL) isExpired
{
    if (self==[ESPProxyTask CLOSE_PROXYTASK]) {
        NSString *msg = @"CLOSE_PROXYTASK shouldn't call isExpired()";
        [ESPMeshLog error:DEBUG_ON Class:[self class] Message:msg];
        NSString *exceptionName = @"ESPProxyTask-isExpired";
        NSString *exceptionReaseon = @"CLOSE_PROXYTASK shouldn't call isExpired()";
        NSException *e = [ESPIllegalStateException exceptionWithName:exceptionName reason:exceptionReaseon userInfo:nil];
        @throw e;
    }
    NSTimeInterval consume = [[NSDate date] timeIntervalSince1970] - _timestamp;
    BOOL isExpired = consume > (_targetTimeout + _taskTimeout)/1000.0;
    return isExpired;
}

-(NSData *) getHttpHeader:(int) contentLength
{
    NSMutableString *mstr = [[NSMutableString alloc]init];
    [mstr appendFormat:@"HTTP/1.1 200 OK\r\n"];
    [mstr appendFormat:@"Content-Length: %d\r\n\r\n",contentLength];
    return [mstr dataUsingEncoding:NSUTF8StringEncoding];
}

/**
 * reply the response to the source socket, when the task executed finish and suc, including remove the mesh head
 * from the response
 */
-(void) replyResponse
{
    if (self==[ESPProxyTask CLOSE_PROXYTASK]) {
        NSString *msg = @"CLOSE_PROXYTASK shouldn't call replyResponse()";
        [ESPMeshLog error:DEBUG_ON Class:[self class] Message:msg];
        NSString *exceptionName = @"ESPProxyTask-replyResponse";
        NSString *exceptionReaseon = @"CLOSE_PROXYTASK shouldn't call replyResponse()";
        NSException *e = [ESPIllegalStateException exceptionWithName:exceptionName reason:exceptionReaseon userInfo:nil];
        @throw e;
    }
    // add fake HTTP header if response isn't HTTP
    NSMutableData *responseData = [[NSMutableData alloc]init];
    if (_protoType != M_PROTO_HTTP) {
        // return empty HTTP response if mResponseBuffer is null and replyResponse() is called
        int contentLength = _responseBuffer != nil ? (int)[_responseBuffer length] : 0;
        NSData *httpHeaderData = [self getHttpHeader:contentLength];
        [responseData appendData:httpHeaderData];
    }
    if (_responseBuffer != nil) {
        [responseData appendData:_responseBuffer];
    }
    [_sourceSocket writeData:responseData];
    [_sourceSocket close];
    _isFinished = YES;
    NSString *msg = [NSString stringWithFormat:@"EspProxyTaskImpl meshBssid: %@ replyResponse()",_targetBssid];
    [ESPMeshLog error:DEBUG_ON Class:[self class] Message:msg];
}

// for NSURLConnection will retry 3 times when close the connection directly,
// so we adopt the policy of reply close response
-(NSData *) getHttpCloseResponse
{
    NSDictionary *closeResponse = [NSDictionary dictionaryWithObject:@"!@#$%^&*()" forKey:@")(*&^%$#@!"];
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:closeResponse options:kNilOptions error:nil];
    return jsonData;
}

/**
 * close the source socket when the task encountered some exception
 */
-(void) replyClose
{
    if (self==[ESPProxyTask CLOSE_PROXYTASK]) {
        NSString *msg = @"CLOSE_PROXYTASK shouldn't call replyClose()";
        [ESPMeshLog error:DEBUG_ON Class:[self class] Message:msg];
        NSString *exceptionName = @"ESPProxyTask-replyClose";
        NSString *exceptionReaseon = @"CLOSE_PROXYTASK shouldn't call replyClose()";
        NSException *e = [ESPIllegalStateException exceptionWithName:exceptionName reason:exceptionReaseon userInfo:nil];
        @throw e;
    }
    
    NSData *httpBodyData = [self getHttpCloseResponse];
    NSMutableData *responseData = [[NSMutableData alloc]init];
    int contentLength = (int)[httpBodyData length];
    NSData *httpHeaderData = [self getHttpHeader:contentLength];
    [responseData appendData:httpHeaderData];
    [responseData appendData:httpBodyData];
    
    [_sourceSocket writeData:responseData];
    [_sourceSocket close];
    _isFinished = YES;
    NSString *msg  = [NSString stringWithFormat:@"EspProxyTaskImpl meshBssid: %@ replyClose()",_targetBssid];
    [ESPMeshLog error:DEBUG_ON Class:[self class] Message:msg];
}

/**
 * get whether the EspProxyTask is finished
 *
 * @return whether the EspProxyTask is finished
 */
-(BOOL) isFinished
{
    if (self==[ESPProxyTask CLOSE_PROXYTASK]) {
        NSString *msg = @"CLOSE_PROXYTASK shouldn't call isFinished()";
        [ESPMeshLog error:DEBUG_ON Class:[self class] Message:msg];
        NSString *exceptionName = @"ESPProxyTask-isFinished";
        NSString *exceptionReaseon = @"CLOSE_PROXYTASK shouldn't call isFinished()";
        NSException *e = [ESPIllegalStateException exceptionWithName:exceptionName reason:exceptionReaseon userInfo:nil];
        @throw e;
    }
    return _isFinished;
}

/**
 * set the EspProxyTask finished
 */
-(void) setFinished:(BOOL)isFinished
{
    if (self==[ESPProxyTask CLOSE_PROXYTASK]) {
        NSString *msg = @"CLOSE_PROXYTASK shouldn't call setFinished()";
        [ESPMeshLog error:DEBUG_ON Class:[self class] Message:msg];
        NSString *exceptionName = @"ESPProxyTask-setFinished";
        NSString *exceptionReaseon = @"CLOSE_PROXYTASK shouldn't call setFinished()";
        NSException *e = [ESPIllegalStateException exceptionWithName:exceptionName reason:exceptionReaseon userInfo:nil];
        @throw e;
    }
    _isFinished = isFinished;
}

/**
 * set whether the request is valid
 *
 * @param isRequestValid whether the request is valid
 */
-(void) setRequestValid:(BOOL)isRequestValid
{
    if (self==[ESPProxyTask CLOSE_PROXYTASK]) {
        NSString *msg = @"CLOSE_PROXYTASK shouldn't call setRequestValid()";
        [ESPMeshLog error:DEBUG_ON Class:[self class] Message:msg];
        NSString *exceptionName = @"ESPProxyTask-setRequestValid";
        NSString *exceptionReaseon = @"CLOSE_PROXYTASK shouldn't call setRequestValid()";
        NSException *e = [ESPIllegalStateException exceptionWithName:exceptionName reason:exceptionReaseon userInfo:nil];
        @throw e;
    }
    _isRequestValid = isRequestValid;
}

/**
 * get whether the request is valid
 *
 * @return whether the request is valid
 */
-(BOOL) isRequestValid
{
    if (self==[ESPProxyTask CLOSE_PROXYTASK]) {
        NSString *msg = @"CLOSE_PROXYTASK shouldn't call isRequestValid()";
        [ESPMeshLog error:DEBUG_ON Class:[self class] Message:msg];
        NSString *exceptionName = @"ESPProxyTask-isRequestValid";
        NSString *exceptionReaseon = @"CLOSE_PROXYTASK shouldn't call isRequestValid()";
        NSException *e = [ESPIllegalStateException exceptionWithName:exceptionName reason:exceptionReaseon userInfo:nil];
        @throw e;
    }
    return _isRequestValid;
}

/**
 * set whether the response is valid
 *
 * @param isResponseValid whether the response is valid
 */
-(void) setResponseVaild:(BOOL)isResponseValid
{
    if (self==[ESPProxyTask CLOSE_PROXYTASK]) {
        NSString *msg = @"CLOSE_PROXYTASK shouldn't call setResponseVaild()";
        [ESPMeshLog error:DEBUG_ON Class:[self class] Message:msg];
        NSString *exceptionName = @"ESPProxyTask-setResponseVaild";
        NSString *exceptionReaseon = @"CLOSE_PROXYTASK shouldn't call setResponseVaild()";
        NSException *e = [ESPIllegalStateException exceptionWithName:exceptionName reason:exceptionReaseon userInfo:nil];
        @throw e;
    }
    _isResponseValid = isResponseValid;
}

/**
 * get whether the response is valid
 *
 * @return whether the response is valid
 */
-(BOOL) isResponseValid
{
    if (self==[ESPProxyTask CLOSE_PROXYTASK]) {
        NSString *msg = @"CLOSE_PROXYTASK shouldn't call isResponseValid()";
        [ESPMeshLog error:DEBUG_ON Class:[self class] Message:msg];
        NSString *exceptionName = @"ESPProxyTask-isResponseValid";
        NSString *exceptionReaseon = @"CLOSE_PROXYTASK shouldn't call isResponseValid()";
        NSException *e = [ESPIllegalStateException exceptionWithName:exceptionName reason:exceptionReaseon userInfo:nil];
        @throw e;
    }
    return _isResponseValid;
}

/**
 * Just read response, forbid sending request
 *
 * @return
 */
-(BOOL) isReadOnlyTask
{
    if (self==[ESPProxyTask CLOSE_PROXYTASK]) {
        NSString *msg = @"CLOSE_PROXYTASK shouldn't call isReadOnlyTask()";
        [ESPMeshLog error:DEBUG_ON Class:[self class] Message:msg];
        NSString *exceptionName = @"ESPProxyTask-isReadOnlyTask";
        NSString *exceptionReaseon = @"CLOSE_PROXYTASK shouldn't call isReadOnlyTask()";
        NSException *e = [ESPIllegalStateException exceptionWithName:exceptionName reason:exceptionReaseon userInfo:nil];
        @throw e;
    }
    return _isReadOnlyTask;
}

/**
 * Whether reply response is required
 *
 * @return
 */
-(BOOL) isReplyRequired
{
    if (self==[ESPProxyTask CLOSE_PROXYTASK]) {
        NSString *msg = @"CLOSE_PROXYTASK shouldn't call isReplyRequired()";
        [ESPMeshLog error:DEBUG_ON Class:[self class] Message:msg];
        NSString *exceptionName = @"ESPProxyTask-isReplyRequired";
        NSString *exceptionReaseon = @"CLOSE_PROXYTASK shouldn't call isReplyRequired()";
        NSException *e = [ESPIllegalStateException exceptionWithName:exceptionName reason:exceptionReaseon userInfo:nil];
        @throw e;
    }
    return _isReplyRequired;
}

/**
 * Get proto type
 *
 * @return
 */
-(int) getProtoType
{
    if (self==[ESPProxyTask CLOSE_PROXYTASK]) {
        NSString *msg = @"CLOSE_PROXYTASK shouldn't call getProtoType()";
        [ESPMeshLog error:DEBUG_ON Class:[self class] Message:msg];
        NSString *exceptionName = @"ESPProxyTask-getProtoType";
        NSString *exceptionReaseon = @"CLOSE_PROXYTASK shouldn't call getProtoType()";
        NSException *e = [ESPIllegalStateException exceptionWithName:exceptionName reason:exceptionReaseon userInfo:nil];
        @throw e;
    }
    return _protoType;
}

/**
 * Get long socket task serial
 *
 * @return
 */
-(int) getLongSocketSerial
{
    if (self==[ESPProxyTask CLOSE_PROXYTASK]) {
        NSString *msg = @"CLOSE_PROXYTASK shouldn't call getLongSocketSerial()";
        [ESPMeshLog error:DEBUG_ON Class:[self class] Message:msg];
        NSString *exceptionName = @"ESPProxyTask-getLongSocketSerial";
        NSString *exceptionReaseon = @"CLOSE_PROXYTASK shouldn't call getLongSocketSerial()";
        NSException *e = [ESPIllegalStateException exceptionWithName:exceptionName reason:exceptionReaseon userInfo:nil];
        @throw e;
    }
    return _longSocketSerial;
}

/**
 * Get task timeout
 *
 * @return
 */
-(int) getTaskTimeout
{
    if (self==[ESPProxyTask CLOSE_PROXYTASK]) {
        NSString *msg = @"CLOSE_PROXYTASK shouldn't call getTaskTimeout()";
        [ESPMeshLog error:DEBUG_ON Class:[self class] Message:msg];
        NSString *exceptionName = @"ESPProxyTask-getTaskTimeout";
        NSString *exceptionReaseon = @"CLOSE_PROXYTASK shouldn't call getTaskTimeout()";
        NSException *e = [ESPIllegalStateException exceptionWithName:exceptionName reason:exceptionReaseon userInfo:nil];
        @throw e;
    }
    return _taskTimeout;
}

/**
 * get group bssid array
 *
 * @return group bssid array
 */
-(NSArray*) getGroupBssidArray
{
    if (self==[ESPProxyTask CLOSE_PROXYTASK]) {
        NSString *msg = @"CLOSE_PROXYTASK shouldn't call getGroupBssidArray()";
        [ESPMeshLog error:DEBUG_ON Class:[self class] Message:msg];
        NSString *exceptionName = @"ESPProxyTask-getGroupBssidArray";
        NSString *exceptionReaseon = @"CLOSE_PROXYTASK shouldn't call getGroupBssidArray()";
        NSException *e = [ESPIllegalStateException exceptionWithName:exceptionName reason:exceptionReaseon userInfo:nil];
        @throw e;
    }
    return _groupBssidArray;
}

/**
 * set group bssid array
 *
 * @param groupBssidArray the group bssid array
 */
-(void) setGroupBssidArray:(NSArray *)groupBssidArray
{
    if (self==[ESPProxyTask CLOSE_PROXYTASK]) {
        NSString *msg = @"CLOSE_PROXYTASK shouldn't call setGroupBssidList()";
        [ESPMeshLog error:DEBUG_ON Class:[self class] Message:msg];
        NSString *exceptionName = @"ESPProxyTask-setGroupBssidList";
        NSString *exceptionReaseon = @"CLOSE_PROXYTASK shouldn't call setGroupBssidList()";
        NSException *e = [ESPIllegalStateException exceptionWithName:exceptionName reason:exceptionReaseon userInfo:nil];
        @throw e;
    }
    _groupBssidArray = groupBssidArray;
}

-(NSString *) description
{
    if (self==[ESPProxyTask CLOSE_PROXYTASK]) {
        return @"[ CLOSE_PROXYTASK ]";
    } else {
        NSString *addr = [super description];
        return [NSString stringWithFormat:@"[ %@ | host = %@ | bssid = %@ | request valid = %@ | response valid = %@ | finish = %@ | longSocketSerial = %d | expired = %@",addr,_targetInetAddress,_targetBssid,_isRequestValid?@"YES":@"NO",_isResponseValid?@"YES":@"NO",_isFinished?@"YES":@"NO",_longSocketSerial, [self isExpired]?@"YES":@"NO"];
    }
}

#pragma pakcage method


-(void) setSourceSocket:(ESPSocketClient2 *)sourceSocket
{
    if (self==[ESPProxyTask CLOSE_PROXYTASK]) {
        NSString *msg = @"CLOSE_PROXYTASK shouldn't call setSourceSocket()";
        [ESPMeshLog error:DEBUG_ON Class:[self class] Message:msg];
        NSString *exceptionName = @"ESPProxyTask-setSourceSocket";
        NSString *exceptionReaseon = @"CLOSE_PROXYTASK shouldn't call setSourceSocket()";
        NSException *e = [ESPIllegalStateException exceptionWithName:exceptionName reason:exceptionReaseon userInfo:nil];
        @throw e;
    }
    _sourceSocket = sourceSocket;
}

-(void) setReadOnlyTask:(BOOL)isReadOnlyTask
{
    if (self==[ESPProxyTask CLOSE_PROXYTASK]) {
        NSString *msg = @"CLOSE_PROXYTASK shouldn't call setSourceSocket()";
        [ESPMeshLog error:DEBUG_ON Class:[self class] Message:msg];
        NSString *exceptionName = @"ESPProxyTask-setSourceSocket";
        NSString *exceptionReaseon = @"CLOSE_PROXYTASK shouldn't call setSourceSocket()";
        NSException *e = [ESPIllegalStateException exceptionWithName:exceptionName reason:exceptionReaseon userInfo:nil];
        @throw e;
    }
    _isReadOnlyTask = isReadOnlyTask;
}

-(void) setReplyRequired:(BOOL)isReplyRequired
{
    if (self==[ESPProxyTask CLOSE_PROXYTASK]) {
        NSString *msg = @"CLOSE_PROXYTASK shouldn't call setIsReplyRequired()";
        [ESPMeshLog error:DEBUG_ON Class:[self class] Message:msg];
        NSString *exceptionName = @"ESPProxyTask-setIsReplyRequired";
        NSString *exceptionReaseon = @"CLOSE_PROXYTASK shouldn't call setIsReplyRequired()";
        NSException *e = [ESPIllegalStateException exceptionWithName:exceptionName reason:exceptionReaseon userInfo:nil];
        @throw e;
    }
    _isReplyRequired = isReplyRequired;
}

-(void) setProtoType:(int)protoType
{
    if (self==[ESPProxyTask CLOSE_PROXYTASK]) {
        NSString *msg = @"CLOSE_PROXYTASK shouldn't call setProtoType()";
        [ESPMeshLog error:DEBUG_ON Class:[self class] Message:msg];
        NSString *exceptionName = @"ESPProxyTask-setProtoType";
        NSString *exceptionReaseon = @"CLOSE_PROXYTASK shouldn't call setProtoType()";
        NSException *e = [ESPIllegalStateException exceptionWithName:exceptionName reason:exceptionReaseon userInfo:nil];
        @throw e;
    }
    _protoType = protoType;
}

-(void) setLongSocketSerial:(int)serial
{
    if (self==[ESPProxyTask CLOSE_PROXYTASK]) {
        NSString *msg = @"CLOSE_PROXYTASK shouldn't call setLongSocketSerial()";
        [ESPMeshLog error:DEBUG_ON Class:[self class] Message:msg];
        NSString *exceptionName = @"ESPProxyTask-setLongSocketSerial";
        NSString *exceptionReaseon = @"CLOSE_PROXYTASK shouldn't call setLongSocketSerial()";
        NSException *e = [ESPIllegalStateException exceptionWithName:exceptionName reason:exceptionReaseon userInfo:nil];
        @throw e;
    }
    _longSocketSerial = serial;
}

-(void) setTaskTimeout:(int)taskTimeout
{
    if (self==[ESPProxyTask CLOSE_PROXYTASK]) {
        NSString *msg = @"CLOSE_PROXYTASK shouldn't call setTaskTimeout()";
        [ESPMeshLog error:DEBUG_ON Class:[self class] Message:msg];
        NSString *exceptionName = @"ESPProxyTask-setTaskTimeout";
        NSString *exceptionReaseon = @"CLOSE_PROXYTASK shouldn't call setTaskTimeout()";
        NSException *e = [ESPIllegalStateException exceptionWithName:exceptionName reason:exceptionReaseon userInfo:nil];
        @throw e;
    }
    _taskTimeout = taskTimeout;
}

@end
