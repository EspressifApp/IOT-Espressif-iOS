
//
//  ESPMeshSocket.m
//  MeshProxy
//
//  Created by 白 桦 on 4/13/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ESPMeshSocket.h"
#import "ESPBlockingMutableArray.h"
#import "ESPSocketClient2.h"
#import "ESPMeshRequest.h"
#import "ESPMeshResponse.h"
#import "ESPMeshLog.h"
#import "ESPSocketUtil.h"
#import "ESPInterruptException.h"
#import "ESPIllegalStateException.h"
#import "ESPSocketIOException.h"
#import "ESPMeshCommunicationUtils.h"

#define DEBUG_ON                        NO
#define DEVICE_AVAILABLE_RETRY          1
#define DEVICE_AVAILABLE_INTERVAL       500
#define DEVICE_AVAILABLE_TIMEOUT        6000
#define SO_TIMEOUT                      4000
#define SO_CONNECT_TIMEOUT              2000
#define SO_CONNECT_INTERVAL             500
#define SO_CONNECT_RETRY                3
#define DEVICE_MESH_PORT                7000
#define BUFFER_SIZE_MAX                 1300
#define DEFAULT_ESPMESH_SOCKET_TIMEOUT  8000

@interface ESPMeshSocket()

// the new proxy task array
@property (nonatomic, strong) __block ESPBlockingMutableArray *refreshProxyTaskArray;
// the proxy task array which has been sent request
@property (nonatomic, strong) __block NSMutableArray *sentProxyTaskArray;
// long socket serial is used to close long socket request after half close
@property (nonatomic, strong) __block NSMutableDictionary *longSocketSerialDict;
// long socket buffer is used to cache long socket response some special time
@property (nonatomic, strong) __block NSMutableDictionary *longSocketBufferDict;

@property (nonatomic, assign) __block BOOL isClosed;
@property (nonatomic, assign) __block BOOL isHalfClosed;
@property (nonatomic, strong) __block ESPSocketClient2 *socket;
@property (nonatomic, strong) __block NSString *targetInetAddr;
@property (nonatomic, assign) __block int timeout;
@property (nonatomic, assign) __block NSTimeInterval refreshTimestamp;
@property (nonatomic, strong) __block NSCondition *conditionLock;
@property (nonatomic, strong) __block NSCondition *conditionHalfClosedLock;
@property (nonatomic, strong) __block ESPBlockingMutableArray *deviceAvaibableToken;
@property (nonatomic, strong) __block NSMutableData *buffer;
@property (nonatomic, assign) __block int bufferOffset;
@property (nonatomic, strong) __block ESPMeshResponse *meshResponse;

// let ESPMeshSocket be executed completely even app entered background
@property (nonatomic,assign) __block UIBackgroundTaskIdentifier _backgroundTask;

@end

@implementation ESPMeshSocket

+ (NSObject *) TOKEN_TRUE
{
    static NSObject *TOKEN_TRUE;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        TOKEN_TRUE = [[NSObject alloc]init];
    });
    return TOKEN_TRUE;
}

- (instancetype)init
{
    abort();
}

- (instancetype)initWithInetAddr:(NSString *)inetAddr
{
    self = [super init];
    if (self) {
        _bufferOffset = 0;
        _meshResponse = nil;
        _targetInetAddr = inetAddr;
        _refreshProxyTaskArray = [[ESPBlockingMutableArray alloc]init];
        _sentProxyTaskArray = [[NSMutableArray alloc]init];
        _longSocketSerialDict = [[NSMutableDictionary alloc]init];
        _longSocketBufferDict = [[NSMutableDictionary alloc]init];
        _isClosed = NO;
        _isHalfClosed = NO;
        _timeout = DEFAULT_ESPMESH_SOCKET_TIMEOUT;
        _refreshTimestamp = [[NSDate date] timeIntervalSince1970];
        _conditionLock= [[NSCondition alloc]init];
        _conditionHalfClosedLock = [[NSCondition alloc]init];
        _deviceAvaibableToken = [[ESPBlockingMutableArray alloc]init];
        _buffer = [[NSMutableData alloc]initWithCapacity:BUFFER_SIZE_MAX];
        
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(queue, ^{
            [self loop];
        });
    }
    return self;
}


- (void) putLongSocketBufferWithTargetBssid:(NSString *)targetBssid Buffer:(NSData *)buffer
{
    NSString *msg = [NSString stringWithFormat:@"putLongSocketBufferWithTargetBssid: %@ Buffer: %@",targetBssid,[[NSString alloc] initWithData:buffer encoding:NSUTF8StringEncoding]];
    [ESPMeshLog debug:DEBUG_ON Class:[self class] Message:msg];
    @synchronized(_longSocketBufferDict) {
        [_longSocketBufferDict setObject:buffer forKey:targetBssid];
    }
}


