//
//  ESPCommandDeviceActivateInternet.m
//  suite
//
//  Created by 白 桦 on 7/27/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import "ESPCommandDeviceActivateInternet.h"
#import "ESPDeviceType.h"
#import "ESPConstantsCommand.h"
#import "ESPConstantsCommandInternet.h"
#import "ESPConstantsHttpStatus.h"
#import "ESPBaseApiUtil.h"
#import "ESPBssidUtil.h"

#define ONLINE_TIMEOUT_PLUG             60000
#define ONLINE_TIMEOUT_PLUG_MESH        180000
#define ONLINE_TIMEOUT_LIGHT            60000
#define ONLINE_TIMEOUT_LIGHT_MESH       180000
#define ONLINE_TIMEOUT_HUMITURE         300000
#define ONLINE_TIMEOUT_FLAMMABLE        300000
#define ONLINE_TIMEOUT_REMOTE           60000
#define ONLINE_TIMEOUT_REMOTE_MESH      180000
#define ONLINE_TIMEOUT_PLUGS            60000
#define ONLINE_TIMEOUT_PLUGS_MESH       180000
#define ONLINE_TIMEOUT_VOLTAGE          60000
#define ONLINE_TIMEOUT_VOLTAGE_MESH     180000
#define ONLINE_TIMEOUT_SOUNDBOX         60000
#define ONLINE_TIMEOUT_SOUNDBOX_MESH    180000

#define URL                             @"https://iot.espressif.cn/v1/key/authorize/?query_devices_mesh=true"

@implementation ESPCommandDeviceActivateInternet

