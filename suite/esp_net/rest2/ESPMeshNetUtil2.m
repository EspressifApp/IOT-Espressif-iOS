//
//  ESPMeshNetUtil2.m
//  MeshProxy
//
//  Created by 白 桦 on 5/3/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import "ESPMeshNetUtil2.h"
#import "ESPDeviceType.h"
#import "ESPBaseApiUtil.h"
#import "ESPUser.h"

#define DEBUG_ON                NO

#pragma mark - MeshDevice start

#define FAIL_TIME_TOLERANCE     1

@interface MeshDevice : NSObject
// mesh device's IOTAddress
@property (nonatomic, strong) __block ESPIOTAddress *iotAddress;

// how many children belong to the mesh device(excluding itself)
@property (nonatomic, assign) __block int childrenCount;

// whether the mesh device is processing
@property (nonatomic, assign) __block volatile BOOL isProcessing;

// whether the mesh device is processed
@property (nonatomic, assign) __block volatile BOOL isProcessed;

// whether the mesh device is processed suc
@property (nonatomic, assign) __block volatile BOOL isSuc;

@property (nonatomic, assign) __block volatile int failTime;

@property (nonatomic, strong) __block NSMutableArray *childrenArray;

- (instancetype) initWithBssid:(NSString *)bssid RootInetAddress:(NSString *)rootInetAddress ParentBssid:(NSString *)parentBssid DeviceType:(ESPDeviceType *)deviceType ChildrenCount:(int)childrenCount RomVersionCur:(NSString *)romVersionCur;

- (BOOL) addChild:(MeshDevice *)child;

- (void) setIsProcessedIsSuc:(BOOL) isSuc;
@end

@interface MeshDevice()

@end

@implementation MeshDevice

- (instancetype)init
{
    abort();
}

- (instancetype)initWithBssid:(NSString *)bssid RootInetAddress:(NSString *)rootInetAddress ParentBssid:(NSString *)parentBssid DeviceType:(ESPDeviceType *)deviceType ChildrenCount:(int)childrenCount RomVersionCur:(NSString *)romVersionCur
{
    self = [super init];
    if (self) {
        ESPIOTAddress *iotAddress = [[ESPIOTAddress alloc]initWithBssid:bssid InetAddress:rootInetAddress IsMeshDevice:YES];
        iotAddress.espParentBssid = parentBssid;
        iotAddress.espDeviceType = deviceType;
        iotAddress.espRomVersionCurrent = romVersionCur;
        _iotAddress = iotAddress;
        _childrenCount = childrenCount;
        _isProcessing = NO;
        _isProcessed = NO;
        _isSuc = NO;
        _failTime = 0;
        _childrenArray = [[NSMutableArray alloc]init];
    }
    return self;
}

- (BOOL) addChild:(MeshDevice *)child
{
    if ([_childrenArray containsObject:child]) {
        if (DEBUG_ON) {
            NSLog(@"ESPMeshNetUtil2 WARN: MeshDevice bssid: %@ has gotten the child bssid %@ already",_iotAddress.espBssid,child.iotAddress.espBssid);
        }
        return NO;
    } else {
        [_childrenArray addObject:child];
        return YES;
    }
}

- (void) setIsProcessed:(BOOL)isProcessed
{
    abort();
}

- (void) setIsProcessedIsSuc:(BOOL) isSuc
{
    if (isSuc) {
        _isProcessed = YES;
        _isSuc = YES;
        if (_failTime > 0) {
            if (DEBUG_ON) {
                NSLog(@"ESPMeshNetUtil2 INFO MeshDevice %@ retry %D time suc",_iotAddress.espBssid,_failTime);
            }
        }
    } else {
        ++_failTime;
        if (_failTime < FAIL_TIME_TOLERANCE) {
            _isProcessing = NO;
            _isProcessed = NO;
            if (DEBUG_ON) {
                NSLog(@"ESPMeshNetUtil2 DEBUG %@ retry %d time...",_iotAddress.espBssid,_failTime);
            }
        } else {
            _isProcessed = YES;
            _isSuc = NO;
            if (DEBUG_ON) {
                NSLog(@"ESPMeshNetUtil2 WARN %@ retry %d time fail",_iotAddress.espBssid,_failTime);
            }
        }
    }
}

- (BOOL) isEqual:(id)object
{
    if (self == object) {
        return YES;
    }
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    
    const MeshDevice *other = object;
    // IOTAddress determine the equality of MeshDevice
    return [_iotAddress isEqual:other.iotAddress];
}

