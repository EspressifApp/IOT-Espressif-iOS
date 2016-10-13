//
//  ESPDevice.m
//  suite
//
//  Created by 白 桦 on 5/25/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import "ESPDevice.h"
#import "ESPDeviceLight.h"
#import "ESPDevicePlug.h"
#import "ESPBssidUtil.h"
#import "ESPActionDeviceActivateLocal.h"
#import "ESPActionDeviceActivateInternet.h"
#import "DEspDeviceManager.h"
#import "ESPGlobalTaskHandler.h"
#import "ESPUser.h"

@implementation ESPDevice

// -1, -2, ... is used to activate softap device by direct connect,
// 1, 2, ... is used by server
static long long idCreator = -LONG_LONG_MAX / 2;

+ (long long) nextId {
    @synchronized(self) {
        return --idCreator;
    }
}

// init deviece with device(like copying)
- (instancetype) initWithDevice:(ESPDevice *)device
{
    return device!=nil ? [device copy] : nil;
}

// init sta device with IOTAddress
- (instancetype) initWithIOTAddress:(ESPIOTAddress *)iotAddress
{
    ESPDevice *device = nil;
    assert(iotAddress.espDeviceType);
    switch (iotAddress.espDeviceType.espTypeEnum) {
        case FLAMMABLE_ESP_DEVICETYPE:
            abort();
            break;
        case HUMITURE_ESP_DEVICETYPE:
            abort();
            break;
        case LIGHT_ESP_DEVICETYPE:
            device = [[ESPDeviceLight alloc]init];
            break;
        case NEW_ESP_DEVICETYPE:
            device = [[ESPDevice alloc]init];
            break;
        case PLUG_ESP_DEVICETYPE:
            device = [[ESPDevicePlug alloc]init];
            break;
        case PLUGS_ESP_DEVICETYPE:
            abort();
            break;
        case REMOTE_ESP_DEVICETYPE:
            abort();
            break;
        case ROOT_ESP_DEVICETYPE:
            abort();
            break;
        case SOUNDBOX_ESP_DEVICETYPE:
            abort();
            break;
        case VOLTAGE_ESP_DEVICETYPE:
            abort();
            break;
    }
    if (device) {
        ESPDeviceState *stateLocal = [[ESPDeviceState alloc]init];
        [stateLocal addStateLocal];
        device.espBssid = iotAddress.espBssid;
        device.espDeviceId = [ESPDevice nextId];
        device.espDeviceKey = iotAddress.espBssid;
        device.espDeviceName = [ESPBssidUtil genDeviceNameByBssid:device.espBssid];
        device.espDeviceState = stateLocal;
        device.espDeviceType = iotAddress.espDeviceType;
        device.espInetAddress = iotAddress.espInetAddress;
        device.espIsMeshDevice = iotAddress.espIsMeshDevice;
        device.espIsOwner = NO;
        device.espIsUsing = NO;
        device.espParentDeviceBssid = iotAddress.espParentBssid;
        device.espRomVersionCurrent = iotAddress.espRomVersionCurrent;
        device.espRootDeviceBssid = iotAddress.espRootBssid;
        device.espUserId = ESP_USER_ID_GUEST;
        device._espIsRenamedJustNow = NO;
        device._espIsFromDatabase = NO;
    }
    return device;
}

