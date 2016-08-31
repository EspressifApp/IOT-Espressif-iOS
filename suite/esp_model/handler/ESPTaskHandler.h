//
//  ESPTaskHandler.h
//  suite
//
//  Created by 白 桦 on 7/18/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import <Foundation/Foundation.h>

#define ESPTASK_EXECUTE_SUC         0
#define ESPTASK_EXECUTE_FAIL        -1
#define ESPTASK_EXECUTE_UNDEFINED   -2

// return the result to determine which sub task will be executed next
typedef int (^ESPTaskBlock)(void);

/**
 * ESPTask only support 1 deep level subtasks at present
 * the sub task should have and only have espBlock
 */
@interface ESPTask : NSObject
// when the ESPTask is executed, only one of espTaskBlock and espBlock will be executed.
// espBlock is preferred to
@property (nonatomic, strong) ESPTaskBlock espTaskBlock;
@property (nonatomic, strong) dispatch_block_t espBlock;

/**
 * check whether the task is cancelled
 *
 * @return whether the task is cancelled
 */
-(BOOL) isCancelled;

/**
 * check whether the task is done
 *
 * @return whether the task is done
 */
-(BOOL) isDone;

/**
 * before the task is executed, it could be cancelled
 *
 * @return whether the task is cancelled or not
 */
-(BOOL) cancel;

/**
 * add sub task to execute when the task is executed suc
 *
 * @param subTaskSuc
 */
-(void) addSubTask2Suc:(ESPTask *)subTaskSuc;

/**
 * add sub task to execute when the task is executed fail
 *
 * @param subTaskFail
 */
-(void) addSubTask2Fail:(ESPTask *)subTaskFail;

@end

@interface ESPTaskHandler : NSObject

/**
 * init a concrete handler, it is usually a singleton class
 *
 * @param count the max count of threads supported at the same time
 * @param name the name of the task handler
 *
 * @return ESPTaskHandler
 */
- (instancetype) initWithExecutorsCount:(NSUInteger) count Name:(NSString *)name;

/**
 * submit the task to be executed async
 *
 * @param task the task to be executed
 *
 * @return whether the task is executed immediately
 */
- (BOOL) submit:(ESPTask *)task;

/**
 * check whether the all tasks are done
 *
 * @return whether the all tasks are done
 */
- (BOOL) isAllTasksDone;

/**
 * check whether there's at least one hander free
 *
 * @return whether there's at least one handler free
 */
- (BOOL) isHandlerAvailable;

@end