- (NSString *) description
{
    NSMutableString *mstr = [[NSMutableString alloc]init];
    [mstr appendFormat:@"[MeshDevice bssid: %@, children bssids: ",_iotAddress.espBssid];
    for (MeshDevice *child in _childrenArray) {
        [mstr appendFormat:@"%@, ",child.iotAddress.espBssid];
    }
    [mstr appendString:@"]"];
    
    return [mstr copy];
}

@end

#pragma mark - MeshDevice end


//@class GetTopoTask;

@interface ESPMeshNetUtil2()

// declare these method here for GetTopoTask will call them
+ (MeshDevice *) queryMeshDevice:(NSString *)inetAddr Bssid:(NSString *)bssid;
+ (void) addNewDevices:(MeshDevice *)newDevice RootBssid:(NSString *)rootBssid DeviceArray:(NSArray *)deviceArray;

@end

@interface GetTopoTask : NSObject

- (void) start;

- (instancetype) initWithRootInetAddr:(NSString *)rootInetAddr RootBssid:(NSString *)rootBssid RootDevice:(MeshDevice *)rootDevice FreshDevice:(MeshDevice *)freshDevice MeshDeviceArray:(NSArray *)meshDeviceArray;

@property (nonatomic, strong) __block NSString *rootBssid;
@property (nonatomic, strong) __block MeshDevice *freshDevice;
@property (nonatomic, strong) __block NSArray *meshDeviceArray;

@end

@implementation ESPMeshNetUtil2

/*
 * {
 *    "parent": {
 *        "mac": "1a:fe:34:a1:06:8f",
 *        "ver": "v1.1.4t45772(o)"
 *     },
 *     "type": "Light",
 *     "num": 24,
 *     "children": [
 *     {
 *       "type": "Light",
 *       "mac": "18:fe:34:a2:c7:62",
 *       "ver": "v1.1.4t45772(o)",
 *       "num": 13
 *     },
 *     {
 *       "type": "Light",
 *       "mac": "18:fe:34:a1:06:d7",
 *       "ver": "v1.1.4t45772(o)"
 *       "num": 8
 *     }
 *     ],
 *     "mdev_mac": "18FE34A1090C"
 *     "ver": "v1.1.4t45772(o)"
 *  }
 */

/**
 * restore the bssid
 *
 * @param bssid like 18fe34abcdef or 18FE34ABCDEF
 * @return like 18:fe:34:ab:cd:ef
 */
+ (NSString *) restoreBssid:(NSString *)bssid
{
    NSMutableString *mstr = [[NSMutableString alloc]init];
    for(int index = 0; index < [bssid length]; index+=2) {
        [mstr appendString:[bssid substringWithRange:NSMakeRange(index, 2)]];
        if (index != [bssid length] - 2) {
            [mstr appendString:@":"];
        }
    }
    return [[mstr copy] lowercaseString];
}

+ (MeshDevice *) queryMeshDevice:(NSString *)inetAddr Bssid:(NSString *)bssid
{
    // build request
    if (DEBUG_ON) {
        NSLog(@"ESPMeshNetUtil2 DEBUG queryMeshDevice() inetAddr: %@, deviceBssid: %@",inetAddr,bssid);
    }
    NSString *uriStr = [NSString stringWithFormat:@"http://%@/config?command=mesh_info",inetAddr];
    // send request and receive response
    NSDictionary *jsonResult = [ESPBaseApiUtil GetForJson:uriStr Bssid:bssid Headers:nil];
    if (DEBUG_ON) {
        NSLog(@"ESPMeshNetUtil2 DEBUG queryMeshDevice() jsonResult: %@",jsonResult);
    }
    // check whether response is nil
    if (jsonResult == nil) {
        if (DEBUG_ON) {
            NSLog(@"ESPMeshNetUtil2 WARN queryMeshDevice() jsonResult is nil, return nil");
        }
        return nil;
    }
    // parse response
    MeshDevice *currentDevice = nil;
    
    @try {
        // parse current device
        NSString *currentParentBssid = [[jsonResult objectForKey:@"parent"] objectForKey:@"mac"];
        NSString *deviceTypeStr = [jsonResult objectForKey:@"type"];
        NSString *currentBssid = [self restoreBssid:[jsonResult objectForKey:@"mdev_mac"]];
        if (![currentBssid isEqualToString:bssid]) {
            if (DEBUG_ON) {
                NSLog(@"ESPMeshNetUtil2 WARN queryMeshDevice() currentBssid: %@, bssid: %@ aren't equal, return nil",currentBssid,bssid);
                return nil;
            }
        }
        ESPDeviceType *currentDeviceType = [ESPDeviceType resolveDeviceTypeByTypeName:deviceTypeStr];
        // json response "num" including device itself, thus -1
        int currentCount = [[jsonResult objectForKey:@"num"]intValue] - 1;
        // parse rom version
        NSString *romVersionCur = [jsonResult objectForKey:@"ver"];
        // build current device
        currentDevice = [[MeshDevice alloc]initWithBssid:bssid RootInetAddress:inetAddr ParentBssid:currentParentBssid DeviceType:currentDeviceType ChildrenCount:currentCount RomVersionCur:romVersionCur];
        // parse children device
        NSArray *jsonArrayChildren = [jsonResult objectForKey:@"children"];
        for (NSDictionary *jsonChild in jsonArrayChildren) {
            NSString *childDeviceTypeStr = [jsonChild objectForKey:@"type"];
            ESPDeviceType *childDeviceType = [ESPDeviceType resolveDeviceTypeByTypeName:childDeviceTypeStr];
            if (childDeviceType == nil) {
                // no more devices, so break
                break;
            }
            NSString *childBssid = [jsonChild objectForKey:@"mac"];
            // json response "num" excluding device itself
            int childCount = [[jsonChild objectForKey:@"num"]intValue];
            // build child device
            MeshDevice *childDevice = [[MeshDevice alloc]initWithBssid:childBssid RootInetAddress:inetAddr ParentBssid:currentBssid DeviceType:childDeviceType ChildrenCount:childCount RomVersionCur:romVersionCur];
            // add child device into current device's child array
            [currentDevice addChild:childDevice];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"ESPMeshNetUtil2 queryMeshDevice() exception:%@",exception);
    }
    
    if (DEBUG_ON) {
        NSLog(@"ESPMeshNetUtil2 DEBUG queryMeshDevice() currentDevice: %@",currentDevice);
    }
    return currentDevice;
}

