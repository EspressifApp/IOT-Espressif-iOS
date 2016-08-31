//
//  ESPUser.m
//  suite
//
//  Created by 白 桦 on 5/23/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import "ESPUser.h"
#import "ESPDeviceState.h"
#import "ESPActionUesrLoginInternet.h"
#import "ESPActionUserRegisterInternet.h"
#import "ESPActionDeviceDiscoverInternetLocal.h"
#import "ESPActionDeviceGetStatusInternet.h"
#import "ESPActionDeviceGetStatusLocal.h"
#import "ESPActionDevicePostStatusInternet.h"
#import "ESPActionDevicePostStatusLocal.h"
#import "ESPActionDeviceUpgradeLocal.h"
#import "ESPActionDeviceUpgradeInternet.h"
#import "ESPActionDeviceRename.h"
#import "ESPActionDeviceDelete.h"
#import "ESPActionDeviceEsptouch.h"
#import "ESPConstantsNotification.h"
#import "ESPDeviceStateMachineHandler.h"
#import "ESPBaseApiUtil.h"
#import "ESPBssidUtil.h"
#import "ESPIOTAddress.h"
#import "ESP_NetUtil.h"
#import "ESPGlobalTaskHandler.h"
#import "DEspDeviceManager.h"
#import "DEspUserManager.h"

@interface ESPUser()

// the device array discovered by Local
@property (readonly, nonatomic, strong) NSMutableArray *deviceLocalArray;
// the device array discovered by Internet
@property (readonly, nonatomic, strong) NSMutableArray *deviceInternetArray;
// the device array to be transformed device state
@property (readonly, nonatomic, strong) NSMutableArray *deviceTransformArray;
// the temp local device array to be displayed on main UI
@property (readonly, nonatomic, strong) NSMutableArray *deviceTempArray;

@end

@implementation ESPUser

@synthesize espDeviceArray = _espDeviceArray;
@synthesize deviceLocalArray = _deviceLocalArray;
@synthesize deviceInternetArray = _deviceInternetArray;
@synthesize deviceTransformArray = _deviceTransformArray;
@synthesize deviceTempArray = _deviceTempArray;

DEFINE_SINGLETON_FOR_CLASS(User, ESP)

#pragma mark - init method

- (instancetype)init
{
    self = [super init];
    if (self) {
        _espDeviceArray = [[NSMutableArray alloc]init];
        _deviceLocalArray = [[NSMutableArray alloc]init];
        _deviceInternetArray = [[NSMutableArray alloc]init];
        _deviceTransformArray = [[NSMutableArray alloc]init];
        _deviceTempArray = [[NSMutableArray alloc]init];
    }
    return self;
}

#pragma mark - assistant method

/**
 * extract device according to bssid from device array
 *
 * @param bssid device's bssid
 * @deviceArray device array
 * @return first device of the same bssid from the device array
 */
- (ESPDevice *) extractDevice:(NSString *)bssid FromDeviceArray:(NSArray *)deviceArray
{
    for (ESPDevice *device in deviceArray) {
        if ([device.espBssid isEqualToString:bssid]) {
            return device;
        }
    }
    return nil;
}

/**
 * clone local device info to deviceDest from deviceOrigin
 *
 * @param deviceDest the dest device absorbing the device info
 * @param deviceOrigin the origin device offering the device info
 */
- (void) cloneLocalDeviceInfoTo:(ESPDevice *)deviceDest fromDevice:(ESPDevice *)deviceOrigin
{
#ifdef DEBUG
    NSLog(@"%@ %@ deviceDest:%@,deviceOrigin:%@",self.class,NSStringFromSelector(_cmd),deviceDest,deviceOrigin);
#endif
    // update device info - inetAddr
    deviceDest.espInetAddress = deviceOrigin.espInetAddress;
    // update device info - isMeshDevice
    deviceDest.espIsMeshDevice = deviceOrigin.espIsMeshDevice;
    // update device info - deviceType
    deviceDest.espDeviceType = deviceOrigin.espDeviceType;
    // update device info - parentDeviceBssid
    deviceDest.espParentDeviceBssid = deviceOrigin.espParentDeviceBssid;
    // update device info - rootDeviceBssid
    deviceDest.espRootDeviceBssid = deviceOrigin.espRootDeviceBssid;
    // update device info - rom version
    if (deviceOrigin.espRomVersionCurrent!=nil) {
        deviceDest.espRomVersionCurrent = deviceOrigin.espRomVersionCurrent;
    }
    
    // update device state
    ESPDeviceState *stateDest = deviceDest.espDeviceState;
    ESPDeviceState *stateOrigin = deviceOrigin.espDeviceState;
    if ([stateDest isStateActivating]) {
        // ignore when stateDest is activating
    } else {
        if ([stateOrigin isStateLocal]) {
            [stateDest clearStateOffline];
            [stateDest addStateLocal];
        } else if ([stateOrigin isStateOffline]) {
            [stateDest clearStateLocal];
            if (![stateDest isStateInternet]) {
                [stateDest addStateOffline];
            }
        } else if ([stateOrigin isStateInternet]) {
            // fix bug for renamed device activate
            [stateDest clearStateInternet];
            if (![stateDest isStateLocal]) {
                [stateDest addStateOffline];
            }
        } else {
            // it shouldn't run to here
            NSLog(@"%@ %@() deviceOrigin is illegal: %@",[self class],NSStringFromSelector(_cmd),deviceOrigin);
            abort();
        }
    }
}

/**
 * clone internet device info to deviceDest from deviceOrigin
 *
 * @param deviceDest the dest device absorbing the device info
 * @param deviceOrigin the origin device offering the device info
 */