- (void) clearLongSocketBufferWithTargetBssid:(NSString *)targetBssid
{
    NSString *msg = [NSString stringWithFormat:@"clearLongSocketBufferWithTargetBssid: %@",targetBssid];
    [ESPMeshLog debug:DEBUG_ON Class:[self class] Message:msg];
    @synchronized(_longSocketBufferDict) {
        [_longSocketBufferDict removeObjectForKey:targetBssid];
    }
}


- (void) clearLongSocketBufferAll
{
    NSString *msg = [NSString stringWithFormat:@"clearLongSocketBufferAll"];
    [ESPMeshLog debug:DEBUG_ON Class:[self class] Message:msg];
    @synchronized(_longSocketBufferDict) {
        [_longSocketBufferDict removeAllObjects];
    }
}

- (void) putLongSocketSerialDictWithTargetBssid:(NSString *)targetBssid Serial:(int)serial
{
    NSString *msg = [NSString stringWithFormat:@"putLongSocketSerialDictWithTargetBssid: %@ Serial:%d",targetBssid,serial];
    [ESPMeshLog debug:DEBUG_ON Class:[self class] Message:msg];
    @synchronized(_longSocketSerialDict) {
        [_longSocketSerialDict setObject:[NSNumber numberWithInt:serial] forKey:targetBssid];
    }
}

- (BOOL) isLongSocketExistWithTargetBssid:(NSString *)targetBssid
{
    @synchronized(_longSocketSerialDict) {
        return [_longSocketSerialDict objectForKey:targetBssid] != nil;
    }
}

- (BOOL) isLongSocketSerialDictExistWithTargetBssid:(NSString *)targetBssid Serial:(int)serial
{
    @synchronized(_longSocketSerialDict) {
        NSNumber *serialNumber = [_longSocketSerialDict objectForKey:targetBssid];
        if (serialNumber != nil && [serialNumber intValue] == serial) {
            return YES;
        } else {
            return NO;
        }
    }
}

- (void) clearLongSocketSerialDict
{
    @synchronized(_longSocketSerialDict) {
        [_longSocketSerialDict removeAllObjects];
    }
}

- (ESPSocketClient2 *) open:(NSString *)remoteInetAddr
{
    ESPSocketClient2 *socket = nil;
    
    BOOL isConnected = NO;
    for (int retry = 0; !isConnected && retry < SO_CONNECT_RETRY; ++retry) {
        // connect to target device(root device)
        socket = [[ESPSocketClient2 alloc]init];
        [socket setSoTimeout:SO_TIMEOUT];
        [socket setConnTimeout:SO_CONNECT_TIMEOUT];
        // socket will be closed automatically
        if ([socket connect:remoteInetAddr Port:DEVICE_MESH_PORT]) {
            isConnected = YES;
            break;
        } else {
            [ESPMeshLog error:DEBUG_ON Class:[self class] Message:@"open() connect fail"];
            if (retry < SO_CONNECT_RETRY-1) {
                [NSThread sleepForTimeInterval:SO_CONNECT_INTERVAL/1000.0];
            }
        }
    }
    if (!isConnected) {
        NSString *msg = [NSString stringWithFormat:@"open() fail for remoteInetAddr:%@, return null",remoteInetAddr];
        [ESPMeshLog debug:DEBUG_ON Class:[self class] Message:msg];
        [self close];
        return nil;
    } else {
        NSString *msg = [NSString stringWithFormat:@"open() suc for remoteInetAddr:%@, so deviceAvailableToken addObject: TOKEN_TRUE",remoteInetAddr];
        [ESPMeshLog debug:DEBUG_ON Class:[self class] Message:msg];
        [_deviceAvaibableToken addObject:[ESPMeshSocket TOKEN_TRUE]];
        return socket;
    }
}

- (void) sendRequestData:(NSData *)requestData TargetBssid:(NSString *)targetBssid TargetBssidArray:(NSArray *)targetBssidArray Proto:(int)proto
{
    if (![self isConnected]) {
        [ESPMeshLog debug:DEBUG_ON Class:[self class] Message:@"sendRequestData() socket isn't connected, return"];
        return;
    }
    ESPMeshRequest *meshRequest = targetBssidArray == nil ? [[ESPMeshRequest alloc]initWithProto:proto TargetBssid:targetBssid OriginRequestData:requestData] : [[ESPMeshRequest alloc]initWithProto:proto TargetBssidArray:targetBssidArray OriginRequestData:requestData];
    requestData = [meshRequest getRequestData];
    
    // write request data
    if ([_socket writeData:requestData]) {
        [self refresh];
        NSString *msg = [NSString stringWithFormat:@"sendRequestData() targetBssid:%@, write suc",targetBssid];
        [ESPMeshLog debug:DEBUG_ON Class:[self class] Message:msg];
    } else {
        [self close];
        NSString *msg = [NSString stringWithFormat:@"sendRequestData() targetBssid:%@, IOException, so close EspMeshSocket",targetBssid];
        [ESPMeshLog error:DEBUG_ON Class:[self class] Message:msg];
    }
}

