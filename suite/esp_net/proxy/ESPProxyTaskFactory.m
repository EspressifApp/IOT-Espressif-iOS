

//
//  ESPProxyTaskFactory.m
//  MeshProxy
//
//  Created by 白 桦 on 4/15/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import "ESPProxyTaskFactory.h"
#import "ESPMeshCommunicationUtils.h"
#import "ESPSocketUtil.h"
#import "ESPMeshLog.h"
#import "ESPSocketIOException.h"

#define DEBUG_ON    NO

@implementation ESPProxyTaskFactory

+ (NSArray *) UNNECESSARY_HEADER_LIST
{
    static NSArray *UNNECESSARY_HEADER_LIST;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        UNNECESSARY_HEADER_LIST = [[NSArray alloc]initWithObjects:HEADER_MESH_BSSID,HEADER_MESH_HOST,HEADER_MESH_MULTICAST_GROUP,HEADER_NON_RESPONSE,HEADER_PROTO_TYPE,HEADER_PROXY_TIMEOUT,HEADER_READ_ONLY,HEADER_TASK_SERIAL,HEADER_TASK_TIMEOUT,nil];
    });
    return UNNECESSARY_HEADER_LIST;
}

/**
 * get bssid list from bssids String
 *
 * @param bssids bssids String
 * @return bssid list
 */
+ (NSArray *) getBssidList:(NSString *)bssids
{
    // 18:fe:34:a2:c6:db length is 17
    if ([bssids length] % 17 != 0) {
        return nil;
    }
    NSMutableArray *bssidMutableArray = [[NSMutableArray alloc]init];
    for (int i = 0; i < [bssids length]; i+=17) {
        NSRange range = NSMakeRange(i, 17);
        NSString *bssid = [bssids substringWithRange:range];
        [bssidMutableArray addObject:bssid];
    }
    return [bssidMutableArray copy];
}

/**
 * create ESPProxyTask by its source socket
 *
 * @param srcSock the source socket
 * @return the ESPProxyTask
 */
+ (ESPProxyTask *)createProxyTask:(ESPSocketClient2 *)srcSock
{
    @try {
        NSMutableData *buffer = [[NSMutableData alloc]initWithLength:2048];
        int headerLength = [ESPSocketUtil readHttpHeader:srcSock IntoBuffer:buffer Offset:0];
        
        NSString *bssid = [ESPSocketUtil findHttpHeader:buffer Offset:0 Count:headerLength HeaderKey:HEADER_MESH_BSSID];
        NSString *host = [ESPSocketUtil findHttpHeader:buffer Offset:0 Count:headerLength HeaderKey:HEADER_MESH_HOST];
        NSString *proxyTimeoutStr = [ESPSocketUtil findHttpHeader:buffer Offset:0 Count:headerLength HeaderKey:HEADER_PROXY_TIMEOUT];
        NSString *readResponseStr = [ESPSocketUtil findHttpHeader:buffer Offset:0 Count:headerLength HeaderKey:HEADER_READ_ONLY];
        NSString *requireResponseStr = [ESPSocketUtil findHttpHeader:buffer Offset:0 Count:headerLength HeaderKey:HEADER_NON_RESPONSE];
        NSString *protoTypeStr = [ESPSocketUtil findHttpHeader:buffer Offset:0 Count:headerLength HeaderKey:HEADER_PROTO_TYPE];
        NSString *taskSerialStr = [ESPSocketUtil findHttpHeader:buffer Offset:0 Count:headerLength HeaderKey:HEADER_TASK_SERIAL];
        NSString *taskTimeoutStr = [ESPSocketUtil findHttpHeader:buffer Offset:0 Count:headerLength HeaderKey:HEADER_TASK_TIMEOUT];
        NSString *contentLengthStr = [ESPSocketUtil findHttpHeader:buffer Offset:0 Count:headerLength HeaderKey:@"Content-Length"];
        int contentLength = 0;
        if (contentLengthStr!=nil) {
            contentLength = [contentLengthStr intValue];
            [ESPSocketUtil readData:srcSock IntoBuffer:buffer Offset:headerLength Count:contentLength];
        }
        NSString *meshGroupStr = [ESPSocketUtil findHttpHeader:buffer Offset:0 Count:headerLength HeaderKey:HEADER_MESH_MULTICAST_GROUP];
        NSArray *bssidArray = nil;
        if (meshGroupStr!=nil) {
            bssidArray  = [self getBssidList:meshGroupStr];
        }
        
        int protoType = protoTypeStr==nil ? M_PROTO_HTTP : [protoTypeStr intValue];
        
        // remove unnecessary header
        NSInteger newHeaderLength;
        NSData *newBuffer = [ESPSocketUtil removeUnnecessaryHttpHeader:buffer HeaderLength:headerLength ContentLength:contentLength HttpHeaderArray:[self UNNECESSARY_HEADER_LIST] NewHeaderLength:&newHeaderLength];
        headerLength = (int)newHeaderLength;
        
        NSData *requestData = [self getRequestData:protoType FullBuffer:newBuffer HeaderLength:headerLength ContentLength:contentLength];
        
        NSString *msg = [NSString stringWithFormat:@"createProxyTask() bssid is: %@",bssid];
        [ESPMeshLog info:DEBUG_ON Class:[self class] Message:msg];
        
        int proxyTimeout = [proxyTimeoutStr intValue];
        ESPProxyTask *task = [[ESPProxyTask alloc]initWithHost:host Bssid:bssid RequestData:requestData Timeout:proxyTimeout];
        [task setSourceSocket:srcSock];
        BOOL readOnly = readResponseStr!=nil && [readResponseStr intValue]!=0;
        [task setReadOnlyTask:readOnly];
        BOOL replyResponse = requireResponseStr==nil || [requireResponseStr intValue]==0;
        [task setReplyRequired:replyResponse];
        [task setProtoType:protoType];
        int taskSerial = taskSerialStr==nil ? SERIAL_NORMAL_TASK : [taskSerialStr intValue];
        [task setLongSocketSerial:taskSerial];
        int taskTimeout = taskTimeoutStr==nil ? 0 : [taskTimeoutStr intValue];
        [task setTaskTimeout:taskTimeout];
        if (bssidArray!=nil) {
            [task setGroupBssidArray:bssidArray];
        }
        return task;
    }
    @catch (ESPSocketIOException *exception) {
        [ESPMeshLog error:DEBUG_ON Class:[self class] Message:@"createProxyTask() ESPSocketIOException"];
        [srcSock close];
    }
    return nil;
}

+ (NSData *) getRequestData:(int)protoType FullBuffer:(NSData *)fullBuffer HeaderLength:(int) headerLength ContentLength:(int)contentLength
{
    BOOL sendContentOnly;
    switch (protoType) {
        case M_PROTO_JSON:
            sendContentOnly = YES;
            break;
        case M_PROTO_NONE:
        case M_PROTO_MQTT:
        case M_PROTO_HTTP:
        default:
            sendContentOnly = NO;
            break;
    }
    
    int bufferOffset = sendContentOnly ? headerLength : 0;
    int bufferLen = sendContentOnly ? contentLength : headerLength + contentLength;
    NSRange range = NSMakeRange(bufferOffset, bufferLen);
    return [fullBuffer subdataWithRange:range];
}


@end
