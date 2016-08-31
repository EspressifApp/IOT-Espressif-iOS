//
//  ESPDeviceStateMachineHandler.h
//  suite
//
//  Created by 白 桦 on 7/26/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESPSingletonMacro.h"
#import "ESPDevice.h"
#import "ESPTaskBase.h"

@protocol TaskDelegate <NSObject>

-(void) onTaskDone: (ESPTaskBase *)task TaskResult: (int)taskResult;

@end

#pragma mark-interfaces

@interface ESPTaskActivateLocal : ESPTaskBase

@end

@interface ESPTaskActivateInternet : ESPTaskBase

@end

@interface ESPDeviceStateMachineHandler : NSObject<TaskDelegate>

DEFINE_SINGLETON_FOR_HEADER(DeviceStateMachineHandler, ESP)

/**
 * create activate local task by device
 *
 * @param device the device to be activated by local
 */
- (ESPTaskActivateLocal *) createTaskActivateLocal:(ESPDevice *)device;

/**
 * create activate internet task by device
 *
 * @param device the device to be activated by internet
 */
- (ESPTaskActivateInternet *) createTaskActivateInternet:(ESPDevice *)device;

/**
 * add new task to be executed async
 *
 * @param task the task to be executed async
 */
- (void) addTask:(ESPTaskBase *) task;

/**
 * cancell all tasks
 */
- (void) cancelAllTasks;

/**
 * check whether all tasks are done
 *
 * @return whether all tasks are done
 */
- (BOOL) isAllTasksDone;

/**
 * check whether the task is done
 *
 * @param bssid the device's bssid
 * @return whether the task is done
 */
- (BOOL) isTaskDone:(NSString *)bssid;

/**
 * check whether the task is suc
 *
 * @param bssid the device's bssid
 * @return whether the task is suc
 */
- (BOOL) isTaskSuc:(NSString *)bssid;

@end