// init device according to info from server
- (instancetype) initWithDeviceName:(NSString *)deviceName DeviceId:(long long)deviceId DeviceKey:(NSString *)deviceKey IsOwner:(BOOL)isOwner Bssid:(NSString *)bssid DeviceState:(ESPDeviceState *)deviceState DeviceType:(ESPDeviceType *)deviceType RomVersion:(NSString *)romVersion LatestRomVersion:(NSString *)latestRomVersion UserId:(long long)userId IsMeshDevice:(BOOL) isMeshDevice ParentBssid:(NSString *)parentBssid ActivatedTimestamp:(NSDate *)deviceActivatedTimestamp;
{
    ESPDevice *device = nil;
    switch (deviceType.espTypeEnum) {
        case FLAMMABLE_ESP_DEVICETYPE:
            break;
        case HUMITURE_ESP_DEVICETYPE:
            break;
        case LIGHT_ESP_DEVICETYPE:
            device = [[ESPDeviceLight alloc]init];
            break;
        case NEW_ESP_DEVICETYPE:
            break;
        case PLUG_ESP_DEVICETYPE:
            device = [[ESPDevicePlug alloc]init];
            break;
        case PLUGS_ESP_DEVICETYPE:
            break;
        case REMOTE_ESP_DEVICETYPE:
            break;
        case ROOT_ESP_DEVICETYPE:
            break;
        case SOUNDBOX_ESP_DEVICETYPE:
            break;
        case VOLTAGE_ESP_DEVICETYPE:
            break;
    }
    device.espBssid = bssid;
    device.espDeviceId = deviceId;
    device.espDeviceKey = deviceKey;
    device.espDeviceName = deviceName;
    device.espDeviceState = deviceState;
    device.espDeviceType = deviceType;
    device.espIsMeshDevice = isMeshDevice;
    device.espIsOwner = isOwner;
    device.espIsUsing = NO;
    device.espParentDeviceBssid = parentBssid;
    device.espRomVersionCurrent = romVersion;
    device.espRomVersionLatest = latestRomVersion;
    device.espUserId = userId;
    device.espDeviceActivatedTimestamp = deviceActivatedTimestamp;
    device._espIsRenamedJustNow = NO;
    device._espIsFromDatabase = NO;
    return device;
}

// init device according to local database
- (instancetype) initWithDaoDevice:(DaoEspDevice *)daoDevice
{
    NSString *deviceName = daoDevice.espDeviceName;
    long long deviceId = [daoDevice.espDeviceId longLongValue];
    NSString *deviceKey = daoDevice.espDeviceKey;
    BOOL isOwner = [daoDevice.espDeviceIsOwner boolValue];
    NSString *bssid = daoDevice.espDeviceBssid;
    int stateValue = [daoDevice.espDeviceState intValue];
    ESPDeviceState *state = [[ESPDeviceState alloc]initWithState:stateValue];
    int typeValue = [daoDevice.espDeviceType intValue];
    ESPDeviceType *type = [ESPDeviceType resolveDeviceTypeBySerial:typeValue];
    NSString *romVerCur = daoDevice.espDeviceRomCur;
    NSString *romVerLat = daoDevice.espDeviceRomLat;
    long long userId = [daoDevice.espPKUserId longLongValue];
    BOOL isMesh = NO;
    NSString *parentBssid = nil;
    NSDate *activatedTimestamp = daoDevice.espDeviceActivatedTimestamp;
    
    return [self initWithDeviceName:deviceName DeviceId:deviceId DeviceKey:deviceKey IsOwner:isOwner Bssid:bssid DeviceState:state DeviceType:type RomVersion:romVerCur LatestRomVersion:romVerLat UserId:userId IsMeshDevice:isMesh ParentBssid:parentBssid ActivatedTimestamp:activatedTimestamp];
}

// Sentry for User can't find local device in the AP
+ (ESPDevice *) ESP_DEVICE_LOCAL_EMPTY
{
    static dispatch_once_t predicate;
    static ESPDevice *DEVICE_LOCAL_EMPTY;
    dispatch_once(&predicate, ^{
        DEVICE_LOCAL_EMPTY = [[ESPDevice alloc]init];
    });
    return DEVICE_LOCAL_EMPTY;
}

// Sentry for User haven't his own device
+ (ESPDevice *) ESP_DEVICE_INTERNET_EMPTY
{
    static dispatch_once_t predicate;
    static ESPDevice *DEVICE_INTERNET_EMPTY;
    dispatch_once(&predicate, ^{
        DEVICE_INTERNET_EMPTY = [[ESPDevice alloc]init];
    });
    return DEVICE_INTERNET_EMPTY;
}

// Sentry for Internet unaccessible
+ (ESPDevice *) ESP_DEVICE_INTERNET_UNACCESSIBLE
{
    static dispatch_once_t predicate;
    static ESPDevice *DEVICE_INTERNET_UNACCESSIBLE;
    dispatch_once(&predicate, ^{
        DEVICE_INTERNET_UNACCESSIBLE = [[ESPDevice alloc]init];
    });
    return DEVICE_INTERNET_UNACCESSIBLE;
}

