//
//  ESPDeviceStateMachineHandler.m
//  suite
//
//  Created by 白 桦 on 7/26/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import "ESPDeviceStateMachineHandler.h"
#import "ESPActivateLocalTaskHandler.h"
#import "ESPActivateInternetTaskHandler.h"
#import "ESPBaseApiUtil.h"
#import "ESPRandomUtil.h"
#import "ESPUser.h"
#import "ESPConstantsNotification.h"
#import "ESPCommandDeviceRenameInternet.h"

#define DEBUG_ON_ESP_STATEMACHINE_HANDLER

#pragma mark-interfaces

@interface ESPTaskActivateLocal()

@property (nonatomic, strong) ESPDevice *espDeviceConfigure;
@property (nonatomic, unsafe_unretained) id<TaskDelegate> delegate;

@end

@interface ESPTaskActivateInternet()

@property (nonatomic, strong) ESPDevice *espDeviceConfigure;
@property (nonatomic, strong) ESPDevice *espDeviceResult;
@property (nonatomic, unsafe_unretained) id<TaskDelegate> delegate;

@end

@interface ESPDeviceStateMachineHandler()

@property (nonatomic, strong) ESPActivateLocalTaskHandler *espHandlerLocal;
@property (nonatomic, strong) ESPActivateInternetTaskHandler *espHandlerInternet;
@property (nonatomic, strong) NSMutableArray *espTasks;
@property (nonatomic, strong) NSMutableArray *espSucTaskBssids;
@property (nonatomic, strong) NSMutableArray *espFailTaskBssids;

@end

#pragma mark-defines

#define kActivateLocalTimeout       20
#define kActivateLocalInterval      5

#define kActivateInternetTimeout    60
#define kActivateInternetInterval   1

#pragma mark-implementions

@implementation ESPTaskActivateLocal

-(void)initTasks
{
    [self initMainTask];
    [self initSubTaskSuc];
    [self initSubTaskFail];
}

-(void)initMainTask
{
    __block ESPTaskActivateLocal *blockSelf = self;
    self.espTaskBlock = ^{
        NSTimeInterval startTimestamp = [NSDate date].timeIntervalSince1970;
        if (![blockSelf isTaskStarted]) {
            [blockSelf setTaskStart];
        }
        // init parameters
        NSString *bssid = blockSelf.espDeviceConfigure.espBssid;
        NSString *inetAddr = blockSelf.espDeviceConfigure.espInetAddress;
        NSString *randomKey = [ESPRandomUtil random40];
        NSString *parentBssid = blockSelf.espDeviceConfigure.espParentDeviceBssid;
        ESPIOTAddress *iotAddress = nil;
        
        blockSelf.espDeviceConfigure.espDeviceKey = randomKey;
#ifdef DEBUG_ON_ESP_STATEMACHINE_HANDLER
        NSLog(@"%@ %@ randomKey:%@",[blockSelf class],NSStringFromSelector(_cmd),randomKey);
#endif
        
        // discover local iotAddress
        iotAddress = [ESPBaseApiUtil discoverDevice:bssid];
#ifdef DEBUG_ON_ESP_STATEMACHINE_HANDLER
        NSLog(@"%@ %@ iotAddress:%@",[blockSelf class],NSStringFromSelector(_cmd),iotAddress);
#endif
        inetAddr = iotAddress != nil ? iotAddress.espInetAddress : nil;
        parentBssid = iotAddress != nil ? iotAddress.espParentBssid : nil;
        
        // update
        if (iotAddress!=nil) {
            NSString *deviceKey = blockSelf.espDeviceConfigure.espDeviceKey;
            blockSelf.espDeviceConfigure = [[ESPDevice alloc]initWithIOTAddress:iotAddress];
            blockSelf.espDeviceConfigure.espDeviceKey = deviceKey;
        }
        
        // check whether parameters are valid
        if (inetAddr==nil) {
#ifdef DEBUG_ON_ESP_STATEMACHINE_HANDLER
            NSLog(@"%@ %@ sleep for interval start",[blockSelf class],NSStringFromSelector(_cmd));
#endif
            NSTimeInterval endTimestamp = [NSDate date].timeIntervalSince1970;
            [blockSelf sleepForIntervalStartTimestamp:startTimestamp EndTimestamp:endTimestamp];
#ifdef DEBUG_ON_ESP_STATEMACHINE_HANDLER
            NSLog(@"%@ %@ sleep for interval end",[blockSelf class],NSStringFromSelector(_cmd));
#endif
            return ESPTASK_EXECUTE_FAIL;
        }
        
        // do activate local action
        BOOL isSuc = [blockSelf.espDeviceConfigure doActionDeviceActivateLocalRandomKey:randomKey];
#ifdef DEBUG_ON_ESP_STATEMACHINE_HANDLER
        NSLog(@"%@ %@ %@",[blockSelf class],NSStringFromSelector(_cmd),isSuc?@"SUC":@"FAIL");
#endif
        
        // return result
        if (isSuc) {
            return ESPTASK_EXECUTE_SUC;
        } else {
#ifdef DEBUG_ON_ESP_STATEMACHINE_HANDLER
            NSLog(@"%@ %@ sleep for interval start",[blockSelf class],NSStringFromSelector(_cmd));
#endif
            NSTimeInterval endTimestamp = [NSDate date].timeIntervalSince1970;
            [blockSelf sleepForIntervalStartTimestamp:startTimestamp EndTimestamp:endTimestamp];
#ifdef DEBUG_ON_ESP_STATEMACHINE_HANDLER
            NSLog(@"%@ %@ sleep for interval end",[blockSelf class],NSStringFromSelector(_cmd));
#endif
            return ESPTASK_EXECUTE_FAIL;
        }
    };
}

