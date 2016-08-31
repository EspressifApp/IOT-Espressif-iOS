//
//  ESPBlockingFinishThread.h
//  MeshProxy
//
//  Created by 白 桦 on 4/13/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ESPBlockingFinishThread : NSObject

@property (nonatomic, assign) __block BOOL isStart;

/**
 * start Threads init
 * abstract method
 */
- (void) startThreadsInit;

/**
 * end Threads destroy
 * abstract method
 */
- (void) endThreadsDestroy;

/**
 * start Thread
 */
- (void) startThread;

/**
 * stop Thread
 */
- (void) stopThread;

/**
 * execute some tasks
 * abstract method
 */
- (void) execute;

@end