- (void) beginBackgroundTask
{
    if (DEBUG_ON)
    {
        NSLog(@"ESPMeshSocket beginBackgroundTask() entrance");
    }
    self._backgroundTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        if (DEBUG_ON)
        {
            NSLog(@"ESPMeshSocket beginBackgroundTask() endBackgroundTask");
        }
        [self endBackgroundTask];
    }];
}

- (void) endBackgroundTask
{
    if (DEBUG_ON)
    {
        NSLog(@"ESPMeshSocket endBackgroundTask() entrance");
    }
    [[UIApplication sharedApplication] endBackgroundTask: self._backgroundTask];
    self._backgroundTask = UIBackgroundTaskInvalid;
}

- (void) loop
{
    
    [self beginBackgroundTask];
    
    ESPProxyTask *proxyTask = nil;
    NSString *msg = nil;
    @try {
        proxyTask = [_refreshProxyTaskArray take];
        msg = [NSString stringWithFormat:@"ESPMeshSocket loop() take1 proxyTask: %@ from refreshProxyTaskArray",proxyTask];
        [ESPMeshLog debug:DEBUG_ON Class:[self class] Message:msg];
    }
    @catch (ESPInterruptException *exception) {
        NSLog(@"ESPMeshSocket loop ESPInterruptException: %@",exception);
    }
    msg = [NSString stringWithFormat:@"loop() take proxyTask: %@",proxyTask];
    [ESPMeshLog debug:DEBUG_ON Class:[self class] Message:msg];
    
    NSString *targetBssid = [proxyTask getTargetBssid];
    if (proxyTask != nil && proxyTask != [ESPProxyTask CLOSE_PROXYTASK]) {
        // connect to the target
        if (_socket == nil) {
            msg = [NSString stringWithFormat:@"loop() try to open() %@",_targetInetAddr];
            [ESPMeshLog debug:DEBUG_ON Class:[self class] Message:msg];
            _socket = [self open:_targetInetAddr];
            if (_socket == nil) {
                msg = [NSString stringWithFormat:@"loop() fail to open() %@, so proxyTask: %@ replyClose()",_targetInetAddr,proxyTask];
                [ESPMeshLog warn:DEBUG_ON Class:[self class] Message:msg];
                [proxyTask replyClose];
                [self endBackgroundTask];
                return;
            } else {
                [self refresh];
            }
        }
    }
    while ([self isConnected] && !_isClosed) {
        BOOL isDeviceAvailable = NO;
        for (int retry = 0; !isDeviceAvailable && retry < DEVICE_AVAILABLE_RETRY; ++retry) {
            if (retry != 0) {
                [NSThread sleepForTimeInterval:DEVICE_AVAILABLE_INTERVAL/1000.0];
                // check whether the loop is stopped
                if (_isClosed) {
                    break;
                }
            }
            msg = [NSString stringWithFormat:@"loop() sendIsDeviceAvailable() %d time",retry];
            [ESPMeshLog debug:DEBUG_ON Class:[self class] Message:msg];
            
            // wait is device available
            int timeout = [proxyTask isReadOnlyTask] ? [proxyTask getTaskTimeout] : DEVICE_AVAILABLE_TIMEOUT;
            NSObject *token = [self waitDeviceAvailableToken:timeout];
            if (token == nil) {
                msg = @"loop() waitDeviceAvailableToken() get null, break";
                [ESPMeshLog warn:DEBUG_ON Class:[self class] Message:msg];
                break;
            }
            isDeviceAvailable = token == [ESPMeshSocket TOKEN_TRUE];
            msg = [NSString stringWithFormat:@"loop() waitDeviceAvailableToken() %d time, isDeviceAvailable: %@",retry,isDeviceAvailable ? @"YES":@"NO"];
            [ESPMeshLog debug:DEBUG_ON Class:[self class] Message:msg];
        }
        
        if (!isDeviceAvailable) {
            [self halfClose];
            [proxyTask replyClose];
            msg = @"loop() isDeviceAvailable is NO, halfClose() proxyTask replyClose() and break";
            [ESPMeshLog warn:DEBUG_ON Class:[self class] Message:msg];
            break;
        } else {
            [proxyTask updateTimestamp];
        }
        
        NSData *requestData = [proxyTask getRequestData];
        // send request
        if (![proxyTask isReadOnlyTask]) {
            int proto = [proxyTask getProtoType];
            NSArray *targetBssidArray = [proxyTask getGroupBssidArray];
            [self sendRequestData:requestData TargetBssid:targetBssid TargetBssidArray:targetBssidArray Proto:proto];
            msg = [NSString stringWithFormat:@"loop() sendRequestData to %@ suc",targetBssid];
            [ESPMeshLog info:DEBUG_ON Class:[self class] Message:msg];
        } else {
            // return device available ticket
            [_deviceAvaibableToken addObject:[ESPMeshSocket TOKEN_TRUE]];
            [self refresh];
            msg = @"loop() send dummy request for proxy task is read only, return device available";
            [ESPMeshLog info:DEBUG_ON Class:[self class] Message:msg];
        }
        
        if ([self isConnected]) {
            if ([proxyTask isReplyRequired]) {
                msg = [NSString stringWithFormat:@"loop() add proxyTask of %@ into sentProxyTaskArray",targetBssid];
                [ESPMeshLog info:DEBUG_ON Class:[self class] Message:msg];
                // add proxyTask into sentTaskArray
                @synchronized(_sentProxyTaskArray) {
                    [_sentProxyTaskArray addObject:proxyTask];
                }
            } else {
                msg = @"loop() retry a non reply request";
                [ESPMeshLog info:DEBUG_ON Class:[self class] Message:msg];
                [proxyTask replyResponse];
            }
        } else {
            msg = [NSString stringWithFormat:@"loop() fail to sendRequestData to %@ :, so proxyTask: %@ replyClose() and break",targetBssid,proxyTask];
            [ESPMeshLog warn:DEBUG_ON Class:[self class] Message:msg];
            [proxyTask replyClose];
            break;
        }
        
        // try to get next proxyTask
        @try {
            proxyTask = [_refreshProxyTaskArray take];
            msg = [NSString stringWithFormat:@"ESPMeshSocket loop() take2 proxyTask: %@ from refreshProxyTaskArray",proxyTask];
            [ESPMeshLog debug:DEBUG_ON Class:[self class] Message:msg];
        }
        @catch (ESPInterruptException *exception) {
            NSLog(@"ESPMeshSocket loop() try to get next proxyTask exception: %@",exception);
        }
        msg = [NSString stringWithFormat:@"loop() take proxyTask: %@ from refreshProxyTaskArray",proxyTask];
        if (proxyTask == nil || proxyTask == [ESPProxyTask CLOSE_PROXYTASK]) {
            break;
        } else {
            // don't forget to update bssid
            targetBssid = [proxyTask getTargetBssid];
        }

    }
    
    [self endBackgroundTask];
}