/**
 * check whether the device is activated
 *
 * @return whether the device is activated
 */
-(BOOL) isActivated
{
    return _espDeviceId > 0;
}

/**
 * activate device local(make device activate to server)
 *
 * @param randomKey the random 40 key
 * @return whether activate device local suc(make device activate to server)
 */
- (BOOL) doActionDeviceActivateLocalRandomKey:(NSString *)randomKey;
{
    ESPActionDeviceActivateLocal *action = [[ESPActionDeviceActivateLocal alloc]init];
    if (self.espIsMeshDevice) {
        return [action doActionMeshDeviceActivateLoalBssid:self.espBssid InetAddr:self.espInetAddress RandomToken:randomKey];
    } else {
        return [action doActionDeviceActivateLocalInetAddr:self.espInetAddress RandomToken:randomKey];
    }
}

/**
 * activate device internet(make user become the device owner on server)
 *
 * @param randomKey the random 40 key
 * @param userKey the user key
 * @param userId the user id
 *
 * @return the activate device from server or nil
 */
- (ESPDevice *) doActionDeviceActivateInternetRandomKey:(NSString *)randomKey UserKey:(NSString *)userKey UserId:(long long)userId
{
    ESPActionDeviceActivateInternet *action = [[ESPActionDeviceActivateInternet alloc]init];
    return [action doActionDeviceActivateInternetUserId:userId UserKey:userKey RandomToken:randomKey];
}

- (DaoEspDevice *) espDaoEspDevice
{
    DaoEspDevice *daoDevice = [[DaoEspDevice alloc]init];
    daoDevice.espDeviceId = [NSNumber numberWithLongLong:_espDeviceId];
    daoDevice.espDeviceKey = _espDeviceKey;
    daoDevice.espDeviceBssid = _espBssid;
    daoDevice.espDeviceType = [NSNumber numberWithInt:_espDeviceType.espSerial];
    daoDevice.espDeviceState = [NSNumber numberWithInt:_espDeviceState.espStateValue];
    daoDevice.espDeviceIsOwner = [NSNumber numberWithBool:_espIsOwner];
    daoDevice.espDeviceName = _espDeviceName;
    daoDevice.espDeviceRomCur = _espRomVersionCurrent;
    daoDevice.espDeviceRomLat = _espRomVersionLatest;
    daoDevice.espDeviceActivatedTimestamp = _espDeviceActivatedTimestamp;
    daoDevice.espPKUserId = [NSNumber numberWithLongLong:_espUserId];
    return daoDevice;
}

/**
 * save device into local database
 */
- (void) save
{
    ESPTask *task = [[ESPTask alloc]init];
    task.espBlock = ^{
        DEspDeviceManager *deviceManager = [DEspDeviceManager sharedDeviceManager];
        [deviceManager insertOrUpdate:self.espDaoEspDevice];
    };

    ESPGlobalTaskHandler *handler = [ESPGlobalTaskHandler sharedGlobalTaskHandler];
    [handler submit:task];
}

/**
 * remove device from local database
 */
- (void) remove
{
    ESPUser *user = [ESPUser sharedUser];
    if (user.espIsLogined) {
        // when user is logined, remove all the devices with the same bssid in database
        [self removeByBssid];
    } else {
        // when user is guest, just remove the device by device key
        [self removeByDeviceKey];
    }
}

/**
 * remove device from local database by bssid
 */
- (void) removeByBssid
{
    ESPTask *task = [[ESPTask alloc]init];
    task.espBlock = ^{
        DEspDeviceManager *deviceManager = [DEspDeviceManager sharedDeviceManager];
        [deviceManager removeByBssid:_espBssid];
    };
    
    ESPGlobalTaskHandler *handler = [ESPGlobalTaskHandler sharedGlobalTaskHandler];
    [handler submit:task];
}

/**
 * remove device from local database by device key
 */
-(void) removeByDeviceKey
{
    ESPTask *task = [[ESPTask alloc]init];
    task.espBlock = ^{
        DEspDeviceManager *deviceManager = [DEspDeviceManager sharedDeviceManager];
        [deviceManager removeByDeviceKey:_espDeviceKey];
    };
    
    ESPGlobalTaskHandler *handler = [ESPGlobalTaskHandler sharedGlobalTaskHandler];
    [handler submit:task];
}


