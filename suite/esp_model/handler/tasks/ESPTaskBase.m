//
//  ESPTaskBase.m
//  suite
//
//  Created by 白 桦 on 7/26/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import "ESPTaskBase.h"

@interface ESPTaskBase()

@property (nonatomic, assign) NSTimeInterval espTimeout;
@property (nonatomic, assign) NSTimeInterval espInterval;
@property (nonatomic, assign) NSTimeInterval espStartTimestamp;

@end

@implementation ESPTaskBase

-(instancetype)initWithBssid:(NSString *)bssid Timeout:(NSTimeInterval)timeout Interval:(NSTimeInterval)interval
{
    self = [super init];
    if (self) {
        _espBssid = bssid;
        _espTimeout = timeout;
        _espInterval = interval;
        _espStartTimestamp = 0;
        [self initTasks];
    }
    return self;
}

/**
 * set task start
 */
-(void)setTaskStart
{
    _espStartTimestamp = [[NSDate date]timeIntervalSince1970];
}

/**
 * check whether the task is started
 *
 * @return whether the task is started
 */
-(BOOL)isTaskStarted
{
    return _espStartTimestamp!=0;
}

/**
 * check whether the task is expired
 *
 * @return whether the task is expired
 */
-(BOOL)isTaskExpired
{
    NSTimeInterval now = [[NSDate date]timeIntervalSince1970];
    return now-_espStartTimestamp>_espTimeout;
}

/**
 * sleep for interval if necessary
 *
 * @param startTimestamp start timestamp
 * @param endTimestamp end timestamp
 */
-(void)sleepForIntervalStartTimestamp:(NSTimeInterval) startTimestamp EndTimestamp:(NSTimeInterval) endTimestamp
{
    NSTimeInterval cost = endTimestamp - startTimestamp;
    NSTimeInterval sleepTime = _espInterval - cost;
    if (sleepTime>0) {
        [NSThread sleepForTimeInterval:sleepTime];
    }
}

/**
 * init main task and sub tasks belong to it
 */
-(void)initTasks
{
    NSAssert(YES, @"initTasks() should be implemented by subclass");
}

@end