/**
 * get local inet address
 *
 * @return local inet address
 */
- (NSString *) getInetAddress
{
    return _targetInetAddr;
}

/**
 * get the refresh proxy task list which hasn't been sent
 *
 * @return the refresh proxy task(ESPProxyTask) array which hasn't been sent
 */
- (NSArray *) getRefreshProxyTaskArray
{
    NSMutableArray *proxyTaskArray = [[NSMutableArray alloc]init];
    for (ESPProxyTask *proxyTask in _refreshProxyTaskArray) {
        if (proxyTask != [ESPProxyTask CLOSE_PROXYTASK] && ![proxyTask isFinished]) {
            [proxyTask updateTimestamp];
            [proxyTaskArray addObject:proxyTask];
        }
    }
    NSString *msg = [NSString stringWithFormat:@"ESPMeshSocket refreshProxyTaskArray:%@ getRefreshProxyTaskArray() %@",_refreshProxyTaskArray, [proxyTaskArray copy]];
    [ESPMeshLog debug:DEBUG_ON Class:[self class] Message:msg];
    return [proxyTaskArray copy];
}

- (void) addNewProxyTask:(ESPProxyTask *)proxyTask
{
    // add new proxy task to refreshProxyTaskArray
    [_refreshProxyTaskArray addObject:proxyTask];
    NSString *msg = [NSString stringWithFormat:@"ESPMeshSocekt addNewProxyTask proxyTask: %@",proxyTask];
    [ESPMeshLog debug:DEBUG_ON Class:[self class] Message:msg];
    // put long serial map if necessary
    int serial = [proxyTask getLongSocketSerial];
    if (serial != SERIAL_NORMAL_TASK) {
        NSString *targetBssid = [proxyTask getTargetBssid];
        [self putLongSocketSerialDictWithTargetBssid:targetBssid Serial:serial];
    }
}

- (void) increaseTimeout:(ESPProxyTask *)proxyTask
{
    NSString *msg = [NSString stringWithFormat:@"increaseTiemout() %d",[proxyTask getTaskTimeout]];
    [ESPMeshLog info:DEBUG_ON Class:[self class] Message:msg];
    _timeout += [proxyTask getTaskTimeout];
}