+ (void) updateTempStaDeviceArray4:(NSString *)rootBssid DeviceArray:(NSArray *)meshDeviceArray
{
    ESPUser *user = [ESPUser sharedUser];
    NSMutableArray *meshDevices = [[NSMutableArray alloc]init];
    
    for (MeshDevice *meshDevice in meshDeviceArray) {
        ESPIOTAddress *iotAddress = [meshDevice iotAddress];
        iotAddress.espRootBssid = rootBssid;
        ESPDevice *device = [[ESPDevice alloc]initWithIOTAddress:iotAddress];
        if (device!=nil) {
            [meshDevices addObject:device];
        }
    }
    [user addDeviceTempArray:meshDevices];
    [user notifyDevicesArrive];
}

+ (BOOL) isMoreDevices:(MeshDevice *)rootDevice DeviceArray:(NSArray *)deviceArray
{
    @synchronized(self) {
        int totalNum = [rootDevice childrenCount] + 1;
        int totalProcessing = 0;
        int totalSuc = 0;
        int totalFail = 0;
        for (MeshDevice *device in deviceArray) {
            if ([device isProcessed]) {
                if ([device isSuc]) {
                    ++totalSuc;
                } else {
                    totalFail += ([device childrenCount] + 1);
                }
            } else if ([device isProcessing]) {
                ++totalProcessing;
            }
            
        }
//        NSLog(@"bh ESPMeshNetUtil2 isMoreDevices() totalNum: %d, totalProcessing: %d, totalSuc: %d, totalFail: %d",totalNum,totalProcessing,totalSuc,totalFail);
        return totalNum > totalProcessing + totalSuc + totalFail;
    }
}

+ (BOOL) hasDeviceProcessing:(NSArray *)deviceArray
{
    for (MeshDevice *meshDevice in deviceArray) {
        if ([meshDevice isProcessing]) {
            return YES;
        }
    }
    return NO;
}

+ (void) addNewDevices:(MeshDevice *)newDevice RootBssid:(NSString *)rootBssid DeviceArray:(NSMutableArray *)deviceArray
{
    NSMutableArray *newDeviceArray = [[NSMutableArray alloc]init];
    if (![deviceArray containsObject:newDevice]) {
        [newDeviceArray addObject:newDevice];
    }
    [newDeviceArray addObjectsFromArray:[newDevice childrenArray]];
    
    for (MeshDevice *newDeviceInArray in newDeviceArray) {
        if ([deviceArray containsObject:newDeviceInArray]) {
            if (DEBUG_ON) {
                NSLog(@"ESPMeshNetUtil2 WARN addNewDevices() newDeviceInArray: %@ is in deviceArray already",newDeviceInArray);
            }
        } else {
            [deviceArray addObject:newDeviceInArray];
        }
    }
    
    [self updateTempStaDeviceArray4:rootBssid DeviceArray:newDeviceArray];
}