- (void) cloneInternetDeviceInfoTo:(ESPDevice *)deviceDest fromDevice:(ESPDevice *)deviceOrigin
{
#ifdef DEBUG
    NSLog(@"%@ %@ deviceDest:%@,deviceOrigin:%@",self.class,NSStringFromSelector(_cmd),deviceDest,deviceOrigin);
#endif
    // update device info - userId
    deviceDest.espUserId = deviceOrigin.espUserId;
    // update device info - deviceKey
    deviceDest.espDeviceKey = deviceOrigin.espDeviceKey;
    // update device info - deviceId
    deviceDest.espDeviceId = deviceOrigin.espDeviceId;
    // update device info - deviceName if necessary
    if (!deviceDest.espDeviceState.isStateRenamed) {
        deviceDest.espDeviceName = deviceOrigin.espDeviceName;
    }
    
    // update device info - deviceType
    deviceDest.espDeviceType = deviceOrigin.espDeviceType;
    // update device info - isMeshDevice if necessary
    if (!deviceDest.espDeviceState.isStateLocal) {
        deviceDest.espIsMeshDevice = deviceOrigin.espIsMeshDevice;
    }
    // update device info - isOwner
    deviceDest.espIsOwner = deviceOrigin.espIsOwner;
    // update device info - parentDeviceBssid
    deviceDest.espParentDeviceBssid = deviceOrigin.espParentDeviceBssid;
    // update device info - romVersionCurrent
    // if romVersionCurrent is belong to local device ignore it
    BOOL romVersionCurIsLocal = NO;
    NSString *destRomVersionCur = deviceDest.espRomVersionCurrent;
    if (destRomVersionCur!=nil) {
        @synchronized (_deviceLocalArray) {
            for (ESPDevice *device in _deviceLocalArray) {
                if ([deviceDest.espBssid isEqualToString:device.espBssid]) {
                    if ([destRomVersionCur isEqualToString:device.espRomVersionCurrent]) {
                        romVersionCurIsLocal = YES;
                    }
                    break;
                }
            }
        }

    }
    if (!romVersionCurIsLocal) {
        deviceDest.espRomVersionCurrent = deviceOrigin.espRomVersionCurrent;
    }
    // update device info - romVersionLatest
    deviceDest.espRomVersionLatest = deviceOrigin.espRomVersionLatest;
    // update deivce info - activated timestamp
    deviceDest.espDeviceActivatedTimestamp = deviceOrigin.espDeviceActivatedTimestamp;
    
    // update device state
    ESPDeviceState *stateDest = deviceDest.espDeviceState;
    ESPDeviceState *stateOrigin = deviceOrigin.espDeviceState;
    
    if ([stateOrigin isStateInternet]) {
        [stateDest clearStateOffline];
        [stateDest addStateInternet];
    } else if ([stateOrigin isStateOffline]) {
        [stateDest clearStateInternet];
        if (![stateDest isStateLocal]) {
            [stateDest addStateOffline];
        }
    } else if ([stateOrigin isStateLocal]) {
        // this situation could be happen when _espDeviceArray has internet device
        // and the temp or local device update the device's state
        // ignore
    }
    else {
        // it shouldn't run to here
        NSLog(@"%@ %@() deviceOrigin is illegal: %@",[self class],NSStringFromSelector(_cmd),deviceOrigin);
        abort();
    }
    
    // update device deleted state
    if (stateOrigin.isStateDeleted) {
        [stateDest addStateDeleted];
    }
}

// update device internet name
- (void) updateDeviceInternet:(ESPDevice *)device
{
    @synchronized (_deviceInternetArray) {
        for (ESPDevice *deviceInternet in _deviceInternetArray) {
            if ([deviceInternet isEqual:device]) {
#ifdef DEBUG
                NSLog(@"%@ %@ device:%@",self.class,NSStringFromSelector(_cmd),deviceInternet);
#endif
                // update device internet name
                deviceInternet.espDeviceName = device.espDeviceName;
            }
        }
    }
}

/**
 * clone transform device info to deviceDest from deviceOrigin
 *
 * @param deviceDest the dest device absorbing the device info
 * @param deviceOrigin the origin device offering the device info
 */
- (void) cloneTransformDeviceInfoTo:(ESPDevice *)deviceDest fromDevice:(ESPDevice *)deviceOrigin
{
#ifdef DEBUG
    NSLog(@"%@ %@ deviceDest:%@,deviceOrigin:%@",self.class,NSStringFromSelector(_cmd),deviceDest,deviceOrigin);
#endif
    // update isUsing
    deviceDest.espIsUsing = deviceOrigin.espIsUsing;
    
    deviceDest._espIsRenamedJustNow = deviceOrigin._espIsRenamedJustNow;
    
    // update device info - deviceName if necessary
    if ([deviceOrigin.espDeviceState isStateRenamed]) {
        deviceDest.espDeviceName = deviceOrigin.espDeviceName;
        [deviceDest save];
        [self updateDeviceInternet:deviceOrigin];
    }
    
    // update device state
    ESPDeviceState *stateDest = deviceDest.espDeviceState;
    ESPDeviceState *stateOrigin = deviceOrigin.espDeviceState;
    stateDest.espStateValue = stateOrigin.espStateValue;
}

/**
 * clone temp device info to deviceDest from deviceOrigin
 *
 * @param deviceDest the dest device absorbing the device info
 * @param deviceOrigin the origin device offering the device info
 */
- (void) cloneTempDeviceInfoTo:(ESPDevice *)deviceDest fromDevice:(ESPDevice *)deviceOrigin
{
    [self cloneLocalDeviceInfoTo:deviceDest fromDevice:deviceOrigin];
}

// kind could be one of @"local",@"internet",@"transform",@"temp"
- (void) handleDeviceArray:(NSArray *)deviceArray MainDeviceArray:(NSMutableArray *)mainDeviceArray Kind: (NSString *)kind
{
    for (ESPDevice *deviceOrigin in deviceArray) {
        NSString *bssid = deviceOrigin.espBssid;
        ESPDevice *deviceDest = [self extractDevice:bssid FromDeviceArray:mainDeviceArray];
        if (deviceDest!=nil) {
            if ([kind isEqualToString:@"local"]) {
                if (!deviceDest.espIsUsing) {
                    // update local device info
                    [self cloneLocalDeviceInfoTo:deviceDest fromDevice:deviceOrigin];
                }
            } else if ([kind isEqualToString:@"internet"]) {
                if (!deviceDest.espIsUsing) {
                    // update internet device info
                    [self cloneInternetDeviceInfoTo:deviceDest fromDevice:deviceOrigin];
                    [deviceDest save];
                }
            } else if ([kind isEqualToString:@"transform"]) {
                // update transform device info
                [self cloneTransformDeviceInfoTo:deviceDest fromDevice:deviceOrigin];
            } else if ([kind isEqualToString:@"temp"]) {
                if (!deviceDest.espIsUsing) {
                    // update temp device info
                    [self cloneTempDeviceInfoTo:deviceDest fromDevice:deviceOrigin];
                }
            }
        } else {
            if ([kind isEqualToString:@"transform"]) {
#ifdef DEBUG
                NSLog(@"%@ %@() deviceDest:%@ can't be found",[self class],NSStringFromSelector(_cmd),deviceDest);
#endif
            } else {
                // add new device
                [mainDeviceArray addObject:deviceOrigin];
                // save device into db async
                [deviceOrigin save];
            }
        }
    }
}

/**
 * handle local device array on main device array
 * 
 * @param localDeviceArray local device array
 * @param mainDeviceArray main device mutable array
 */
- (void) handleLocalDeviceArray:(NSArray *)localDeviceArray MainDeviceArray:(NSMutableArray *)mainDeviceArray
{
    [self handleDeviceArray:localDeviceArray MainDeviceArray:mainDeviceArray Kind:@"local"];
}

/**
 * handle internet device array on main device array
 *
 * @param internetDeviceArray internet device array
 * @param mainDeviceArray main device array
 */