- (void) decreaseTimeout:(ESPProxyTask *)proxyTask
{
    NSString *msg = [NSString stringWithFormat:@"decreaseTimeout() %d",[proxyTask getTaskTimeout]];
    [ESPMeshLog info:DEBUG_ON Class:[self class] Message:msg];
    _timeout -= [proxyTask getTaskTimeout];
}

/**
 * offer the new proxy task
 *
 * @param proxyTask the new proxy task
 */
- (void) offer: (ESPProxyTask *) proxyTask
{
    [proxyTask updateTimestamp];
    // check whether the target InetAddress is valid
    if (![[proxyTask getTargetInetAddress] isEqualToString:_targetInetAddr]) {
        NSString *exceptionName = @"ESPMeshSocket-offer";
        NSString *exceptionReason = @"ESPProxyTask's target InetAddress is wrong";
        NSException *e = [ESPIllegalStateException exceptionWithName:exceptionName reason:exceptionReason userInfo:nil];
        @throw e;
    }
    // update the ESPMeshSocket timeout if necessary
    if ([proxyTask getTaskTimeout] != 0) {
        [self increaseTimeout:proxyTask];
    }
    [self addNewProxyTask:proxyTask];
}

/**
 * close the EspMeshSocket half, don't accept more new request
 */
- (void) halfClose
{
    NSString *msg = @"halfClose()";
    [ESPMeshLog error:DEBUG_ON Class:[self class] Message:msg];
    _isHalfClosed = YES;
}

/**
 * close the EspMeshSocket
 */
- (void) close
{
    @synchronized(self) {
        
        NSString *msg = nil;
        
        if (!_isClosed) {
            if (_socket != nil) {
                [_socket close];
            }
            
            
            @synchronized(_sentProxyTaskArray) {
                for (ESPProxyTask *proxyTask in _sentProxyTaskArray) {
                    [proxyTask replyClose];
                    msg = [NSString stringWithFormat:@"close() proxyTask in sentProxyTaskArray :%@ replyClose()",proxyTask];
                    [ESPMeshLog debug:DEBUG_ON Class:[self class] Message:msg];
                }
            }
            
//            for (int i = 0; i < [_refreshProxyTaskArray count]; i++) {
//                ESPProxyTask *proxyTask = [_refreshProxyTaskArray objectAtIndex:i];
//                BOOL isClosedNecessary = NO;
//                if (proxyTask != [ESPProxyTask CLOSE_PROXYTASK] && [proxyTask isExpired]) {
//                    isClosedNecessary = YES;
//                }
//                if (!isClosedNecessary) {
//                    int serial = proxyTask != [ESPProxyTask CLOSE_PROXYTASK] ? [proxyTask getLongSocketSerial] : SERIAL_NORMAL_TASK;
//                    NSString *targetBssid = [proxyTask getTargetBssid];
//                    if (serial != SERIAL_NORMAL_TASK) {
//                        if ([self isLongSocketSerialDictExistWithTargetBssid:targetBssid Serial:serial]) {
//                            isClosedNecessary = YES;
//                        }
//                    }
//                }
//                if (isClosedNecessary) {
//                    [proxyTask replyClose];
//                    msg = [NSString stringWithFormat:@"close() expired proxyTask in refreshProxyTaskArray :%@ replyClose()",proxyTask];
//                    [ESPMeshLog debug:DEBUG_ON Class:[self class] Message:msg];
//                }
//            }
            
            [self clearLongSocketBufferAll];
            [self clearLongSocketSerialDict];
            [_refreshProxyTaskArray addObject:[ESPProxyTask CLOSE_PROXYTASK]];
            _isClosed = YES;
            [_conditionLock lock];
            [_conditionHalfClosedLock signal];
            [_conditionLock unlock];
            msg = @"ESPMeshSocket is closed";
            [ESPMeshLog debug:DEBUG_ON Class:[self class] Message:msg];
        }
    }
}

/**
 * check whether the EspSocket is expired
 *
 * @return whether the EspSocket is expired
 */
- (BOOL) isExpired
{
    NSTimeInterval consume = [[NSDate date] timeIntervalSince1970] - _refreshTimestamp;
    BOOL isExpired = consume > _timeout/1000.0;
    return isExpired;
}

/**
 * make the ESPMeshSocket keep fefresh
 */
- (void) refresh
{
    if (![self isHalfClosed]) {
        _refreshTimestamp = [[NSDate date] timeIntervalSince1970];
    }
}

/**
 * reply proxy task
 *
 * @param targetBssid the target device's bssid
 * @param responseBytes the response bytes from buffer or null if response bytes are in meshResponse
 * @return whether the proxy task of the target bssid is exist
 */
