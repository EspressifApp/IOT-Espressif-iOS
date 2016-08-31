//
//  ESPTaskBase.h
//  suite
//
//  Created by 白 桦 on 7/26/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import "ESPTaskHandler.h"

@interface ESPTaskBase : ESPTask

@property (readonly, nonatomic, strong) NSString *espBssid;

-(instancetype)initWithBssid:(NSString *)bssid Timeout:(NSTimeInterval) timeout Interval:(NSTimeInterval) interval;

/**
 * set task start
 */
-(void)setTaskStart;

/**
 * check whether the task is started
 *
 * @return whether the task is started
 */
-(BOOL)isTaskStarted;

/**
 * check whether the task is expired
 *
 * @return whether the task is expired
 */
-(BOOL)isTaskExpired;

/**
 * sleep for interval if necessary
 *
 * @param startTimestamp start timestamp
 * @param endTimestamp end timestamp
 */
-(void)sleepForIntervalStartTimestamp:(NSTimeInterval) startTimestamp EndTimestamp:(NSTimeInterval) endTimestamp;
/**
 * init main task and sub tasks belong to it
 */
-(void)initTasks;

@end