- (void) handleInternetDeviceArray:(NSArray *)internetDeviceArray MainDeviceArray:(NSMutableArray *)mainDeviceArray
{
    [self handleDeviceArray:internetDeviceArray MainDeviceArray:mainDeviceArray Kind:@"internet"];
}

/**
 * handle transform device array on main device array
 *
 * @param transformDeviceArray transform device array
 * @param mainDeviceArray main device array
 */
- (void) handleTransformDeviceArray:(NSArray *)transformDeviceArray MainDeviceArray:(NSMutableArray *)mainDeviceArray
{
    [self handleDeviceArray:transformDeviceArray MainDeviceArray:mainDeviceArray Kind:@"transform"];
}

/**
 * handle temp device array on main device array
 *
 * @param tempDeviceArray temp local device array
 * @param mainDeviceArray main device array
 */
- (void) handleTempDeviceArray:(NSArray *)tempDeviceArray MainDeviceArray:(NSMutableArray *)mainDeviceArray
{
    [self handleDeviceArray:tempDeviceArray MainDeviceArray:mainDeviceArray Kind:@"temp"];
}

/**
 * remove redundant devices on main device array
 *
 * @param mainDeviceMutableArray main device mutable array
 */
- (void) removeRedundantDevices:(NSMutableArray *)mainDeviceMutableArray
{
    for (int index=0; index < [mainDeviceMutableArray count]; ++index) {
        ESPDevice *device = [mainDeviceMutableArray objectAtIndex:index];
        if (device._espIsFromDatabase)
        {
            if (!device.espDeviceState.isStateActivating
                &&!device.espDeviceState.isStateConfiguring
                &&!device.espDeviceState.isStateUpgradeLocal
                &&!device.espDeviceState.isStateUpgradeInternet) {
                [device.espDeviceState clearStateLocal];
                [device.espDeviceState clearStateInternet];
                [device.espDeviceState addStateOffline];
            }
        }
        else if (![device.espDeviceState isStateNew]
                 &&![device.espDeviceState isStateConfiguring]
                 &&![device.espDeviceState isStateUpgradeLocal]
                 &&![device.espDeviceState isStateUpgradeInternet]
                 &&![device.espDeviceState isStateActivating]
                 &&![device.espDeviceState isStateDeleted]
                 &&![device.espDeviceState isStateRenamed]
                 // TODO - upgrade local/internet ok?
                 &&![device.espDeviceState isStateOffline]
                 )
        {
#ifdef DEBUG
            NSLog(@"%@ %@ device:%@",self.class,NSStringFromSelector(_cmd),device);
#endif
            [mainDeviceMutableArray removeObjectAtIndex:index--];
        }
    }
}

-(void) handleDeletedDevices
{
    // find deleted devices
    NSMutableArray *deletedDevices = [[NSMutableArray alloc]init];
    for (NSInteger i = _espDeviceArray.count-1; i>=0; --i) {
        ESPDevice *device = _espDeviceArray[i];
        if (device.espDeviceState.isStateDeleted) {
            [deletedDevices addObject:device];
            [_espDeviceArray removeObjectAtIndex:i];
#ifdef DEBUG
            NSLog(@"%@ %@ find deleted device:%@",self.class,NSStringFromSelector(_cmd),device);
#endif
        }
    }
    
    // process devices temp for deleted devices
    @synchronized (_deviceTempArray) {
        for (ESPDevice *deletedDevice in deletedDevices) {
            for (NSInteger i = _deviceTempArray.count-1; i>=0; --i) {
                ESPDevice *tempDevice = _deviceTempArray[i];
                if ([tempDevice.espBssid isEqualToString:deletedDevice.espBssid]) {
                    [_deviceTempArray removeObjectAtIndex:i];
#ifdef DEBUG
                    NSLog(@"%@ %@ remove temp device:%@",self.class,NSStringFromSelector(_cmd),tempDevice);
#endif
                }
            }
        }
    }
    
    // process devices local for deleted devices
    @synchronized (_deviceLocalArray) {
#ifdef DEBUG
        NSLog(@"%@ %@ remove local _deviceLocalArray:%@",self.class,NSStringFromSelector(_cmd),_deviceLocalArray);
#endif
        for (ESPDevice *deletedDevice in deletedDevices) {
            for (NSInteger i = _deviceLocalArray.count-1; i>=0; --i) {
                ESPDevice *localDevice = _deviceLocalArray[i];
                if ([localDevice.espBssid isEqualToString:deletedDevice.espBssid]) {
                    [_deviceLocalArray removeObjectAtIndex:i];
#ifdef DEBUG
                    NSLog(@"%@ %@ remove local device:%@",self.class,NSStringFromSelector(_cmd),localDevice);
#endif
                }
            }
        }
        
    }
    
    // process devices internet for deleted devices
    @synchronized (_deviceInternetArray) {
        for (ESPDevice *deletedDevice in deletedDevices) {
            for (NSInteger i = _deviceInternetArray.count-1; i>=0; --i) {
                ESPDevice *internetDevice = _deviceInternetArray[i];
                if ([internetDevice.espBssid isEqualToString:deletedDevice.espBssid]) {
                    [internetDevice.espDeviceState addStateDeleted];
#ifdef DEBUG
                    NSLog(@"%@ %@ add deleted state internetDevice device:%@",self.class,NSStringFromSelector(_cmd),internetDevice);
#endif
                }
            }
        }
    }
}

-(NSArray *) filterOfflineDevicesIfNecessary
{
    ESPUser *user = [ESPUser sharedUser];
    if (!user.espIsLogined) {
        NSMutableArray *devices = [NSMutableArray arrayWithArray:_espDeviceArray];
        for (NSInteger index=devices.count-1; index>=0; --index) {
            ESPDevice *device = devices[index];
            if (device.espDeviceState.isStateOffline) {
                [devices removeObjectAtIndex:index];
            }
        }
        return devices;
    } else {
        return _espDeviceArray;
    }
}

#pragma mark - get/set method

- (NSArray *) espDeviceArray
{
    @synchronized(_espDeviceArray) {
        // handle devices - transform
        NSArray *deviceTransformArray = self.deviceTransformArray;
        [self handleTransformDeviceArray:deviceTransformArray MainDeviceArray:_espDeviceArray];
        
        // remove redundant devices(remove unspecial state devices)
        [self removeRedundantDevices:_espDeviceArray];
        
        // handle devices - local
        NSArray *deviceLocalArray = self.deviceLocalArray;
        [self handleLocalDeviceArray:deviceLocalArray MainDeviceArray:_espDeviceArray];
        // handle devices - internet
        NSArray *deviceInternet = self.deviceInternetArray;
        [self handleInternetDeviceArray:deviceInternet MainDeviceArray:_espDeviceArray];
        // handle devices - temp
        NSArray *deviceTemp = self.deviceTempArray;
        [self handleTempDeviceArray:deviceTemp MainDeviceArray:_espDeviceArray];
        
        // handle deleted devices
        [self handleDeletedDevices];

#ifdef DEBUG
        NSLog(@"%@ %@ deviceArray:%@",self.class,NSStringFromSelector(_cmd),_espDeviceArray);
#endif

        // keep offline devices
        return [self filterOfflineDevicesIfNecessary];
    }
}