- (BOOL) replyProxyTask:(NSString *)targetBssid ResponseData:(NSData *)responseData
{
    NSString *msg = @"replyProxyTask() entrance";
    [ESPMeshLog debug:DEBUG_ON Class:[self class] Message:msg];
    // try to find the ProxyTask in the sentProxyTaskArray
    ESPProxyTask *finishedProxyTask = nil;
    @synchronized(_sentProxyTaskArray) {
        for (int i = 0; i < [_sentProxyTaskArray count]; ++i) {
            ESPProxyTask *proxyTask = [_sentProxyTaskArray objectAtIndex:i];
            if ([[proxyTask getTargetBssid] isEqualToString:targetBssid]) {
                finishedProxyTask = proxyTask;
                [_sentProxyTaskArray removeObjectAtIndex:i--];
                msg = [NSString stringWithFormat:@"replyProxyTask() remove %@ from sentProxyTaskArray",targetBssid];
                [ESPMeshLog info:DEBUG_ON Class:[self class] Message:msg];
                break;
            }
        }
    }
    if (finishedProxyTask != nil) {
        msg = [NSString stringWithFormat:@"replyProxyTask() proxyTask: %@",finishedProxyTask];
        [ESPMeshLog info:DEBUG_ON Class:[self class] Message:msg];
        if (responseData == nil) {
            // get response data from meshResponse if necessary
            responseData = [_meshResponse getPureResponseData];
        }
        [finishedProxyTask setResponseBuffer:responseData];
        [finishedProxyTask replyResponse];
        // don't open the log for released version, or app will crash sometime for concurrent exception
//        msg = [NSString stringWithFormat:@"replyProxyTask() proxyTask is removed from sentProxyTaskArray: %@, sentProxyTaskArray: %@",finishedProxyTask,_sentProxyTaskArray];
//        [ESPMeshLog error:DEBUG_ON Class:[self class] Message:msg];
        
        // decrease timeout if necessary
        if ([finishedProxyTask getTaskTimeout] != 0) {
            [self decreaseTimeout:finishedProxyTask];
        }
        return YES;
    } else {
        NSMutableArray *bssidArray = [[NSMutableArray alloc]init];
        @synchronized(_sentProxyTaskArray) {
            for (ESPProxyTask *proxyTask in _sentProxyTaskArray) {
                [bssidArray addObject:[proxyTask getTargetBssid]];
            }
        }
        msg = [NSString stringWithFormat:@"replyProxyTask() can't find %@, sentProxyTaskArray bssidArray: %@",targetBssid,bssidArray];
        [ESPMeshLog error:DEBUG_ON Class:[self class] Message:msg];
        return NO;
    }
}

- (BOOL) receiveBufferData
{
    NSString *targetBssid = nil;
    NSData *responseData = nil;
    NSString *msg = nil;
    // check whether there exist response in longSocketBufferDict
    @synchronized(_longSocketBufferDict) {
        for (NSString *bufferBssid in _longSocketBufferDict) {
            @synchronized(_sentProxyTaskArray) {
                for (ESPProxyTask *proxyTask in _sentProxyTaskArray) {
                    if ([[proxyTask getTargetBssid] isEqualToString:bufferBssid] && [proxyTask getLongSocketSerial] != SERIAL_NORMAL_TASK) {
                        targetBssid = bufferBssid;
                        responseData = [_longSocketBufferDict objectForKey:bufferBssid];
                        [self clearLongSocketBufferWithTargetBssid:targetBssid];
                        break;
                    }
                }
            }
        }
    }
    // reply to target device if necessary
    if (targetBssid != nil) {
        if ([self replyProxyTask:targetBssid ResponseData:responseData]) {
            [self clearLongSocketBufferWithTargetBssid:targetBssid];
        } else {
            msg = [NSString stringWithFormat:@"receiveBufferData() can't find targetBssid: %@",targetBssid];
            [ESPMeshLog error:DEBUG_ON Class:[self class] Message:msg];
        }
    }
    BOOL isReplyAlready = targetBssid != nil;
    msg = [NSString stringWithFormat:@"receiveBufferData() isReplyAlready: %@",(targetBssid != nil) ? @"YES" : @"NO"];
    [ESPMeshLog debug:DEBUG_ON Class:[self class] Message:msg];
    return isReplyAlready;
}

/**
 * receive response bytes from mesh device
 */