- (BOOL) isDeviceOnline:(BOOL) isMeshDevice DeviceType:(ESPDeviceType *) deviceType LastActive:(long long) lastActive CurrentTime:(long long)currentTime
{
    long long timeout = 0;
    switch (deviceType.espTypeEnum) {
        case FLAMMABLE_ESP_DEVICETYPE:
            timeout = ONLINE_TIMEOUT_FLAMMABLE;
            break;
        case HUMITURE_ESP_DEVICETYPE:
            timeout = ONLINE_TIMEOUT_HUMITURE;
            break;
        case LIGHT_ESP_DEVICETYPE:
            timeout = isMeshDevice ?  ONLINE_TIMEOUT_LIGHT_MESH : ONLINE_TIMEOUT_LIGHT;
            break;
        case NEW_ESP_DEVICETYPE:
            break;
        case PLUG_ESP_DEVICETYPE:
            timeout = isMeshDevice ? ONLINE_TIMEOUT_PLUG_MESH : ONLINE_TIMEOUT_PLUG;
            break;
        case PLUGS_ESP_DEVICETYPE:
            timeout = isMeshDevice ? ONLINE_TIMEOUT_PLUGS_MESH : ONLINE_TIMEOUT_PLUGS;
            break;
        case REMOTE_ESP_DEVICETYPE:
            timeout = isMeshDevice ? ONLINE_TIMEOUT_REMOTE_MESH : ONLINE_TIMEOUT_REMOTE;
            break;
        case ROOT_ESP_DEVICETYPE:
            break;
        case SOUNDBOX_ESP_DEVICETYPE:
            timeout = isMeshDevice ? ONLINE_TIMEOUT_SOUNDBOX_MESH : ONLINE_TIMEOUT_SOUNDBOX;
            break;
        case VOLTAGE_ESP_DEVICETYPE:
            timeout = isMeshDevice ? ONLINE_TIMEOUT_VOLTAGE_MESH : ONLINE_TIMEOUT_VOLTAGE;
            break;
    }
    /**
     * when last_active is after currentTime or currentTime - last_active <= timeout, the device is online
     */
    if (lastActive >= currentTime || currentTime - lastActive <= timeout)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

/**
 * Activate the new device online
 *
 * @param userId the user's id
 * @param userKey the user's key
 * @param randomToken the random token
 * @return the new activated device
 */
- (ESPDevice *) doCommandDeviceActivateInternetUserId:(long long)userId UserKey:(NSString *)userKey RandomToken:(NSString *)randomToken
{
    NSDictionary *jsonRequest = @{TOKEN:randomToken};
    NSDictionary *headers = @{AUTHORIZATION:[NSString stringWithFormat:@"%@ %@",TOKEN,userKey],TIME_ZONE:EPOCH};
    NSDictionary *jsonResponse = [ESPBaseApiUtil Post:URL Json:jsonRequest Headers:headers];
    if (jsonResponse==nil) {
        return nil;
    }
    int status = [[jsonResponse objectForKey:STATUS]intValue];
    if (status == HTTP_STATUS_OK) {
        long long currentTime = [ESPBaseApiUtil getUTCTimeLongLong];
        if (currentTime==LONG_LONG_MIN) {
            currentTime = [NSDate date].timeIntervalSince1970 * 1000;
        }
        NSDictionary *jsonKey = [jsonResponse objectForKey:KEY];
        
        BOOL isOwnerKey = NO;
        if ([[jsonKey objectForKey:IS_OWNER_KEY]intValue] == 1) {
            isOwnerKey = YES;
        }
        long long deviceId = [[jsonKey objectForKey:DEVICE_ID]longLongValue];
        // jsonDevice
        NSDictionary *jsonDevice = [jsonResponse objectForKey:DEVICE];
        
        // bssid
        NSString *bssid = [jsonDevice objectForKey:BSSID];
        // type
        int ptype = [[jsonDevice objectForKey:PTYPE]intValue];
        ESPDeviceType *deviceType = [ESPDeviceType resolveDeviceTypeBySerial:ptype];
        if (deviceType==nil) {
            // invalid type
            return nil;
        }
        if (![ESPDeviceType isTypeSupportedAlready:deviceType]) {
            NSLog(@"%@ %@ type:%@ is not supported yet",self.class,NSStringFromSelector(_cmd),deviceType);
            // type not supported yet
            return nil;
        }
        
        // device name
        NSString *deviceName = [jsonDevice objectForKey:NAME];
        
        // filter "device-name-"
        NSString *_deviceName = @"device-name-";
        const NSUInteger _deviceNamelength = [_deviceName length];
        if ([deviceName length] > _deviceNamelength) {
            NSString *deviceNamePre = [deviceName substringToIndex:_deviceNamelength];
            if ([deviceNamePre isEqualToString:_deviceName]) {
                deviceName = [ESPBssidUtil genDeviceNameByBssid:bssid];
            }
        }
        
        // isOwner
        BOOL isOwner = NO;
        if ([[jsonKey objectForKey:IS_OWNER_KEY]intValue] == 1) {
            isOwner = YES;
        }
        
        // deviceKey
        NSString *deviceKey = [jsonKey objectForKey:TOKEN];
        
        // romVersion and latestRomVersion
        NSString *romVersion = [jsonDevice objectForKey:ROM_VERSION];
        NSString *latestRomVersion = [jsonDevice objectForKey:LATEST_ROM_VERSION];
        // check isOnline
        BOOL isMeshDevice = [jsonDevice objectForKey:PARENT_MDEV_MAC]!=nil;
        long long lastActive = [[jsonDevice objectForKey:LAST_ACTIVE]longLongValue] * 1000;
        BOOL isOnline = [self isDeviceOnline:isMeshDevice DeviceType:deviceType LastActive:lastActive CurrentTime:currentTime];
        // set state
        ESPDeviceState *deviceState = [[ESPDeviceState alloc]init];
        isOnline ? [deviceState addStateInternet] : [deviceState addStateOffline];
        
        // parent device bssid
        NSString *parentBssid = nil;
        if (isMeshDevice) {
            NSString *_parentBssid = [jsonDevice objectForKey:PARENT_MDEV_MAC];
            if (![_parentBssid isEqualToString:@"null"]) {
                parentBssid = _parentBssid;
            }
        }
        // check parentBssid, filter the AP
        if (parentBssid != nil && ![ESPBssidUtil isESPDevice:parentBssid]) {
            parentBssid = nil;
        }
        
        // activated timestamp
        long long activatedTimeSecond = [[jsonDevice objectForKey:@"activated_at"]longLongValue];
        NSDate *activatedTimestamp = [NSDate dateWithTimeIntervalSince1970:activatedTimeSecond];
        
        // create device
        ESPDevice *device = [[ESPDevice alloc]initWithDeviceName:deviceName DeviceId:deviceId DeviceKey:deviceKey IsOwner:isOwner Bssid:bssid DeviceState:deviceState DeviceType:deviceType RomVersion:romVersion LatestRomVersion:latestRomVersion UserId:userId IsMeshDevice:isMeshDevice ParentBssid:parentBssid ActivatedTimestamp:activatedTimestamp];
        return device;
    }
    return nil;
}

@end
