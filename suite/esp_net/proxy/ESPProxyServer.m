//
//  ESPProxyServer.m
//  MeshProxy
//
//  Created by 白 桦 on 4/13/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import "ESPProxyServer.h"
#import "ESPSocketServer2.h"
#import "ESPBlockingFinishThread.h"
#import "ESPSocketClient2.h"
#import "ESPProxyTask.h"
#import "ESPProxyTaskFactory.h"
#import "ESPMeshLog.h"
#import "ESPMeshSocketManager.h"
#import "ESPInterruptException.h"
#import "ESPIllegalStateException.h"
#import "ESPMeshSocketManager.h"

#define DEBUG_ON    YES

@interface AcceptTaskThread : ESPBlockingFinishThread

@end

@interface AcceptTaskThread()

@property (nonatomic, weak) __block ESPProxyServer* server;

@end

@implementation AcceptTaskThread

- (instancetype)initWithServer:(ESPProxyServer *)server
{
    self = [super init];
    if (self) {
        _server = server;
    }
    return self;
}

- (ESPProxyTask *)accept:(ESPSocketClient2 *) socket
{
    return [ESPProxyTaskFactory createProxyTask:socket];
}

- (void)startThreadsInit
{
}

- (void)endThreadsDestroy
{
}

- (void)execute
{
    while (super.isStart) {
        ESPSocketClient2 *socket = nil;
        ESPProxyServer *server = _server;
        if (server != nil) {
            socket = [server.socketServer accept];
        } else {
            break;
        }
        if (socket==nil) {
            if ([server.socketServer isClosed]) {
                break;
            } else {
                perror("ESPProxyServer AcceptTaskThread execute() accept fail");
                [ESPMeshLog error:DEBUG_ON Class:[self class] Message:@"execute() mServerSocket.accept() IOException, break"];
                
                dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
                dispatch_async(queue, ^{
                    [server stop];
                    [server start];
                });
                break;
            }
        } else {
            ESPProxyTask *proxyTask = [self accept:socket];
            @synchronized(server.taskBlockArray) {
                [server.taskBlockArray addObject:proxyTask];
            }
        }
    }
}

@end

@interface OfferTaskThread : ESPBlockingFinishThread

@end

@interface OfferTaskThread()

@property (nonatomic, weak) __block ESPProxyServer* server;
@property (nonatomic, strong) __block NSMutableArray* taskAddedMutableArray;
@property (nonatomic, assign) __block BOOL isInterrupted;

@end

@implementation OfferTaskThread

- (instancetype)initWithServer:(ESPProxyServer *)server
{
    self = [super init];
    if (self) {
        _taskAddedMutableArray = [[NSMutableArray alloc]init];
        _server = server;
        _isInterrupted = NO;
    }
    return self;
}

- (void)startThreadsInit
{
}

- (void)endThreadsDestroy
{
    [_taskAddedMutableArray removeAllObjects];
//    _isInterrupted = YES;
    [self interrupt];
}

- (void) interrupt
{
    _isInterrupted = YES;
    [_server.taskBlockArray interrupt];
}

- (void) offer:(ESPProxyTask*)task
{
    [[ESPMeshSocketManager sharedMeshSocketManager] accept:task];
}

- (BOOL) isTargetBssidUsing:(NSString *)bssid
{
    BOOL result = NO;
    ESPProxyTask *task;
    
    for (int i = 0; i<[_taskAddedMutableArray count]; i++) {
        task = [_taskAddedMutableArray objectAtIndex:i];
        if ([task isFinished]) {
            NSString *msg = [NSString stringWithFormat:@"%@ is finished, remove it",[task getTargetBssid]];
            [ESPMeshLog debug:DEBUG_ON Class:[self class] Message:msg];
            [_taskAddedMutableArray removeObjectAtIndex:i--];
            continue;
        }
        if ([task isExpired]) {
            NSString *msg = [NSString stringWithFormat:@"%@ is expired, remove it",[task getTargetBssid]];
            [ESPMeshLog debug:DEBUG_ON Class:[self class] Message:msg];
            [_taskAddedMutableArray removeObjectAtIndex:i--];
            continue;
        }
        if ([[task getTargetBssid] isEqualToString:bssid]) {
            result = YES;
        }
    }
    
    NSString *msg = [NSString stringWithFormat:@"%@ checkTargetBssidIsUsing %@",bssid,result?@"YES":@"NO"];
    [ESPMeshLog debug:DEBUG_ON Class:[self class] Message:msg];
    return result;
}