- (void) receiveResponseData
{
    NSString *msg = nil;
    if (![self isConnected]) {
        msg = @"receiveResponseData() socket isn't connected, return";
        [ESPMeshLog warn:DEBUG_ON Class:[self class] Message:msg];
        return;
    }
    
    if ([self receiveBufferData]) {
        msg = @"receiveResponseData() receive response from buffer, return";
        [ESPMeshLog info:DEBUG_ON Class:[self class] Message:msg];
        return;
    }
    
    @try {
        // clear bufferOffset
        _bufferOffset = 0;
        NSMutableData *buffer = _buffer;
        int dataCount = 4;
        // read first 4 data
        [ESPSocketUtil readData:_socket IntoBuffer:buffer Offset:_bufferOffset Count:dataCount];
        _bufferOffset += dataCount;
        // update meshResponse
        _meshResponse = [[ESPMeshResponse alloc]init:buffer];
        
        // read other data
        int packageLength = [_meshResponse getPackageLength];
        dataCount = packageLength - dataCount;
        [ESPSocketUtil readData:_socket IntoBuffer:buffer Offset:_bufferOffset Count:dataCount];
        
        _bufferOffset += dataCount;
        if (![_meshResponse fillInAll:buffer]) {
            msg = @"receiveResponseData() meshResponse fail to fill in all, so close() and return";
            [ESPMeshLog warn:DEBUG_ON Class:[self class] Message:msg];
            [self close];
            return;
        }
        
        msg = [NSString stringWithFormat:@"receiveResponseData() meshResponse: %@",_meshResponse];
        [ESPMeshLog debug:DEBUG_ON Class:[self class] Message:msg];
        
        // check whether it has mesh option
        if ([_meshResponse hasMeshOption]) {
            ESPMeshOption *meshOption = [_meshResponse getMeshOption];
            for (int i = 0; i < [meshOption getDeviceAvailableCount]; ++i) {
                [_deviceAvaibableToken addObject:[ESPMeshSocket TOKEN_TRUE]];
                msg = @"receiveResponseData() receive device available1";
                [ESPMeshLog debug:DEBUG_ON Class:[self class] Message:msg];
            }
        }
        
        if ([_meshResponse isBodyEmpty]) {
            msg = @"receiveResponseData() meshResponse isBodyEmpty, return";
            [ESPMeshLog debug:DEBUG_ON Class:[self class] Message:msg];
            return;
        }
        
        // get targetBssid and reply response
        NSString *targetBssid = [_meshResponse getTargetBssid];
        
        if (targetBssid == nil) {
            NSString *exceptionName = @"ESPMeshSocket-receiveResponseData";
            NSString *exceptionReason = @"receiveResponseData() can't filter the targetBssid";
            NSException *e = [ESPIllegalStateException exceptionWithName:exceptionName reason:exceptionReason userInfo:nil];
            @throw e;
        } else {
            // check whether there's device available info in the package
            if ([_meshResponse isDeviceAvailable]) {
                [_deviceAvaibableToken addObject:[ESPMeshSocket TOKEN_TRUE]];
                msg = @"receiveResponseData() receive device available2";
                [ESPMeshLog debug:DEBUG_ON Class:[self class] Message:msg];
            }
            // can't find proxy task and the bssid exist long socket
            if (![self replyProxyTask:targetBssid ResponseData:nil] && [self isLongSocketExistWithTargetBssid:targetBssid]) {
                NSData *resposneData = [_meshResponse getPureResponseData];
                msg = @"receiveResponseData() can't find proxy task, so put into long socket buffer";
                [self putLongSocketBufferWithTargetBssid:targetBssid Buffer:resposneData];
            }
        }

    }
    @catch (ESPSocketIOException *exception) {
        msg = [NSString stringWithFormat:@"receiveResponseData() ESPSocketIOException e:%@ , so close ESPMeshSocket",exception];
        [ESPMeshLog error:DEBUG_ON Class:[self class] Message:msg];
        [self close];
    }
}

/**
 * check the proxy tasks' states and proceed them
 */