- (NSArray *) deviceLocalArray
{
    @synchronized(_deviceLocalArray) {
        NSArray *deviceLocalArray = [NSArray arrayWithArray:_deviceLocalArray];
        return deviceLocalArray;
    }
}

- (void) addDeviceLocal:(ESPDevice *)deviceLocal
{
    @synchronized(_deviceLocalArray) {
#ifdef DEBUG
        NSLog(@"%@ %@ deviceLocal:%@",[self class],NSStringFromSelector(_cmd),deviceLocal);
#endif
        if (deviceLocal==[ESPDevice ESP_DEVICE_INTERNET_EMPTY]) {
            // it shouldn't run to here
            NSLog(@"%@ %@() deviceLocal is illegal: %@",[self class],NSStringFromSelector(_cmd),deviceLocal);
            abort();
        } else if (deviceLocal==[ESPDevice ESP_DEVICE_INTERNET_UNACCESSIBLE]) {
            // it shouldn't run to here
            NSLog(@"%@ %@() deviceLocal is illegal: %@",[self class],NSStringFromSelector(_cmd),deviceLocal);
            abort();
        } else if (deviceLocal==[ESPDevice ESP_DEVICE_LOCAL_EMPTY]) {
            // when DEVICE_LOCAL_EMPTY is added, clear deviceLocalArray
            [_deviceLocalArray removeAllObjects];
            // [ESPDevice ESP_DEVICE_LOCAL_EMPTY] haven't be used now
            abort();
        } else {
            ESPDevice *deviceOrigin = deviceLocal;
            NSString *bssid = deviceOrigin.espBssid;
            // check whether the device is in deviceLocalArray already
            ESPDevice *deviceDest = [self extractDevice:bssid FromDeviceArray:_deviceLocalArray];
            if (deviceDest!=nil) {
                // update device info
                [self cloneLocalDeviceInfoTo:deviceDest fromDevice:deviceOrigin];
            } else {
#ifdef DEBUG
                NSLog(@"%@ %@ _deviceLocalArray add device:%@,localArray:%@",self.class,NSStringFromSelector(_cmd),deviceOrigin,_deviceLocalArray);
#endif
                // add new device
                [_deviceLocalArray addObject:deviceOrigin];
            }
        }
    }
}

- (void) updateDeviceLocalArray:(NSArray *)deviceLocalArray
{
    // clear and update or add
    @synchronized(_deviceLocalArray) {
#ifdef DEBUG
        NSLog(@"%@ %@ deviceLocalArray:%@",[self class],NSStringFromSelector(_cmd),deviceLocalArray);
#endif
        [_deviceLocalArray removeAllObjects];
        for (ESPDevice *deviceLocal in deviceLocalArray) {
            [self addDeviceLocal:deviceLocal];
        }
    }
}

- (NSArray *) deviceInternetArray
{
    @synchronized(_deviceInternetArray) {
        NSArray *deviceInternetArray = [NSArray arrayWithArray:_deviceInternetArray];
        return deviceInternetArray;
    }
}

- (void) addDeviceInternet:(ESPDevice *)deviceInternet
{
    @synchronized(_deviceInternetArray) {
#ifdef DEBUG
        NSLog(@"%@ %@ deviceInternet:%@",[self class],NSStringFromSelector(_cmd),deviceInternet);
#endif
        if (deviceInternet==[ESPDevice ESP_DEVICE_INTERNET_EMPTY]) {
            // when DEVICE_INTERNET_EMPTY is added, clear deviceInternetArray
            [_deviceInternetArray removeAllObjects];
        } else if (deviceInternet==[ESPDevice ESP_DEVICE_INTERNET_UNACCESSIBLE]) {
            // when DEVICE_INTERNET_UNACCESSIBLE is added, clear Internet State
            for (ESPDevice *device in _deviceInternetArray) {
                [device.espDeviceState clearStateInternet];
                [device.espDeviceState addStateOffline];
            }
        } else if (deviceInternet==[ESPDevice ESP_DEVICE_LOCAL_EMPTY]) {
            // it shouldn't run to here
            NSLog(@"%@ %@() deviceInternet is illegal: %@",[self class],NSStringFromSelector(_cmd),deviceInternet);
            abort();
        } else {
            ESPDevice *deviceOrigin = deviceInternet;
            NSString *bssid = deviceOrigin.espBssid;
            // check whether the device is in deviceInternetArray already
            ESPDevice *deviceDest = [self extractDevice:bssid FromDeviceArray:_deviceInternetArray];
            if (deviceDest!=nil) {
                if (!deviceDest.espDeviceState.isStateDeleted) {
                    // update device info
                    [self cloneInternetDeviceInfoTo:deviceDest fromDevice:deviceInternet];
                } else {
#ifdef DEBUG
                    NSLog(@"%@ %@ device:%@ has been deleted",self.class,NSStringFromSelector(_cmd),deviceDest);
#endif
                }
            } else {
                // add new device
                [_deviceInternetArray addObject:deviceInternet];
            }
        }
    }
}

// check device's is renamed just now and clear state of renamed if necessary
- (void) checkDeviceInternetArrayIsRenameJust
{
    @synchronized (_espDeviceArray) {
        for (ESPDevice *device in _espDeviceArray) {
            for (ESPDevice *deviceInternet in _deviceInternetArray) {
                // device==deviceInternet && device isStateRenamed && device !isRenamedJustNow
                if ([device isEqual:deviceInternet] && device.espDeviceState.isStateRenamed) {
                    if (device._espIsRenamedJustNow) {
#ifdef DEBUG
                        NSLog(@"%@ %@ device:%@ is renamed just now",self.class,NSStringFromSelector(_cmd),device);
#endif
                    } else {
                        deviceInternet.espDeviceName = device.espDeviceName;
                        [device.espDeviceState clearStateRenamed];
                        // save clear state renamed in local database
                        DEspDeviceManager *deviceManager = [DEspDeviceManager sharedDeviceManager];
                        DaoEspDevice *daoEspDevice = [deviceManager queryByDeviceKey:deviceInternet.espDeviceKey];
                        ESPDeviceState *deviceState = [[ESPDeviceState alloc]initWithState:daoEspDevice.espDeviceState.intValue];
                        [deviceState clearStateRenamed];
                        daoEspDevice.espDeviceState = [NSNumber numberWithInt:deviceState.espStateValue];
                        [device save];
                    }
                    break;
                }
            }
        }
    }
}

