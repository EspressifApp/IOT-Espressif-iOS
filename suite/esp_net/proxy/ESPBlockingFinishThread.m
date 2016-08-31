

//
//  ESPBlockingFinishThread.m
//  MeshProxy
//
//  Created by 白 桦 on 4/13/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import "ESPBlockingFinishThread.h"
#import "ESPBlockingMutableArray.h"
#import "ESPInterruptException.h"

@interface ESPBlockingFinishThread()

@property (nonatomic, strong) __block ESPBlockingMutableArray *finishArray;

@end

@implementation ESPBlockingFinishThread

+ (NSObject *) FINISH
{
    static dispatch_once_t predicate;
    static NSObject *FINISH;
    dispatch_once(&predicate, ^{
        FINISH = [[NSObject alloc]init];
    });
    return FINISH;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _finishArray = [[ESPBlockingMutableArray alloc]init];
        _isStart = NO;
    }
    return self;
}

/**
 * start Threads init
 * abstract method
 */
- (void) startThreadsInit
{
    assert(0);
    NSLog(@"ESPBlockingFinishThread startThreadsInit() is abstract, please implement it");
}

/**
 * end Threads destroy
 * abstract method
 */
- (void) endThreadsDestroy
{
    assert(0);
    NSLog(@"ESPBlockingFinishThread endThreadsDestroy() is abstract, please implement it");

}

/**
 * start Thread
 */
- (void) startThread
{
    @synchronized(self) {
        if (_isStart) {
            [self stopThread];
        }
        [self startThreadsInit];
        _isStart = YES;
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(queue, ^{
            [self run];
        });
    }
}

/**
 * stop Thread
 */
- (void) stopThread
{
    @synchronized(self) {
        if (_isStart) {
            [self endThreadsDestroy];
            _isStart = NO;
            [self waitFinish];
        }
    }
}

- (void) run
{
    [self execute];
    [self notifyFinish];
}

/**
 * execute some tasks
 * abstract method
 */
- (void) execute
{
    assert(0);
    NSLog(@"ESPBlockingFinishThread execute() is abstract, please implement it");
}

- (void) notifyFinish
{
    [_finishArray addObject:[ESPBlockingFinishThread FINISH]];
}

- (void) waitFinish
{
    @try {
        [_finishArray take];
    }
    @catch (ESPInterruptException *exception) {
        NSLog(@"ESPBlockingFinishThread waitFinish() catch ESPInterruptException");
    }
}

@end