-(void)initSubTaskSuc
{
    __block ESPTaskActivateLocal *blockSelf = self;
    ESPTask *taskSuc = [[ESPTask alloc]init];
    taskSuc.espBlock = ^{
#ifdef DEBUG_ON_ESP_STATEMACHINE_HANDLER
        NSLog(@"%@ %@",[blockSelf class],NSStringFromSelector(_cmd));
#endif
        ESPDeviceStateMachineHandler *handler = [ESPDeviceStateMachineHandler sharedDeviceStateMachineHandler];
        ESPTaskActivateInternet *task = [handler createTaskActivateInternet:blockSelf.espDeviceConfigure];
        [handler addTask:task];
#ifdef DEBUG_ON_ESP_STATEMACHINE_HANDLER
        NSLog(@"%@ %@ add activate internet task into handler",[blockSelf class],NSStringFromSelector(_cmd));
#endif
        [blockSelf.delegate onTaskDone:blockSelf TaskResult:ESPTASK_EXECUTE_SUC];
    };
    [self addSubTask2Suc:taskSuc];
}

-(void)initSubTaskFail
{
    __block ESPTaskActivateLocal *blockSelf = self;
    ESPTask *taskFail = [[ESPTask alloc]init];
    taskFail.espBlock = ^{
#ifdef DEBUG_ON_ESP_STATEMACHINE_HANDLER
        NSLog(@"%@ %@",[blockSelf class],NSStringFromSelector(_cmd));
#endif
        [blockSelf.delegate onTaskDone:blockSelf TaskResult:ESPTASK_EXECUTE_FAIL];
    };
    [self addSubTask2Fail:taskFail];
}

@end

@implementation ESPTaskActivateInternet

-(void)initTasks
{
    [self initMainTask];
    [self initSubTaskSuc];
    [self initSubTaskFail];
}

//-(void)[[NSNotificationCenter defaultCenter]postNotificationName:DEVICES_ARRIVE object:nil];
-(void)notifyNewDeviceAdd:(ESPDevice *)newDevice
{
    [[NSNotificationCenter defaultCenter]postNotificationName:ESPTOUCH_ADD_NEW_DEVICE object:self.espDeviceResult];
}