/**
 * remove internet array if necessary
 *
 * @param prevArray  previous internet array
 * @param curArray  current internet array
 * 
 *
 */
- (NSArray *) removeInteretArrayPrevArray:(NSArray *)prevArray CurArray:(NSArray *)curArray
{
    NSMutableArray *newArray = [[NSMutableArray alloc]init];
    // find the latest [ESPDevice ESP_DEVICE_INTERNET_UNACCESSIBLE] in cur array and process
    NSInteger index = NSNotFound;
    for (NSInteger i=curArray.count-1; i>=0; --i) {
        if ([ESPDevice ESP_DEVICE_INTERNET_UNACCESSIBLE]==curArray[i]) {
            index = i;
            break;
        }
    }
    if (index!=NSNotFound) {
        if (index==curArray.count-1) {
            // [ESPDevice ESP_DEVICE_INTERNET_UNACCESSIBLE] is in the end, just return it
            return @[[ESPDevice ESP_DEVICE_INTERNET_UNACCESSIBLE]];
        } else {
            for (NSInteger i=index+1; i<curArray.count; ++i) {
                [newArray addObject:curArray[i]];
            }
        }
    } else {
        [newArray addObjectsFromArray:curArray];
    }
    
    // process newArray by prevArray: remove device in prevArray but not in newArray
    //                                copy device deleted state in newArray from prevArray
    for (ESPDevice *prevDevice in prevArray) {
        NSInteger newIndex = [newArray indexOfObject:prevDevice];
        if (newIndex==NSNotFound) {
#ifdef DEBUG
            NSLog(@"%@ %@ removeByDeviceKey prevDevice:%@",self.class,NSStringFromSelector(_cmd),prevDevice);
#endif
            [prevDevice removeByDeviceKey];
        } else {
            if (prevDevice.espDeviceState.isStateDeleted) {
                ESPDevice *newDevice = newArray[newIndex];
                [newDevice.espDeviceState addStateDeleted];
                // do delete action
                ESPUser *user = [ESPUser sharedUser];
                [user doActionDeleteDevice:prevDevice Instantly:YES];
#ifdef DEBUG
                NSLog(@"%@ %@ copy deleted state newDevice:%@",self.class,NSStringFromSelector(_cmd),newDevice);
#endif
            }
        }
    }
    
    return newArray;
}

- (void) updateDeviceInternetArray:(NSArray *)deviceInternetArray
{
    @synchronized(_deviceInternetArray) {
#ifdef DEBUG
        NSLog(@"%@ %@ deviceInternetArray:%@",[self class],NSStringFromSelector(_cmd),deviceInternetArray);
#endif
        if (deviceInternetArray.count==1&&deviceInternetArray[0]==[ESPDevice ESP_DEVICE_INTERNET_UNACCESSIBLE]) {
            [self addDeviceInternet:deviceInternetArray[0]];
        } else {
            // remove internet array
            NSArray *newDeviceInternetArray = [self removeInteretArrayPrevArray:_deviceInternetArray CurArray:deviceInternetArray];
            // clear and add
            [_deviceInternetArray removeAllObjects];
            for (ESPDevice *deviceInternet in newDeviceInternetArray) {
                [self addDeviceInternet:deviceInternet];
            }
            // check device's is renamed just now and clear state of renamed if necessary
            [self checkDeviceInternetArrayIsRenameJust];
        }
    }
}

- (NSArray *) deviceTransformArray
{
    @synchronized(_deviceTransformArray) {
        NSArray *deviceTransformArray = [NSArray arrayWithArray:_deviceTransformArray];
        [_deviceTransformArray removeAllObjects];
        return deviceTransformArray;
    }
}

- (void) addDeviceTransform:(ESPDevice *)deviceTransform
{
    @synchronized(_deviceTransformArray) {
#ifdef DEBUG
        NSLog(@"%@ %@ deviceTransform:%@",[self class],NSStringFromSelector(_cmd),deviceTransform);
#endif
        [_deviceTransformArray addObject:deviceTransform];
    }
}

- (void) addDeviceTransformArray:(NSArray *)deviceTransformArray
{
    // add
    @synchronized(_deviceTransformArray) {
#ifdef DEBUG
        NSLog(@"%@ %@ deviceTransformArray:%@",[self class],NSStringFromSelector(_cmd),deviceTransformArray);
#endif
        [_deviceTransformArray addObjectsFromArray:deviceTransformArray];
    }
}

- (NSArray *) deviceTempArray
{
    @synchronized(_deviceTempArray) {
        NSArray *deviceTempArray = [NSArray arrayWithArray:_deviceTempArray];
        [_deviceTempArray removeAllObjects];
        return deviceTempArray;
    }
}

- (void) addDeviceTemp:(ESPDevice *)deviceTemp
{
    @synchronized(_deviceTempArray) {
#ifdef DEBUG
        NSLog(@"%@ %@ deviceTemp:%@",[self class],NSStringFromSelector(_cmd),deviceTemp);
#endif
        [_deviceTempArray addObject:deviceTemp];
    }
}

- (void) addDeviceTempArray:(NSArray *)deviceTempArray
{
    // update or add
    @synchronized(_deviceTempArray) {
#ifdef DEBUG
        NSLog(@"%@ %@ deviceTempArray:%@",[self class],NSStringFromSelector(_cmd),deviceTempArray);
#endif
        [_deviceTempArray addObjectsFromArray:deviceTempArray];
    }
}

#pragma mark - action

/**
 * get the current status of device(via local or internet) if local it will use local first
 *
 * @param device the device
 * @return whether the get action is suc
 */
- (BOOL) doActionGetDeviceStatusDevice:(ESPDevice *)device
{
    BOOL isLocal = [device.espDeviceState isStateLocal];
    if (isLocal) {
        ESPActionDeviceGetStatusLocal *actionLocal = [[ESPActionDeviceGetStatusLocal alloc]init];
        return [actionLocal doActionDeviceGetStatusLocalDevice:device];
    } else {
        ESPActionDeviceGetStatusInternet *actionInternet = [[ESPActionDeviceGetStatusInternet alloc]init];
        return [actionInternet doActionDeviceGetStatusInternetDevice:device];
    }
}

/**
 * post the status to device(via local or internet) if local it will use local first
 *
 * @param device the device
 * @param status the new status
 * @return whether the post action is suc
 */