- (void) execute
{
    ESPProxyServer *server = _server;
    if (server==nil) {
        return;
    }
    ESPBlockingMutableArray *taskBlockArray = server.taskBlockArray;
    while (super.isStart&&!_isInterrupted) {
        @synchronized(taskBlockArray) {
            for (int i = 0; i < [taskBlockArray count] && super.isStart; ++i) {
                ESPProxyTask *task = [taskBlockArray objectAtIndex:i];
                if (![self isTargetBssidUsing:[task getTargetBssid]]) {
                    [taskBlockArray removeObjectAtIndex:i--];
                    [self offer:task];
                    [_taskAddedMutableArray addObject:task];
                }
            }
        }
        if (!super.isStart||_isInterrupted) {
            [ESPMeshLog debug:DEBUG_ON Class:[self class] Message:@"OfferTaskThread mRun is false"];
            break;
        }
        
        @try {
            BOOL isBlockingAwaked = NO;
            BOOL isEmpty;
            @synchronized(taskBlockArray) {
                isEmpty = [taskBlockArray isEmpty];
            }
            if (isEmpty) {
                isBlockingAwaked = YES;
                [ESPMeshLog debug:DEBUG_ON Class:[self class] Message:@"TaskArray is empty, wait new task add"];
                [taskBlockArray wait];
            }
            if (!isBlockingAwaked) {
                [ESPMeshLog info:DEBUG_ON Class:[self class] Message:@"TaskArray is not empty, sleep 100 millisecond and run again"];
                [NSThread sleepForTimeInterval:0.1];
            }
        }
        @catch (ESPInterruptException *exception) {
            if (_isInterrupted) {
                [ESPMeshLog info:DEBUG_ON Class:[self class] Message:@"OfferTaskThread execute() is interrupted"];
                break;
            } else {
                NSLog(@"ESPProxyServer OfferTaskThread encounter ESPInterruptException");
            }
        }
    }   // while end
}

@end

#define PROXY_SERVER_PORT_MIN   10000
#define PROXY_SERVER_PORT_MAX   65535

@interface ESPProxyServer()

@property (nonatomic, assign) __block BOOL isStarted;
@property (nonatomic, assign) __block int localPort;
@property (nonatomic, strong) __block AcceptTaskThread *acceptTaskThread;
@property (nonatomic, strong) __block OfferTaskThread *offerTaskThread;

@end

@implementation ESPProxyServer

DEFINE_SINGLETON_FOR_CLASS(ProxyServer, ESP)

- (instancetype)init
{
    self = [super init];
    if (self) {
        _localPort = -1;
        _isStarted = NO;
        _taskBlockArray = [[ESPBlockingMutableArray alloc]init];
    }
    return self;
}

- (void) openServer
{
    while (YES) {
        int port = arc4random() % (PROXY_SERVER_PORT_MAX - PROXY_SERVER_PORT_MIN) + PROXY_SERVER_PORT_MIN;
        _socketServer = [[ESPSocketServer2 alloc]initWithPort:port];
        if (_socketServer!=nil) {
            _localPort = port;
            break;
        } else {
            NSLog(@"ESPProxyServer openServer socketServer fail for port=%d",port);
        }
    }
}

- (void) closeServer
{
    [_socketServer close];
}

/**
 * start the ESPProxyServer
 */
- (void) start
{
    @synchronized(self) {
        [ESPMeshLog debug:DEBUG_ON Class:[self class] Message:@"ESPProxyServer start() entrance"];
        
        if (_isStarted) {
            [self stop];
        }
        
        // Start ESPMeshSocketManager
        [[ESPMeshSocketManager sharedMeshSocketManager]start];
        
        // Open server
        [self openServer];
        
        // Start accept task thread
        _acceptTaskThread = [[AcceptTaskThread alloc]initWithServer:self];
        [_acceptTaskThread startThread];
        
        // Start offer task thread
        _offerTaskThread = [[OfferTaskThread alloc]initWithServer:self];
        [_offerTaskThread startThread];
        
        _isStarted = YES;
    }
}

/**
 * stop the ESPProxyServer
 */
- (void) stop
{
    @synchronized(self) {
        [ESPMeshLog debug:DEBUG_ON Class:[self class] Message:@"EspProxyServer stop() entrance"];
        
        _isStarted = NO;
        
        // Close offer proxy task thread
        if (_offerTaskThread != nil) {
            [_offerTaskThread stopThread];
            _offerTaskThread = nil;
        }
        [_taskBlockArray removeAllObjects];
        [_taskBlockArray clearInterrupt];
        
        // Close server
        [self closeServer];
        // Close accept task thread
        if (_acceptTaskThread != nil) {
            [_acceptTaskThread stopThread];
            _acceptTaskThread = nil;
        }
        
        // Stop ESPMeshSocketManager
        [[ESPMeshSocketManager sharedMeshSocketManager]stop];
    }
}

/**
 * get the ESPProxyServer port
 *
 * @return the ESPProxyServer port
 */
- (int) getEspProxyServerPort
{
    @synchronized(self) {
        if (!_isStarted) {
            NSString *msg = @"getEspProxyServerPort() should be called after start()";
            [ESPMeshLog error:DEBUG_ON Class:[self class] Message:msg];
            NSString *exceptionName = @"ESPProxyServer-getEspProxyServerPort";
            NSString *exceptionReaseon = @"getEspProxyServerPort() should be called after start()";
            NSException *e = [ESPIllegalStateException exceptionWithName:exceptionName reason:exceptionReaseon userInfo:nil];
            @throw e;
        }
        return _localPort;
    }
}

@end