-(void)initMainTask
{
    __block ESPTaskActivateInternet *blockSelf = self;
    self.espTaskBlock = ^{
        NSTimeInterval startTimestamp = [NSDate date].timeIntervalSince1970;
        if (![blockSelf isTaskStarted]) {
            [blockSelf setTaskStart];
        }
        ESPUser *user = [ESPUser sharedUser];
        long long userId = user.espUserId;
        NSString *userKey = user.espUserKey;
        NSString *randomKey = blockSelf.espDeviceConfigure.espDeviceKey;
        
#ifdef DEBUG_ON_ESP_STATEMACHINE_HANDLER
        NSLog(@"%@ %@ randomKey: %@",[blockSelf class],NSStringFromSelector(_cmd),randomKey);
#endif
        blockSelf.espDeviceResult = [blockSelf.espDeviceConfigure doActionDeviceActivateInternetRandomKey:randomKey UserKey:userKey UserId:userId];
        
        if (blockSelf.espDeviceResult==nil) {
            NSTimeInterval endTimestamp = [NSDate date].timeIntervalSince1970;
#ifdef DEBUG_ON_ESP_STATEMACHINE_HANDLER
            NSLog(@"%@ %@ sleep for interval start",[blockSelf class],NSStringFromSelector(_cmd));
#endif
            [blockSelf sleepForIntervalStartTimestamp:startTimestamp EndTimestamp:endTimestamp];
#ifdef DEBUG_ON_ESP_STATEMACHINE_HANDLER
            NSLog(@"%@ %@ sleep for interval end",[blockSelf class],NSStringFromSelector(_cmd));
#endif
            return ESPTASK_EXECUTE_FAIL;
        } else {
#ifdef DEBUG_ON_ESP_STATEMACHINE_HANDLER
            NSLog(@"%@ %@ deviceResult:%@",[blockSelf class],NSStringFromSelector(_cmd),blockSelf.espDeviceResult);
#endif
            // do rename action if espDeviceResult.name != espDeviceConfigure.name
            if (![blockSelf.espDeviceResult.espDeviceName isEqualToString:blockSelf.espDeviceConfigure.espDeviceName]) {
                blockSelf.espDeviceResult.espDeviceName = blockSelf.espDeviceConfigure.espDeviceName;
                [user doActionRenameDevice:blockSelf.espDeviceResult DeviceName:blockSelf.espDeviceConfigure.espDeviceName Instantly:YES];
                
                ESPCommandDeviceRenameInternet *command = [[ESPCommandDeviceRenameInternet alloc]init];
                [command doCommandDeviceRenameInternet:blockSelf.espDeviceResult DeviceName:blockSelf.espDeviceResult.espDeviceName];
            }

            return ESPTASK_EXECUTE_SUC;
        }
    };
}

-(void)initSubTaskSuc
{
    __block ESPTaskActivateInternet *blockSelf = self;
    ESPTask *taskSuc = [[ESPTask alloc]init];
    taskSuc.espBlock = ^{
#ifdef DEBUG_ON_ESP_STATEMACHINE_HANDLER
        NSLog(@"%@ %@",[blockSelf class],NSStringFromSelector(_cmd));
#endif
        [blockSelf notifyNewDeviceAdd:blockSelf.espDeviceResult];
        [blockSelf.delegate onTaskDone:blockSelf TaskResult:ESPTASK_EXECUTE_SUC];
    };
    [self addSubTask2Suc:taskSuc];
}

-(void)initSubTaskFail
{
    __block ESPTaskActivateInternet *blockSelf = self;
    ESPTask *taskFail = [[ESPTask alloc]init];
    taskFail.espBlock = ^{
#ifdef DEBUG_ON_ESP_STATEMACHINE_HANDLER
        NSLog(@"%@ %@",[blockSelf class],NSStringFromSelector(_cmd));
#endif
        [blockSelf.delegate onTaskDone:blockSelf TaskResult:ESPTASK_EXECUTE_FAIL];
    };
    [self addSubTask2Fail:taskFail];
}

@end

@implementation ESPDeviceStateMachineHandler

DEFINE_SINGLETON_FOR_CLASS(DeviceStateMachineHandler, ESP)

- (instancetype)init
{
    self = [super init];
    if (self) {
        _espHandlerLocal = [ESPActivateLocalTaskHandler sharedActivateLocalTaskHandler];
        _espHandlerInternet = [ESPActivateInternetTaskHandler sharedActivateInternetTaskHandler];
        _espTasks = [[NSMutableArray alloc]init];
        _espSucTaskBssids = [[NSMutableArray alloc]init];
        _espFailTaskBssids = [[NSMutableArray alloc]init];
    }
    return self;
}

/**
 * create activate local task by device
 *
 * @param device the device to be activated by local
 */
- (ESPTaskActivateLocal *) createTaskActivateLocal:(ESPDevice *)device
{
    ESPTaskActivateLocal *task = [[ESPTaskActivateLocal alloc]initWithBssid:device.espBssid Timeout:kActivateLocalTimeout Interval:kActivateLocalInterval];
    task.espDeviceConfigure = device;
    task.delegate = self;
    return task;
}

/**
 * create activate internet task by device
 *
 * @param device the device to be activated by internet
 */
- (ESPTaskActivateInternet *) createTaskActivateInternet:(ESPDevice *)device
{
    ESPTaskActivateInternet *task = [[ESPTaskActivateInternet alloc]initWithBssid:device.espBssid Timeout:kActivateInternetTimeout Interval:kActivateInternetInterval];
    task.espDeviceConfigure = device;
    task.delegate = self;
    return task;
}

/**
 * add new task to be executed async
 *
 * @param task the task to be executed async
 */