-(BOOL) doActionPostDeviceStatusDevice:(ESPDevice *)device Status:(ESPDeviceStatus *)status
{
    BOOL isLocal = [device.espDeviceState isStateLocal];
    if (isLocal) {
        ESPActionDevicePostStatusLocal *actionLocal = [[ESPActionDevicePostStatusLocal alloc]init];
        return [actionLocal doActionDevicePostStatusLocalDevice:device Status:status];
    } else {
        ESPActionDevicePostStatusInternet *actionInternet = [[ESPActionDevicePostStatusInternet alloc]init];
        return [actionInternet doActionDevicePostStatusInternetDevice:device Status:status];
    }
}

/**
 * an easy API for doActionRefreshDevices:(BOOL) and doActionRefreshStaDevices:(BOOL)
 * after logining, doActionRefreshDevices:(BOOL) will be invoked, vice versa
 *
 * @param isSyn whether execute it syn or asyn
 */
-(void) doActionRefreshAllDevices:(BOOL) isSyn
{
    if (self.espIsLogined) {
        [self doActionRefreshDevices:isSyn];
    } else {
        [self doActionRefreshStaDevices:isSyn];
    }
}

/**
 * refresh the devices's status belong to the Player. it will check whether the device is Local , Internet ,
 * Offline, or Coexist of Local and Internet in the background thread. after it is finished, the NSNotification of
 * DEVICES_ARRIVE (@see ESPConstantsNotification) will sent. when ESPUser receive the broadcast, he should
 * refresh the UI
 *
 * @param isSyn whether execute it syn or asyn
 */
-(void) doActionRefreshDevices:(BOOL) isSyn
{
    ESPActionDeviceDiscoverInternetLocal *action = [[ESPActionDeviceDiscoverInternetLocal alloc]init];
    [action doActionDeviceDiscoverInternetLocal:isSyn UserKey:self.espUserKey];
}

/**
 * it is like {@link #doActionRefreshDevices()}, but it only refresh sta devices
 *
 * @param isSyn whether execute it syn or asyn
 */
-(void) doActionRefreshStaDevices:(BOOL) isSyn
{
    ESPActionDeviceDiscoverInternetLocal *action = [[ESPActionDeviceDiscoverInternetLocal alloc]init];
    [action doActionDeviceDiscoverLocal:isSyn];
}

/**
 * upgrade the device by local
 *
 * @param device the device to be upgraded
 * @return whether the device upgrade local suc
 */
-(BOOL) doActionUpgradeDeviceLocal:(ESPDevice *)device
{
    ESPActionDeviceUpgradeLocal *action = [[ESPActionDeviceUpgradeLocal alloc]init];
    return [action doUpgradeLocalDevice:device];
}

/**
 * upgrade the device by internet
 *
 * @param device the device to be upgraded
 * @return whether the device upgrade internet suc
 */
-(BOOL) doActionUpgradeDeviceInternet:(ESPDevice *)device
{
    ESPActionDeviceUpgradeInternet *action = [[ESPActionDeviceUpgradeInternet alloc]init];
    return [action doUpgradeInternetDevice:device];
}

/**
 * rename device internet(user) or local(guest)
 *
 * @param device the device to be renamed
 * @param deviceName the device's new name
 * @param instantly rename device name instantly or not
 */
-(void) doActionRenameDevice:(ESPDevice *)device DeviceName:(NSString *)deviceName Instantly:(BOOL)instantly
{
    ESPActionDeviceRename *action = [[ESPActionDeviceRename alloc]init];
    if (device.isActivated) {
        [action doActionDeviceRenameInternetAsync:device DeviceName:deviceName Instantly:instantly];
    } else {
        [action doActionDeviceRenameLocalAsync:device DeviceName:deviceName Instantly:instantly];
    }
}

/**
 * delete device internet(user) or local(guest)
 *
 * @param device the device to be deleted
 * @param instantly delete device instantly or not
 */
-(void) doActionDeleteDevice:(ESPDevice *)device Instantly:(BOOL)instantly
{
    ESPActionDeviceDelete *action = [[ESPActionDeviceDelete alloc]init];
    if (device.isActivated) {
        [action doActionDeviceDeleteInternetAsync:device Instantly:instantly];
    } else {
        [action doActionDeviceDeleteLocalAsync:device Instantly:instantly];
    }
}

/**
 * login by Internet
 *
 * @param userEmail user's email
 * @param userPassword user's password
 * @return ESPLoginResult
 */
-(ESPLoginResult *) doActionUserLoginInternetUserEmail:(NSString *)userEmail UserPassword:(NSString *)userPassword
{
    ESPActionUesrLoginInternet *action = [[ESPActionUesrLoginInternet alloc]init];
    ESPLoginResult *result = [action doActionUserLoginInternetUserEmail:userEmail UserPassword:userPassword];
    return result;
}

/**
 * register user account with email by Internet
 *
 * @param userName user's name
 * @param userEmail user's email
 * @param userPassword user's password
 * @return ESPRegisterResult
 */
-(ESPRegisterResult *) doActionUserRegisterInternetUserName:(NSString *)userName UserEmail:(NSString *)userEmail UserPassword:(NSString *)userPassword
{
    ESPActionUserRegisterInternet *action = [[ESPActionUserRegisterInternet alloc]init];
    ESPRegisterResult *result = [action doActionUserRegisterInternetUserName:userName UserEmail:userEmail UserPassword:userPassword];
    return result;
}

#pragma mark - add device(s)

-(BOOL) __ping
{
    [[NSNotificationCenter defaultCenter]postNotificationName:ESPTOUCH_CONTACTING_SERVER object:nil];
    NSString *urlString = @"https://iot.espressif.cn/v1/ping";
    NSDictionary *jsonResponse = nil;
    for (int retry = 0; jsonResponse==nil&&retry<3; ++retry) {
        if (retry!=0) {
            [NSThread sleepForTimeInterval:1.0];
        }
        jsonResponse = [ESPBaseApiUtil Get:urlString Headers:nil];
    }
    BOOL isServerAvailable = jsonResponse!=nil;
    if (isServerAvailable) {
        [[NSNotificationCenter defaultCenter]postNotificationName:ESPTOUCH_REGISTER_DEVICES object:nil];
    }
    return isServerAvailable;
}

// rename all new devices
-(void) __renameAllNewDevices:(NSArray *)esptouchResultList
{
    ESPUser *user = [ESPUser sharedUser];
    NSArray *devices = user.espDeviceArray;
    for (ESPTouchResult *esptouchResult in esptouchResultList) {
        NSString *bssid = [ESPBssidUtil restoreBssid:esptouchResult.bssid];
        NSString *inetAddr = [ESP_NetUtil descriptionInetAddr4ByData:esptouchResult.ipAddrData];
        ESPIOTAddress *iotAddress = [[ESPIOTAddress alloc]initWithBssid:bssid InetAddress:inetAddr];
        iotAddress.espDeviceType = nil;
        for (ESPDevice *device in devices) {
            if ([bssid isEqualToString:device.espBssid]) {
                iotAddress.espDeviceType = device.espDeviceType;
            }
        }
        if (iotAddress.espDeviceType!=nil) {
            ESPDevice *iotAddrDevice = [[ESPDevice alloc]initWithIOTAddress:iotAddress];
            [user doActionRenameDevice:iotAddrDevice DeviceName:iotAddrDevice.espDeviceName Instantly:NO];
        }
    }

}