- (void) checkProxyTaskStateAndProc
{
    NSString *msg = [NSString stringWithFormat:@"ESPMeshSocket checkProxyTaskStateAndProc() entrance, sentProxyTaskArray = %@",_sentProxyTaskArray];
    [ESPMeshLog debug:DEBUG_ON Class:[self class] Message:msg];

    while ([self isNewDataArrive]) {
        msg = [NSString stringWithFormat:@"checkProxyTaskStateAndProc() receiveResponseData"];
        [ESPMeshLog debug:DEBUG_ON Class:[self class] Message:msg];
        [self receiveResponseData];
    }
    NSMutableArray *expiredSentProxyTaskArray = [[NSMutableArray alloc]init];
    @synchronized(_sentProxyTaskArray) {
        for (int i = 0; i < [_sentProxyTaskArray count]; ++i) {
            ESPProxyTask *proxyTask = [_sentProxyTaskArray objectAtIndex:i];
            if (proxyTask != [ESPProxyTask CLOSE_PROXYTASK] && [proxyTask isExpired]) {
                [expiredSentProxyTaskArray addObject:proxyTask];
                [_sentProxyTaskArray removeObjectAtIndex:i--];
                msg = [NSString stringWithFormat:@"checkProxyTaskStateAndProc() remove %@ from sentProxyTaskArray",[proxyTask getTargetBssid]];
                [ESPMeshLog info:DEBUG_ON Class:[self class] Message:msg];
            }
        }
    }
    if ([expiredSentProxyTaskArray count] > 0) {
        msg = @"checkProxyTaskStateAndProc() half close";
        [ESPMeshLog debug:DEBUG_ON Class:[self class] Message:msg];
        [self halfClose];
        msg = [NSString stringWithFormat:@"checkProxyTaskStateAndProc() expiredSentProxyTaskArray is: %@",expiredSentProxyTaskArray];
        [ESPMeshLog debug:DEBUG_ON Class:[self class] Message:msg];
    }
    for (ESPProxyTask *proxyTask in expiredSentProxyTaskArray) {
        msg = [NSString stringWithFormat:@"checkProxyTaskStateAndProc() proxyTask.replyClose(): %@",proxyTask];
        [ESPMeshLog debug:DEBUG_ON Class:[self class] Message:msg];
        [proxyTask replyClose];
    }
    if ([self isHalfClosed]) {
        msg = @"checkProxyTaskStateAndProc() is in the halfClose state";
        [ESPMeshLog debug:DEBUG_ON Class:[self class] Message:msg];
        @synchronized(_sentProxyTaskArray) {
            if ([_sentProxyTaskArray count] == 0) {
                msg = @"checkProxyTaskStateAndProc() close for sentProxyTaskArray is empty already";
                [ESPMeshLog debug:DEBUG_ON Class:[self class] Message:msg];
                [self close];
            }
        }
    }
}

/**
 * get whether there's new data arrive
 *
 * @return whether there's new data arrive
 */
- (BOOL) isNewDataArrive
{
    BOOL isAvailable = NO;
    // check whether there's buffer for long socket
    for (NSString *bufferBssid in _longSocketBufferDict) {
        @synchronized(_sentProxyTaskArray) {
            for (ESPProxyTask *proxyTask in _sentProxyTaskArray) {
                if ([[proxyTask getTargetBssid] isEqualToString:bufferBssid]) {
                    return YES;
                }
            }
        }
    }
    // check whether there's new data from socket
    isAvailable = [_socket isAvailable];
    if (isAvailable) {
        NSString *msg = [NSString stringWithFormat:@"isNewDataArrive() isAvailable: %@ for %@",isAvailable ? @"YES" : @"NO", _targetInetAddr];
        [ESPMeshLog info:DEBUG_ON Class:[self class] Message:msg];
    }
    return isAvailable;
}

/**
 * wait the mesh root device is available token
 *
 * @param timeout timeout in milliseconds
 * @return the mesh root device is available token or null(if timeout)
 */
- (NSObject *) waitDeviceAvailableToken:(int) timeout
{
    NSObject *deviceAvailableToken = nil;
    NSString *msg = nil;
    if (![self isConnected]) {
        msg = [NSString stringWithFormat:@"waitDeviceAvailableToken() socket isn't connected, return nil"];
        return deviceAvailableToken;
    }
    @try {
        deviceAvailableToken = [_deviceAvaibableToken takeUntilTimeout:timeout];
    }
    @catch (ESPInterruptException *exception) {
        NSLog(@"ESPMeshSocket waitDeviceAvailableToken() takeUntilTimeout ESPInterruptException: %@",exception);
    }

    msg = [NSString stringWithFormat:@"waitDeviceAvailableToken() %@",deviceAvailableToken];
    [ESPMeshLog info:DEBUG_ON Class:[self class] Message:msg];
    return deviceAvailableToken;
}

/**
 * get whether the EspMeshSocket is connected to remote device
 *
 * @return whether the EspMeshSocket is connected to remote device
 */
- (BOOL) isConnected
{
    return _socket != nil && [_socket isConnected];
}

/**
 * get whether the EspMeshSocket is closed
 *
 * @return whether the EspMeshSocket is closed
 */
- (BOOL) isClosed
{
    return (_socket != nil && [_socket isClosed]) || _isClosed;
}

- (BOOL) isHalfClosed
{
    return _isHalfClosed;
}

- (NSString *)description
{
    NSTimeInterval expireTime = _timeout/1000.0 - ([[NSDate date] timeIntervalSince1970] - _refreshTimestamp);
    NSString *msg = [NSString stringWithFormat:@"[targetInetAddr: %@, isClosed:%@, isHalfClosed:%@, expireTime:%f]",_targetInetAddr,_isClosed ? @"YES" : @"NO", _isHalfClosed ? @"YES" : @"NO",expireTime];
    return msg;
}


@end
