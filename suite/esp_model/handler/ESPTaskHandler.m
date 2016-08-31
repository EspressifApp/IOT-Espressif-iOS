//
//  ESPTaskHandler.m
//  suite
//
//  Created by 白 桦 on 7/18/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import "ESPTaskHandler.h"

//#define DEBUG_ON_ESP_TASK_HANDLER

#pragma mark-interfaces

@interface ESPTask()

@property (nonatomic, weak) ESPTaskHandler *espTaskHandler;
@property (nonatomic, weak) ESPTask *espParentTask;
@property (nonatomic, strong) NSMutableArray *espSubTasks;
@property (nonatomic, assign) int espTaskToken;
@property (atomic, assign) BOOL espIsCancelled;
@property (atomic, assign) BOOL espIsDone;

@end

/**
 *
 * ESPHandler make it easy to check whether the dispatch_queue_t is busy
 *
 */
@interface ESPHandler : NSObject

@property (nonatomic, strong) dispatch_queue_t espDispatchQueue;
@property (atomic, assign) BOOL espIsBusy;
@property (nonatomic, strong) NSString *espHandlerName;
@property (nonatomic, assign) NSUInteger espHandlerIndex;
@property (nonatomic, strong) ESPTaskHandler *espTaskHandler;

-(instancetype) initWithName:(NSString *)name Index:(NSUInteger)index TaskHandler:(ESPTaskHandler *)taskHandler;

/**
 * execute the task
 * 
 * @param task the task to be executed
 */
-(void) execute:(ESPTask *)task;

@end

/**
 *
 * ESPTaskHandler is the intermediator between ESPTask and ESPHandler.
 * when new task coming, it will process it as follows:
 * 1. add task to the free queue
 * 2. try to offer the task to a free handler
 * 3. if all handlers are busy, donothing, when one task is finished call executeIfNecessary
 */
@interface ESPTaskHandler()


@property (nonatomic, strong) NSMutableArray *espHandlers;
@property (nonatomic, strong) NSMutableArray *espTasks;

/**
 *
 * @param targetTask the target task to be executed
 *
 * @return whether the task is executed or not(always NO when targetTask is nil)
 */
- (BOOL) executeIfNecessary:(ESPTask *)targetTask;

/**
 * cancel the task have been submitted, only the task not beginning will suc
 *
 * @param task the task to be canceled
 *
 * @return whether the task is canceled
 */
-(BOOL) cancel:(ESPTask *)task;

@end

#pragma mark-implementions

@implementation ESPTask

- (instancetype)init
{
    self = [super init];
    if (self) {
        _espParentTask = nil;
        _espTaskToken = ESPTASK_EXECUTE_UNDEFINED;
        _espIsCancelled = NO;
        _espIsDone = NO;
    }
    return self;
}

-(BOOL) isCancelled
{
    return self.espIsCancelled;
}

-(BOOL) isDone
{
    return self.espIsDone;
}

-(BOOL) cancel
{
    self.espIsCancelled = YES;
    self.espIsDone = YES;
    return [self.espTaskHandler cancel:self];
}

-(void) addSubTask2Suc:(ESPTask *)subTaskSuc
{
    subTaskSuc.espTaskToken = ESPTASK_EXECUTE_SUC;
    for (ESPTask *subTask in self.espSubTasks) {
        NSAssert(subTask.espTaskToken!=ESPTASK_EXECUTE_SUC, @"subtask for suc exist already");
    }
    subTaskSuc.espParentTask = self;
    [self.espSubTasks addObject:subTaskSuc];
}

-(void) addSubTask2Fail:(ESPTask *)subTaskFail
{
    subTaskFail.espTaskToken = ESPTASK_EXECUTE_FAIL;
    for (ESPTask *subTask in self.espSubTasks) {
        NSAssert(subTask.espTaskToken!=ESPTASK_EXECUTE_FAIL, @"subtask for fail exist already");
    }
    subTaskFail.espParentTask = self;
    [self.espSubTasks addObject:subTaskFail];
}

-(NSMutableArray *) espSubTasks
{
    if (!_espSubTasks) {
        _espSubTasks = [[NSMutableArray alloc]init];
    }
    return _espSubTasks;
}

@end

@implementation ESPHandler

-(instancetype) initWithName:(NSString *)name Index:(NSUInteger)index TaskHandler:(ESPTaskHandler *)taskHandler
{
    self = [super init];
    if (self) {
        _espIsBusy = NO;
        _espHandlerName = name;
        _espHandlerIndex = index;
        _espTaskHandler = taskHandler;
        NSString *queueName = [NSString stringWithFormat:@"%@-%i",name,index];
        _espDispatchQueue = dispatch_queue_create([queueName cStringUsingEncoding:NSUTF8StringEncoding], kNilOptions);
    }
    return self;
}