-(BOOL) __addDevicesSyncResultCount:(int)expectTaskResultCount ApSsid:(NSString *)apSsid ApBssid:(NSString *)apBssid ApPassword:(NSString *)apPassword IsSsidHidden:(BOOL)isSsidHidden RequiredActivate:(BOOL)requiredActivate Delegate:(id<ESPTouchDelegate>)delegate
{
    // do esptouch action
    ESPActionDeviceEsptouch *action = [[ESPActionDeviceEsptouch alloc]init];
    NSArray *esptouchResultList = [action doActionDeviceEsptouchResultCount:expectTaskResultCount ApSsid:apSsid ApBssid:apBssid ApPassword:apPassword IsSsidHidden:isSsidHidden Delegate:delegate];
    // firstResult.isSuc express whether esptouch is suc or not
    ESPTouchResult *firstResult = [esptouchResultList firstObject];
    if (!firstResult.isSuc) {
        return NO;
    } else if (firstResult.isSuc && !requiredActivate) {
        // rename all new devices
        [self __renameAllNewDevices:esptouchResultList];
        // add activate local task into handler

        return YES;
    } else {
        // rename all new devices
        [self __renameAllNewDevices:esptouchResultList];
        // ping server
        [self __ping];
        // add task into device statemachine handler
        ESPDeviceStateMachineHandler *handler = [ESPDeviceStateMachineHandler sharedDeviceStateMachineHandler];
        // cancel all tasks and clear handler dirty datas
        [handler cancelAllTasks];
        for (ESPTouchResult *esptouchResult in esptouchResultList) {
            // generate sta device by esptouch result
            if (!esptouchResult.isSuc) {
                break;
            }
            NSString *bssid = [ESPBssidUtil restoreBssid:esptouchResult.bssid];
            NSString *inetAddr = nil;
            inetAddr = [ESP_NetUtil descriptionInetAddr4ByData:esptouchResult.ipAddrData];
            if (inetAddr==nil) {
                inetAddr = [ESP_NetUtil descriptionInetAddr6ByData:esptouchResult.ipAddrData];
            }
            ESPIOTAddress *iotAddress = [[ESPIOTAddress alloc]initWithBssid:bssid InetAddress:inetAddr];
            iotAddress.espDeviceType = [ESPDeviceType resolveDeviceTypeByTypeName:@"New"];
            ESPDevice *iotAddrDevice = [[ESPDevice alloc]initWithIOTAddress:iotAddress];
            // add activate local task into handler
            ESPTaskActivateLocal *activateLocalTask = [handler createTaskActivateLocal:iotAddrDevice];
            [handler addTask:activateLocalTask];
        }
        // wait handler finished
        while (!handler.isAllTasksDone) {
            // busy waiting
            [NSThread sleepForTimeInterval:0.5];
        }
        // check whether there's device activating suc
        for (ESPTouchResult *esptouchResult in esptouchResultList) {
            NSString *bssid = [ESPBssidUtil restoreBssid:esptouchResult.bssid];
            // it is suc as long as one device activating suc
            if ([handler isTaskSuc:bssid]) {
                return YES;
            }
        }
    }
    return NO;
}

-(BOOL) activateDeviceSync:(ESPDevice *)device
{
    ESPDeviceStateMachineHandler *handler = [ESPDeviceStateMachineHandler sharedDeviceStateMachineHandler];
    // cancel all tasks and clear handler dirty datas
    [handler cancelAllTasks];
    // add activate local task into handler
    ESPTaskActivateLocal *activateLocalTask = [handler createTaskActivateLocal:device];
    [handler addTask:activateLocalTask];
    // wait handler finished
    while (!handler.isAllTasksDone) {
        // busy waiting
        [NSThread sleepForTimeInterval:0.5];
    }
    // check whether the device activating suc
    return [handler isTaskSuc:device.espBssid];
}

/**
 * add all devices in SmartConfig connect to the AP which the phone is connected, if requiredActivate is true, it
 * will make device avaliable on server. all of the tasks are syn.
 *
 * @param apSsid the Ap's ssid
 * @param apBssid the Ap's bssid
 * @param apPassword the Ap's password
 * @param isSsidHidden whether the Ap's ssid is hidden
 * @param requiredActivate whether activate the devices automatically
 * @param esptouchListener when one device is connected to the Ap, it will be called back
 *
 * @return whether the task is executed suc(if there's another task executing, it will return false,and don't start the task)
 */
-(BOOL) addDevicesSyncApSsid:(NSString *)apSsid ApBssid:(NSString *)apBssid ApPassword:(NSString *)apPassword IsSsidHidden:(BOOL)isSsidHidden RequiredActivate:(BOOL)requiredActivate Delegate:(id<ESPTouchDelegate>)delegate
{
    BOOL isSuc = [self __addDevicesSyncResultCount:0 ApSsid:apSsid ApBssid:apBssid ApPassword:apPassword IsSsidHidden:isSsidHidden RequiredActivate:requiredActivate Delegate:delegate];
    [self doActionRefreshDevices:YES];
    return isSuc;
}

/**
 * add one device in SmartConfig connect to the AP which the phone is connected, if requiredActivate is true, it
 * will make device available on server. the task is syn
 *
 * @param apSsid the Ap's ssid
 * @param apBssid the Ap's bssid
 * @param apPassword the Ap's password
 * @param isSsidHidden whether the Ap's ssid is hidden
 * @param requiredActivate whether activate the devices automatically
 * @param esptouchListener when one device is connected to the Ap, it will be called back
 *
 * @return whether the task is executed suc
 */
-(BOOL) addDeviceSyncApSsid:(NSString *)apSsid ApBssid:(NSString *)apBssid ApPassword:(NSString *)apPassword IsSsidHidden:(BOOL)isSsidHidden RequiredActivate:(BOOL)requiredActivate Delegate:(id<ESPTouchDelegate>)delegate
{
    BOOL isSuc = [self __addDevicesSyncResultCount:1 ApSsid:apSsid ApBssid:apBssid ApPassword:apPassword IsSsidHidden:isSsidHidden RequiredActivate:requiredActivate Delegate:delegate];
    [self doActionRefreshDevices:YES];
    return isSuc;
}

#pragma mark - others

/**
 * send DEVICES_ARRIVE notifications
 */
-(void) notifyDevicesArrive
{
    [[NSNotificationCenter defaultCenter]postNotificationName:DEVICES_ARRIVE object:nil];
}