- (void) addTask:(ESPTaskBase *) task
{
    @synchronized(self) {
        [self.espTasks addObject:task];
        if ([task isKindOfClass:[ESPTaskActivateLocal class]]) {
            [self.espHandlerLocal submit:task];
        } else if ([task isKindOfClass:[ESPTaskActivateInternet class]]) {
            [self.espHandlerInternet submit:task];
        } else {
            abort();
        }
    }
}

/**
 * cancell all tasks
 */
- (void) cancelAllTasks
{
    @synchronized(self) {
        for (ESPTaskBase *task in self.espTasks) {
            [task cancel];
        }
        [self.espTasks removeAllObjects];
        [self.espSucTaskBssids removeAllObjects];
        [self.espFailTaskBssids removeAllObjects];
    }
}

/**
 * check whether all tasks are done
 *
 * @return whether all tasks are done
 */
- (BOOL) isAllTasksDone
{
    BOOL isAllTasksDone;
    @synchronized(self) {
        isAllTasksDone = self.espTasks.count==0;
    }
    return isAllTasksDone;
}

/**
 * check whether the task is done
 *
 * @param bssid the device's bssid
 * @return whether the task is done
 */
- (BOOL) isTaskDone:(NSString *)bssid
{
    BOOL isTaskDone = YES;
    @synchronized(self) {
        for (ESPTaskBase *task in self.espTasks) {
            NSString *taskBssid = task.espBssid;
            if ([bssid isEqualToString:taskBssid]) {
                isTaskDone = NO;
                break;
            }
        }
    }
    return isTaskDone;
}

/**
 * check whether the task is suc
 *
 * @param bssid the device's bssid
 * @return whether the task is suc
 */
- (BOOL) isTaskSuc:(NSString *)bssid
{
    BOOL isTaskSuc = NO;
    BOOL isChecked = NO;
    @synchronized(self) {
        if ([self isTaskDone:bssid]) {
            // check suc bssids
            if (!isChecked) {
                for (NSString *bssidSuc in self.espSucTaskBssids) {
                    if ([bssidSuc isEqualToString:bssid]) {
                        isTaskSuc = YES;
                        isChecked = YES;
                        [self.espSucTaskBssids removeObject:bssidSuc];
                        break;
                    }
                }
            }
            // check fail bssids
            if (!isChecked) {
                for (NSString *bssidFail in self.espFailTaskBssids) {
                    if ([bssidFail isEqualToString:bssid]) {
                        isTaskSuc = NO;
                        isChecked = YES;
                        [self.espFailTaskBssids removeObject:bssidFail];
                        break;
                    }
                }
            }
            if (!isChecked) {
                abort();
            }
        }
    }
    return isTaskSuc;
}

// implement TaskDelegate
-(void) onTaskDone: (ESPTaskBase *)task TaskResult: (int)taskResult
{
#ifdef DEBUG_ON_ESP_STATEMACHINE_HANDLER
    NSLog(@"%@ %@ task:%@ taskResult:%d",[self class],NSStringFromSelector(_cmd),task,taskResult);
#endif
    @synchronized(self) {
        [self.espTasks removeObject:task];
        NSString *bssid = task.espBssid;
        switch (taskResult) {
            case ESPTASK_EXECUTE_SUC:

                if ([task isKindOfClass:[ESPTaskActivateLocal class]]) {
                    // ESPTaskActivateLocal suc isn't really suc
#ifdef DEBUG_ON_ESP_STATEMACHINE_HANDLER
                    NSLog(@"%@ %@ task:%@ task is finished",[self class],NSStringFromSelector(_cmd),task);
#endif
                } else {
#ifdef DEBUG_ON_ESP_STATEMACHINE_HANDLER
                    NSLog(@"%@ %@ task:%@ task is SUC",[self class],NSStringFromSelector(_cmd),task);
#endif
                    [self.espSucTaskBssids addObject:bssid];
                }
                break;
            case ESPTASK_EXECUTE_FAIL:
                if ([task isTaskExpired]) {
#ifdef DEBUG_ON_ESP_STATEMACHINE_HANDLER
                    NSLog(@"%@ %@ task:%@ task is expired",[self class],NSStringFromSelector(_cmd),task);
#endif
                    [self.espFailTaskBssids addObject:bssid];
                } else {
#ifdef DEBUG_ON_ESP_STATEMACHINE_HANDLER
                    NSLog(@"%@ %@ task:%@ task isn't expired FAIL",[self class],NSStringFromSelector(_cmd),task);
#endif
                    [self addTask:task];
                }
                break;
            default:
                abort();
        }
    }
}

@end