// only support 1 deep level subtasks at present
-(void) execute:(ESPTask *)task
{
#ifdef DEBUG_ON_ESP_TASK_HANDLER
    NSLog(@"%@ %@",[self class],NSStringFromSelector(_cmd));
#endif
    NSAssert(self.espDispatchQueue, @"espDispatchQueue shouldn't be nil");
    dispatch_async(self.espDispatchQueue, ^{
        self.espIsBusy = YES;
        if (task.espBlock!=nil) {
            // don't have subtasks
            task.espBlock();
#ifdef DEBUG_ON_ESP_TASK_HANDLER
            NSLog(@"%@ %@ espBlock",[self class],NSStringFromSelector(_cmd));
#endif
        } else if (task.espTaskBlock!=nil) {
            // process 1 deep level subtasks
            int taskResult = task.espTaskBlock();
#ifdef DEBUG_ON_ESP_TASK_HANDLER
            NSLog(@"%@ %@ espTaskBlock",[self class],NSStringFromSelector(_cmd));
#endif
            if (!task.isCancelled) {
                for (ESPTask *subTask in task.espSubTasks) {
                    if (taskResult==subTask.espTaskToken) {
                        if (subTask.espBlock!=nil) {
                            subTask.espBlock();
#ifdef DEBUG_ON_ESP_TASK_HANDLER
                            NSLog(@"%@ %@ espTaskBlock's child espBlock",[self class],NSStringFromSelector(_cmd));
#endif
                        }
                        break;
                    }
                }
            } else {
#ifdef DEBUG_ON_ESP_TASK_HANDLER
                NSLog(@"%@ %@ espTask is cancelled",[self class],NSStringFromSelector(_cmd));
#endif
            }
        }
#ifdef DEBUG_ON_ESP_TASK_HANDLER
        NSLog(@"%@ %@ executeIfNecessary",[self class],NSStringFromSelector(_cmd));
#endif
        self.espIsBusy = NO;
        [_espTaskHandler executeIfNecessary:nil];
        task.espIsDone = YES;
    });
}

@end

@implementation ESPTaskHandler

/**
 * init a concrete handler, it is usually a singleton class
 *
 * @param count the max count of threads supported at the same time
 * @param name the name of the task handler
 *
 * @return ESPTaskHandler
 */
- (instancetype) initWithExecutorsCount:(NSUInteger) count Name:(NSString *)name
{
    self = [super init];
    if (self) {
        NSAssert(count>0, @"count should more than 0");
        _espHandlers = [[NSMutableArray alloc]init];
        _espTasks = [[NSMutableArray alloc]init];
        for (NSUInteger index=0; index<count; index++) {
            name = [NSString stringWithFormat:@"%@-%@",[self class],name];
            ESPHandler *handler = [[ESPHandler alloc]initWithName:name Index:index TaskHandler:self];
            [_espHandlers addObject:handler];
        }
     }
    return self;
}

/**
 * submit the task to be executed async
 *
 * @param task the task to be executed
 *
 * @return whether the task is executed immediately
 */
- (BOOL) submit:(ESPTask *)task
{
    task.espTaskHandler = self;
    return [self executeIfNecessary:task];
}

- (BOOL) cancel:(ESPTask *)task
{
    @synchronized(self) {
        BOOL isSuc = NO;
        for(NSUInteger index=0;index<_espTasks.count;++index) {
            ESPTask *taskInArray = [_espTasks objectAtIndex:index];
            if (taskInArray==task) {
                isSuc = YES;
                [_espTasks removeObjectAtIndex:index];
                break;
            }
        }
        return isSuc;
    }
}

- (BOOL) executeIfNecessary:(ESPTask *)targetTask
{
#ifdef DEBUG_ON_ESP_TASK_HANDLER
    NSLog(@"%@ %@",[self class],NSStringFromSelector(_cmd));
#endif
    @synchronized(self) {
        BOOL isSuc = NO;
        NSUInteger indexOffset=0;
        // try to execute the elder tasks first
        for (NSUInteger index=indexOffset; _espTasks.count>0 && index<_espHandlers.count; ++index,++indexOffset) {
#ifdef DEBUG_ON_ESP_TASK_HANDLER
            NSLog(@"%@ %@ try to execute the elder task one time",[self class],NSStringFromSelector(_cmd));
#endif
            ESPHandler *handler = [_espHandlers objectAtIndex:index];
            if (!handler.espIsBusy) {
                ESPTask *task = [_espTasks objectAtIndex:0];
                [_espTasks removeObjectAtIndex:0];
                [handler execute:task];
            }
        }
        if (targetTask!=nil) {
            // try to execute the target task
            for (NSUInteger index=indexOffset; index<_espHandlers.count; ++index) {
#ifdef DEBUG_ON_ESP_TASK_HANDLER
                NSLog(@"%@ %@ try to execute the target task",[self class],NSStringFromSelector(_cmd));
#endif
                ESPHandler *handler = [_espHandlers objectAtIndex:index];
                if (!handler.espIsBusy) {
                    [handler execute:targetTask];
                    isSuc = YES;
                    break;
                }
            }
            // add targetTask into self.espTasks when not executed
            if (!isSuc) {
#ifdef DEBUG_ON_ESP_TASK_HANDLER
                NSLog(@"%@ %@ add target task into self.espTasks",[self class],NSStringFromSelector(_cmd));
#endif
                [_espTasks addObject:targetTask];
            }

        }
        return isSuc;
    }
}