+ (MeshDevice *) getFreshDevice2:(MeshDevice *)rootDevice DeviceArray:(NSArray *)deviceArray
{
    @synchronized(self) {
        for (MeshDevice *device in deviceArray) {
            if (![device isProcessed] && ![device isProcessing]) {
                [device setIsProcessing:YES];
                return device;
            }
        }
    }
    return nil;
}

+ (int) getExecutedTaskCount:(NSArray *)deviceArray
{
    @synchronized(self) {
        int count = 0;
        for (MeshDevice *device in deviceArray) {
            if ([device isProcessing]) {
                ++count;
            }
        }
        return count;
    }
}

+ (void) buildResultArray:(NSMutableArray *)iotAddressArray DeviceArray:(NSArray *)meshDeviceArray
{
    for (MeshDevice *meshDevice in meshDeviceArray) {
        [iotAddressArray addObject:[meshDevice iotAddress]];
    }
}

+ (NSArray *) getTopoIOTAddressArray5:(NSString *)rootInetAddr RootBssid:(NSString *)rootBssid
{
    NSMutableArray *iotAddressArray = [[NSMutableArray alloc]init];
    // query root mesh device
    MeshDevice *rootDevice = [self queryMeshDevice:rootInetAddr Bssid:rootBssid];
    
    rootDevice.iotAddress.espParentBssid = nil;
    
    NSMutableArray *meshDeviceArrayAtomic = [[NSMutableArray alloc]init];
    
    const int MAX_PROCESSING_TASK = 20;
    
    if (rootDevice != nil) {
        // root device clear processing
        [rootDevice setIsProcessing:NO];
        // root device set processed
        [rootDevice setIsProcessedIsSuc:YES];
        // add devices
        [self addNewDevices:rootDevice RootBssid:rootBssid DeviceArray:meshDeviceArrayAtomic];
        
        BOOL isTaskArrayEmptyLast = NO;
        BOOL isBreakTaskArrayEmpty = NO;
        BOOL isSleepy = NO;
        // check whether there're more devices
        BOOL isMoreDevices = [self isMoreDevices:rootDevice DeviceArray:meshDeviceArrayAtomic];
        while (isMoreDevices) {
            int executedTaskCount;
            @synchronized(meshDeviceArrayAtomic) {
                executedTaskCount = [self getExecutedTaskCount:meshDeviceArrayAtomic];
            }
            
            // check whether the main task is sleepy
            isSleepy = executedTaskCount >= MAX_PROCESSING_TASK;
            
            @synchronized(meshDeviceArrayAtomic) {
                // distribute tasks
                for (int taskIndex = 0; taskIndex < MAX_PROCESSING_TASK - executedTaskCount; ++taskIndex) {
                    // get fresh device
                    MeshDevice *freshDevice = [self getFreshDevice2:rootDevice DeviceArray:meshDeviceArrayAtomic];
                    if (freshDevice == nil) {
                        if (DEBUG_ON) {
                            NSLog(@"ESPMeshNetUtil2 DEBUG getTopoIOTAddressArray5() no fresh devices, so sleepy and break");
                        }
                        isSleepy = YES;
                        if (executedTaskCount == 0) {
                            if (isTaskArrayEmptyLast) {
                                if (DEBUG_ON) {
                                    NSLog(@"ESPMeshNetUtil2 INFO getTopoIOTAddressArray5() isBreakTaskArrayEmpty = YES");
                                }
                                isBreakTaskArrayEmpty = YES;
                            }
                            else {
                                if (DEBUG_ON) {
                                    NSLog(@"ESPMeshNetUtil2 INFO getTopoIOTAddressArray5() isTaskArrayEmptyLast = YES");
                                }
                                isTaskArrayEmptyLast = YES;
                            }
                        } else {
                            isTaskArrayEmptyLast = NO;
                        }
                        break;
                    } else {
                        isTaskArrayEmptyLast = NO;
                        GetTopoTask *task = [[GetTopoTask alloc]initWithRootInetAddr:rootInetAddr RootBssid:rootBssid RootDevice:rootDevice FreshDevice:freshDevice MeshDeviceArray:meshDeviceArrayAtomic];
                        [task start];
                    }
                }
            }
            
            if (isBreakTaskArrayEmpty) {
                if (DEBUG_ON) {
                    NSLog(@"ESPMeshNetUtil2 WARN getTopoIOTAddressArray5() device number exist err, no more devices exist, so break, [meshDeviceArrayAtomic count] is %d",(int)[meshDeviceArrayAtomic count]);
                }
                break;
            }
            
            @synchronized(meshDeviceArrayAtomic) {
                // check whether there're more devices
                isMoreDevices = [self isMoreDevices:rootDevice DeviceArray:meshDeviceArrayAtomic];
            }
            
            // sleep some time if necessary
            if (isMoreDevices && isSleepy) {
                if (DEBUG_ON) {
                    NSLog(@"ESPMeshNetUtil2 DEBUG getTopoIOTAddressArray5() sleep some time");
                    [NSThread sleepForTimeInterval:2.0];
                }
            }
        }
    }
    
    BOOL hasDeviceProcessing = NO;
    // wait all tasks finished
    @synchronized(meshDeviceArrayAtomic) {
        hasDeviceProcessing = [self hasDeviceProcessing:meshDeviceArrayAtomic];
    }
    while (hasDeviceProcessing) {
        if (DEBUG_ON) {
            NSLog(@"ESPMeshNetUtil2 INFO getTopoIOTAddressArray5() sleep 100ms waiting for all tasks finished");
        }
        [NSThread sleepForTimeInterval:0.1];
        @synchronized(meshDeviceArrayAtomic) {
            hasDeviceProcessing = [self hasDeviceProcessing:meshDeviceArrayAtomic];
        }

    }
    
    [self buildResultArray:iotAddressArray DeviceArray:meshDeviceArrayAtomic];
    return iotAddressArray;
}

