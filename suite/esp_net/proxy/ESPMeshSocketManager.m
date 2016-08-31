//
//  ESPMeshSocketManager.m
//  MeshProxy
//
//  Created by 白 桦 on 4/13/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import "ESPMeshSocketManager.h"
#import "ESPBlockingFinishThread.h"
#import "ESPInterruptException.h"

#import "ESPMeshSocket.h"
#import "ESPMeshLog.h"

#define DEBUG_ON    NO

#pragma LoopCheckThread
@interface LoopCheckThread : ESPBlockingFinishThread

- (instancetype)initWithManager:(ESPMeshSocketManager *)manager;

@end

@interface LoopCheckThread()

@property (nonatomic, assign) __block BOOL isInterrupted;
@property (nonatomic, weak) __block ESPMeshSocketManager* manager;

@end

@implementation LoopCheckThread

- (instancetype)initWithManager:(ESPMeshSocketManager *)manager
{
    self = [super init];
    if (self) {
        _isInterrupted = NO;
        _manager = manager;
    }
    return self;
}

- (void) print: (NSString *)msg
{
    [ESPMeshLog info:DEBUG_ON Class:[self class] Message:msg];
}

- (void) startThreadsInit
{
}

- (void) endThreadsDestroy
{
//    _isInterrupted = YES;
    [self interrupt];
}

- (void) interrupt
{
    _isInterrupted = YES;
    ESPMeshSocketManager *manager = _manager;
    if (manager!=nil) {
        [manager.meshSockeBlockArray interrupt];
    }
}

- (void) execute
{
    ESPMeshSocket *meshSocket;
    ESPMeshSocketManager *manager = _manager;
    if (manager==nil) {
        return;
    }
    ESPBlockingMutableArray *meshArray = manager.meshSockeBlockArray;
    while (super.isStart && !_isInterrupted) {
        // TODO log too much
//        [self print:[NSString stringWithFormat:@"LoopCheckThread mesh array size = %d", (int)[meshArray count]]];
        // wait new mesh socket
        BOOL isEmpty;
        @synchronized(meshArray) {
            isEmpty = [meshArray isEmpty];
        }
        if (isEmpty) {
            // try to wait an object
            @try {
                [meshArray wait];
            }
            @catch (ESPInterruptException *exception) {
                if (_isInterrupted) {
                    [self print:@"LoopCheckThread execute() is interrupted"];
                    break;
                } else {
                    NSLog(@"#######$$$$$$$LoopCheckThread execute() shouldn't execute here$$$$$$$#######");
                }
            }
        }
        
        for (int i = 0; i < [meshArray count]; i++) {
            meshSocket = [meshArray objectAtIndex:i];
            if ([meshSocket isClosed]) {
                [self print:[NSString stringWithFormat:@"LoopCheckThread %@ is closed or expired", [meshSocket getInetAddress]]];
                @synchronized(meshArray) {
                    [meshArray removeObjectAtIndex:i--];
                }
                NSArray *unExecutedTaskArray = [meshSocket getRefreshProxyTaskArray];
                for (ESPProxyTask *task in unExecutedTaskArray) {
                    [self print:[NSString stringWithFormat:@"LoopCheckThread %@ is accepted()",task]];
                    [manager accept:task];
                }
            } else {
                if ([meshSocket isExpired]) {
                    [self print:[NSString stringWithFormat:@"LoopCheckThread %@ halfClose()", meshSocket]];
                    [meshSocket halfClose];
                }
                if ([meshSocket isConnected]) {
                    // TODO log too much
//                    [self print:[NSString stringWithFormat:@"LoopCheckThread %@ checkProxyTaskStateAndProc()", meshSocket]];
                    [meshSocket checkProxyTaskStateAndProc];
                }
            }
        }
        
        [NSThread sleepForTimeInterval:0.1];
    }   // while end
    [self print:@"LookCheckThread finish"];
}

@end

@interface ESPMeshSocketManager()

@property (nonatomic, strong) __block LoopCheckThread *loopCheckThread;

@end

#pragma ESPMeshSocketManager
@implementation ESPMeshSocketManager

DEFINE_SINGLETON_FOR_CLASS(MeshSocketManager, ESP)

- (void) print: (NSString *)msg
{
    [ESPMeshLog info:DEBUG_ON Class:[self class] Message:msg];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _meshSockeBlockArray = [[ESPBlockingMutableArray alloc]init];
    }
    return self;
}

- (void) start
{
    @synchronized(self) {
        if (_loopCheckThread==nil) {
            [self print:@"start() start check loop"];
            _loopCheckThread = [[LoopCheckThread alloc]initWithManager:self];
            [_loopCheckThread startThread];
        } else {
            [self print:@"start() check loop thread has started"];
        }
    }
}

- (void) stop
{
    @synchronized(self) {
        if (_loopCheckThread!=nil) {
            [self print:@"stop() stop check loop"];
            [_loopCheckThread stopThread];
            _loopCheckThread = nil;
        } else {
            [self print:@"stop() check loop thread is null"];
        }
        [_meshSockeBlockArray removeAllObjects];
        [_meshSockeBlockArray clearInterrupt];
    }
}

- (void) accept: (ESPProxyTask *)task
{
    @synchronized(self) {
        ESPMeshSocket *taskSocket = nil;
        NSString *taskHostAddress = [task getTargetInetAddress];
        @synchronized(_meshSockeBlockArray) {
            for (int i = 0; i < [_meshSockeBlockArray count]; ++i) {
                ESPMeshSocket *socket = [_meshSockeBlockArray objectAtIndex:i];
                NSString *socketHostAddress = [socket getInetAddress];
                if ([socketHostAddress isEqualToString:taskHostAddress]) {
                    [self print:[NSString stringWithFormat:@"accept() task mesh socket exist: %@",taskHostAddress]];
                    taskSocket = socket;
                    [taskSocket offer:task];
                    break;
                }
            }
        }
        if (taskSocket==nil) {
            [self print:[NSString stringWithFormat:@"accept() new a task mesh socket: %@",taskHostAddress]];
            taskSocket = [[ESPMeshSocket alloc]initWithInetAddr:[task getTargetInetAddress]];
            [taskSocket offer:task];
            @synchronized(_meshSockeBlockArray) {
                [_meshSockeBlockArray addObject:taskSocket];
            }
        }
    }
}

@end