/**
 * check whether the all tasks are done
 *
 * @return whether the all tasks are done
 */
- (BOOL) isAllTasksDone
{
    BOOL isAllTasksDone = YES;
    @synchronized(self) {
        for (ESPHandler *handler in _espHandlers) {
            if (handler.espIsBusy) {
                isAllTasksDone = NO;
                break;
            }
        }
    }
    return isAllTasksDone;
}

/**
 * check whether there's at least one hander free
 *
 * @return whether there's at least one handler free
 */
- (BOOL) isHandlerAvailable
{
    BOOL isHandlerAvailable = NO;
    @synchronized(self) {
        for (ESPHandler *handler in _espHandlers) {
            if (!handler.espIsBusy) {
                isHandlerAvailable = YES;
                break;
            }
        }
    }
    return isHandlerAvailable;
}

/**
 * these test code are used for debug
 *
+(void) test
{
    // situation1 task1,task2,task3 add together, task3 can't be executed immediately
    ESPTaskHandler *handler = [[ESPTaskHandler alloc]initWithExecutorsCount:2 Name:@"ESPTashHandlerTester"];
    ESPTask *task1 = [[ESPTask alloc]init];
    task1.espBlock = ^{
        NSLog(@"##########################################task1 is executing");
        [NSThread sleepForTimeInterval:1.0];
        NSLog(@"##########################################task1 is finished");
    };
    BOOL task1Result = [handler submit:task1];
    NSLog(@"##########################################task1 result is %@",task1Result?@"SUC":@"FAIL");
    ESPTask *task2 = [[ESPTask alloc]init];
    task2.espBlock = ^{
        NSLog(@"##########################################task2 is executing");
        [NSThread sleepForTimeInterval:1.0];
        NSLog(@"##########################################task2 is finished");
    };
    BOOL task2Result = [handler submit:task2];
    NSLog(@"##########################################task2 result is %@",task2Result?@"SUC":@"FAIL");
    ESPTask *task3 = [[ESPTask alloc]init];
    task3.espBlock = ^{
        NSLog(@"##########################################task3 is executing");
        [NSThread sleepForTimeInterval:1.0];
        NSLog(@"##########################################task3 is finished");
    };
    BOOL task3Result = [handler submit:task3];
    NSLog(@"##########################################task3 result is %@",task3Result?@"SUC":@"FAIL");
    // situation2 cancel task3 in situation
    BOOL task3Cancel = [task3 cancel];
    NSLog(@"##########################################task3 cancel is %@",task3Cancel?@"SUC":@"FAIL");
    // situation3 taskMaster has sub tasks of taskSuc and taskFail
    ESPTask *taskMaster = [[ESPTask alloc]init];
    taskMaster.espTaskBlock = ^{
        NSLog(@"##########################################taskMaster is executing");
        [NSThread sleepForTimeInterval:1.0];
        NSLog(@"##########################################taskMaster is finished");
//        return ESPTASK_EXECUTE_SUC;
        return ESPTASK_EXECUTE_FAIL;
    };
    ESPTask *taskSuc = [[ESPTask alloc]init];
    taskSuc.espBlock = ^{
        NSLog(@"##########################################taskMaster is suc");
    };
    [taskMaster addSubTask2Suc:taskSuc];
    ESPTask *taskFail = [[ESPTask alloc]init];
    taskFail.espBlock = ^{
        NSLog(@"##########################################taskMaster is failed");
    };
    [taskMaster addSubTask2Fail:taskFail];
    [handler submit:taskMaster];
    [taskMaster cancel];
    
    NSLog(@"task3:%@",task3.isDone?@"DONE":@"UNDONE");
    [NSThread sleepForTimeInterval:1.5];
    NSLog(@"task1:%@",task1.isDone?@"DONE":@"UNDONE");
}
 */

@end