-(BOOL) espIsLogined
{
    return _espUserEmail!=nil&&![_espUserEmail isEqualToString:ESP_USER_EMAIL_GUEST];
}

-(DaoEspUser *) espDaoEspUser
{
    DaoEspUser *daoUser = [[DaoEspUser alloc]init];
    daoUser.espUserId = [NSNumber numberWithLongLong:_espUserId];
    daoUser.espUserKey = _espUserKey;
    daoUser.espUserName = _espUserName;
    daoUser.espUserEmail = _espUserEmail;
    return daoUser;
}

/**
 * save devices into db
 */
-(void) saveDevices
{
    NSArray *devices = nil;
    @synchronized(_espDeviceArray) {
        devices = [self.espDeviceArray copy];
    }
    
    ESPTask *task = [[ESPTask alloc]init];
    task.espBlock = ^{
        DEspDeviceManager *deviceManager = [DEspDeviceManager sharedDeviceManager];
        for (ESPDevice *device in devices) {
            [deviceManager insertOrUpdate:device.espDaoEspDevice];
        }
    };
    
    ESPGlobalTaskHandler *handler = [ESPGlobalTaskHandler sharedGlobalTaskHandler];
    [handler submit:task];
}

/**
 * load devices from db
 */
-(void) loadDevices
{
    DEspDeviceManager *deviceManager = [DEspDeviceManager sharedDeviceManager];
    // add device local
    NSArray <DaoEspDevice *> *localDaoDevices = [deviceManager queryByUserId:ESP_USER_ID_GUEST];
    for (DaoEspDevice *daoDevice in localDaoDevices) {
        ESPDevice *device = [[ESPDevice alloc]initWithDaoDevice:daoDevice];
        
        // restore device state
        ESPDeviceState *state = device.espDeviceState;
        
        [state clearStateLocal];
        [state addStateOffline];
        
        // clear renamed state
        [state clearStateRenamed];
        
        device._espIsFromDatabase = YES;
        [self addDeviceLocal:device];
    }
    
    NSMutableArray *renamedDevices = [[NSMutableArray alloc]init];
    NSMutableArray *deletedDevices = [[NSMutableArray alloc]init];
    
    // add device internet
    if (_espUserId!=ESP_USER_ID_GUEST) {
        NSArray <DaoEspDevice *> *internetDaoDevices = [deviceManager queryByUserId:_espUserId];
        for (DaoEspDevice *daoDevice in internetDaoDevices) {
            ESPDevice *device = [[ESPDevice alloc]initWithDaoDevice:daoDevice];
            // restore device state
            ESPDeviceState *state = device.espDeviceState;
            // deal with different device state
            if (state.isStateActivating) {
#ifdef DEBUG
                NSLog(@"%@ %@ isStateActivating, daoEspDevice:%@",self.class,NSStringFromSelector(_cmd),device.espDaoEspDevice);
#endif
                continue;
            } else if (state.isStateConfiguring) {
#ifdef DEBUG
                NSLog(@"%@ %@ isStateConfiguring, daoEspDevice:%@",self.class,NSStringFromSelector(_cmd),device.espDaoEspDevice);
#endif
                continue;
            } else if (state.isStateNew) {
#ifdef DEBUG
                NSLog(@"%@ %@ isStateNew, daoEspDevice:%@",self.class,NSStringFromSelector(_cmd),device.espDaoEspDevice);
#endif
                continue;
            } else if (state.isStateUpgradeLocal) {
                [state clearStateUpgradeLocal];
            } else if (state.isStateUpgradeInternet) {
                [state clearStateUpgradeInternet];
            }
            
            [state clearStateLocal];
            [state clearStateInternet];
            [state addStateOffline];
            
            if (state.isStateRenamed) {
                [renamedDevices addObject:device];
            }
            
            if (state.isStateDeleted) {
                [deletedDevices addObject:device];
            }
            
            [self addDeviceInternet:device];
            
        }
    }
    
    // update device internet and local
    NSArray *devices = self.espDeviceArray;
    
#ifdef DEBUG
    NSLog(@"%@ %@ devices:%@",self.class,NSStringFromSelector(_cmd),devices);
#endif
    
    // do rename action
    for (ESPDevice *renamedDevice in renamedDevices) {
        [self doActionRenameDevice:renamedDevice DeviceName:renamedDevice.espDeviceName Instantly:NO];
    }
    
    // do delete action
    for (ESPDevice *deleteDevice in deletedDevices) {
        [self doActionDeleteDevice:deleteDevice Instantly:NO];
    }
    
    [self notifyDevicesArrive];
}

/**
 * save user into db
 */
-(void) saveUser
{
    ESPTask *task = [[ESPTask alloc]init];
    task.espBlock = ^{
        DEspUserManager *userManager = [DEspUserManager sharedUserManager];
        DaoEspUser *daoUser = self.espDaoEspUser;
        [userManager insertOrUpdate:daoUser];
    };
    
    ESPGlobalTaskHandler *handler = [ESPGlobalTaskHandler sharedGlobalTaskHandler];
    [handler submit:task];
}

/**
 * load user from db
 */
-(void) loadUser
{
    DEspUserManager *userManager = [DEspUserManager sharedUserManager];
    NSAssert(_espUserEmail!=nil, @"espUserEmail shouldn't be nil before loadUser: is called");
    DaoEspUser *daoUser = [userManager queryByEmail:_espUserEmail];
    if(daoUser!=nil) {
        _espUserName = daoUser.espUserName;
        _espUserId = [daoUser.espUserId longLongValue];
        _espUserKey = daoUser.espUserKey;
    } else {
        NSLog(@"%@ %@ daoUser is nil",self.class,NSStringFromSelector(_cmd));
    }
}

/**
 * load user guest
 */
-(void) loadGuest
{
    _espUserId = ESP_USER_ID_GUEST;
    _espUserKey = ESP_USER_KEY_GUEST;
    _espUserName = ESP_USER_NAME_GUEST;
    _espUserEmail = ESP_USER_EMAIL_GUEST;
}

/**
 * logout
 */
-(void) logout
{
    [self loadGuest];

    @synchronized (_espDeviceArray) {
        [_espDeviceArray removeAllObjects];
    }
    @synchronized (_deviceLocalArray) {
        [_deviceLocalArray removeAllObjects];
    }
    @synchronized (_deviceInternetArray) {
        [_deviceInternetArray removeAllObjects];
    }@synchronized (_deviceTempArray) {
        [_deviceTempArray removeAllObjects];
    }
}

#pragma mark - description

-(NSString *) description
{
    NSString *hexAddr = [super description];
    return [NSString stringWithFormat:@"[%@ userId:%lld, userKey:%@, userName:%@, userEmail:%@]",hexAddr,self.espUserId,self.espUserKey,self.espUserName,self.espUserEmail];
}

@end