- (BOOL)isEqual:(id)object
{
    if (self == object) {
        return YES;
    }
    if (![object isKindOfClass:[ESPDevice class]]) {
        return NO;
    }
    
    const ESPDevice *other = object;
    return [self.espDeviceKey isEqualToString:other.espDeviceKey];
    
}

- (id) copyWithZone:(NSZone *)zone
{
    ESPDevice *copy = nil;
    switch (self.espDeviceType.espTypeEnum) {
        case FLAMMABLE_ESP_DEVICETYPE:
            break;
        case HUMITURE_ESP_DEVICETYPE:
            break;
        case LIGHT_ESP_DEVICETYPE:
            copy = [[ESPDeviceLight allocWithZone:zone]init];
            break;
        case NEW_ESP_DEVICETYPE:
            break;
        case PLUG_ESP_DEVICETYPE:
            copy = [[ESPDevicePlug allocWithZone:zone]init];
            break;
        case PLUGS_ESP_DEVICETYPE:
            break;
        case REMOTE_ESP_DEVICETYPE:
            break;
        case ROOT_ESP_DEVICETYPE:
            break;
        case SOUNDBOX_ESP_DEVICETYPE:
            break;
        case VOLTAGE_ESP_DEVICETYPE:
            break;
    }
    if (copy) {
        copy.espBssid = self.espBssid;
        copy.espDeviceId = self.espDeviceId;
        copy.espDeviceKey = self.espDeviceKey;
        copy.espIsOwner = self.espIsOwner;
        copy.espDeviceName = self.espDeviceName;
        copy.espRomVersionCurrent = self.espRomVersionCurrent;
        copy.espRomVersionLatest = self.espRomVersionLatest;
        copy.espUserId = self.espUserId;
        copy.espDeviceType = [self.espDeviceType copy];
        copy.espDeviceState = [self.espDeviceState copy];
        copy.espInetAddress = self.espInetAddress;
        copy.espIsMeshDevice = self.espIsMeshDevice;
        copy.espParentDeviceBssid = self.espParentDeviceBssid;
        copy.espRootDeviceBssid = self.espRootDeviceBssid;
        copy.espIsUsing = self.espIsUsing;
        copy.espDeviceActivatedTimestamp = [self.espDeviceActivatedTimestamp copy];
        copy._espIsRenamedJustNow = self._espIsRenamedJustNow;
        copy._espIsFromDatabase = self._espIsFromDatabase;
    }
    return copy;
}

- (NSString *)description
{
    NSString *hexAddr = [super description];
    if (self==[ESPDevice ESP_DEVICE_LOCAL_EMPTY]) {
        return [NSString stringWithFormat:@"[%@ DEVICE_LOCAL_EMPTY]",hexAddr];
    } else if (self==[ESPDevice ESP_DEVICE_INTERNET_EMPTY]) {
        return [NSString stringWithFormat:@"[%@ DEVICE_INTERNET_EMPTY]",hexAddr];
    } else if (self==[ESPDevice ESP_DEVICE_INTERNET_UNACCESSIBLE]) {
        return [NSString stringWithFormat:@"[%@ DEVICE_INTERNET_UNACCESSIBLE]",hexAddr];
    } else {
        // don't print _espIsFromDatabase for it's very unimportant
        return [NSString stringWithFormat:@"[%@ bssid:%@ deviceId:%lld deviceKey:%@ isOwner:%@ deviceName:%@ romVerCur:%@ romVerLat:%@ useId:%lld deviceType:%@ deviceState:%@ inetAddr:%@ isMeshDevice:%@ parentDeviceBssid:%@ rootDeviceBssid:%@ isRenamedJustNow:%@]",hexAddr,self.espBssid,self.espDeviceId,self.espDeviceKey,self.espIsOwner?@"YES":@"NO",self.espDeviceName,self.espRomVersionCurrent,self.espRomVersionLatest,self.espUserId,self.espDeviceType,self.espDeviceState,self.espInetAddress,self.espIsMeshDevice?@"YES":@"NO",self.espParentDeviceBssid,self.espRootDeviceBssid,self._espIsRenamedJustNow?@"YES":@"NO"];
    }
}

@end