+ (ESPIOTAddress *) getTopoIOTAddress5:(NSString *)rootInetAddress Bssid:(NSString *)bssid
{
    MeshDevice *meshDevice = [self queryMeshDevice:rootInetAddress Bssid:bssid];
    return meshDevice != nil ? [meshDevice iotAddress] : nil;
}

+ (ESPIOTAddress *) GetTopoIOTAddress5:(NSString *)rootInetAddress Bssid:(NSString *)bssid
{
    ESPIOTAddress *iotAddress = [self getTopoIOTAddress5:rootInetAddress Bssid:bssid];
    if (DEBUG_ON) {
        NSLog(@"ESPMeshNetUtil2 DEBUG GetTopoIOTAddress5(rootInetAddress=[%@],bssid=[%@]): %@",rootInetAddress,bssid,iotAddress);
    }
    return iotAddress;
}

+ (NSArray *) GetTopoIOTAddressArray5:(NSString *)rootInetAddress RootBssid:(NSString *)rootBssid;
{
    NSArray *iotAddressArray = [self getTopoIOTAddressArray5:rootInetAddress RootBssid:rootBssid];
    if (DEBUG_ON) {
        NSLog(@"ESPMeshNetUtil2 DEBUG GetTopoIOTAddress5(rootInetAddress=[%@],rootBssid=[%@]): %@",rootInetAddress,rootBssid,iotAddressArray);
    }
    return iotAddressArray;
}

@end


#pragma mark - GetTopoTask start



@implementation GetTopoTask

- (instancetype)init
{
    abort();
}

- (instancetype)initWithRootInetAddr:(NSString *)rootInetAddr RootBssid:(NSString *)rootBssid RootDevice:(MeshDevice *)rootDevice FreshDevice:(MeshDevice *)freshDevice MeshDeviceArray:(NSArray *)meshDeviceArray
{
    self = [super init];
    if (self) {
        _rootBssid = rootBssid;
        _freshDevice = freshDevice;
        _meshDeviceArray = meshDeviceArray;
    }
    return self;
}

- (void) run
{
    // query mesh device
    NSString *inetAddr = _freshDevice.iotAddress.espInetAddress;
    NSString *deviceBssid = _freshDevice.iotAddress.espBssid;
    MeshDevice *queryDevice = [ESPMeshNetUtil2 queryMeshDevice:inetAddr Bssid:deviceBssid];
    // process query device
    if (queryDevice == nil) {
        [_freshDevice setIsProcessedIsSuc:NO];
    } else {
        // meshDeviceArray is atomic
        // add devices
        @synchronized(_meshDeviceArray) {
            [ESPMeshNetUtil2 addNewDevices:queryDevice RootBssid:_rootBssid DeviceArray:_meshDeviceArray];
        }
        
        [_freshDevice setIsProcessedIsSuc:YES];
        
        for (MeshDevice *childMeshDevice in [queryDevice childrenArray]) {
            if ([childMeshDevice childrenCount] == 0) {
                [childMeshDevice setIsProcessedIsSuc:YES];
            }
        }
    }
    
    [_freshDevice setIsProcessing:NO];
}

- (void) start
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        [self run];
    });
}

@end

#pragma mark - GetTopoTask end