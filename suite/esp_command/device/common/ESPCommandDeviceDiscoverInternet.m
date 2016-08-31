//
//  ESPCommandDeviceDiscoverInternet.m
//  suite
//
//  Created by 白 桦 on 6/1/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import "ESPCommandDeviceDiscoverInternet.h"
#import "ESPDeviceType.h"
#import "ESPDeviceState.h"
#import "ESPBaseApiUtil.h"
#import "ESPConstantsCommand.h"
#import "ESPConstantsCommandInternet.h"
#import "ESPConstantsHttpStatus.h"
#import "ESPGroup.h"
#import "ESPGroupState.h"
#import "ESPUser.h"
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

@implementation ESPCommandDeviceDiscoverInternet

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

- (NSArray *) sendRequest:(NSString *)userKey
{
    NSString *key1 = AUTHORIZATION;
    NSString *value1 = [NSString stringWithFormat:@"%@ %@",TOKEN,userKey];
    NSString *key2 = TIME_ZONE;
    NSString *value2 = EPOCH;
    NSDictionary *headers = [NSDictionary dictionaryWithObjectsAndKeys:value1,key1,value2,key2, nil];
    NSDictionary *responseDict = [ESPBaseApiUtil Get:URL Headers:headers];
    if (responseDict!=nil) {
        int status = [[responseDict objectForKey:STATUS]intValue];
        if (status==HTTP_STATUS_OK) {
#ifdef DEBUG
            NSLog(@"%@ %@ suc",[self class],NSStringFromSelector(_cmd));
#endif
            NSArray *groupDict = [responseDict objectForKey:DEVICE_GROUPS];
            return groupDict;
        }
    }
#ifdef DEBUG
    NSLog(@"%@ %@ fail",[self class],NSStringFromSelector(_cmd));
#endif
    return nil;
}

- (NSArray *)resolveResponse:(NSArray *)groupsJsonArray CurrentTime:(long long)currentTime
{
    NSMutableArray *groupArray = [[NSMutableArray alloc]init];
    
    for (int gi = 0; gi < [groupsJsonArray count]; ++gi) {
        NSDictionary *groupDict = [groupsJsonArray objectAtIndex:gi];
        long long groupId = [[groupDict objectForKey:ID] longLongValue];
        NSString *groupName = [groupDict objectForKey:NAME];
        ESPGroup *group =[[ESPGroup alloc]init];
        group.espGroupId = groupId;
        group.espGroupName = groupName;
        [groupArray addObject:group];
        
        NSArray *devicesJsonArray = [groupDict objectForKey:DEVICES];
        for (int di = 0; di < [devicesJsonArray count]; ++di) {
            NSDictionary *deviceJsonDict = [devicesJsonArray objectAtIndex:di];
            // bssid
            NSString *bssid = [deviceJsonDict objectForKey:BSSID];
            if ([bssid isEqualToString:@""] || [bssid length] != [@"18:fe:34:a2:c6:db" length]) {
                continue;
            }
            // type
            int ptype = [[deviceJsonDict objectForKey:PTYPE]intValue];
            ESPDeviceType *deviceType = [ESPDeviceType resolveDeviceTypeBySerial:ptype];
            if (deviceType==nil) {
                // invalid type
                continue;
            }
            if (![ESPDeviceType isTypeSupportedAlready:deviceType]) {
                NSLog(@"%@ %@ type:%@ is not supported yet",self.class,NSStringFromSelector(_cmd),deviceType);
                // type not supported yet
                continue;
            }
            
            // userId
            long long userId = [ESPUser sharedUser].espUserId;
            
            // deviceId
            long long deviceId = [[deviceJsonDict objectForKey:ID]longLongValue];
            
            // device name
            NSString *deviceName = [deviceJsonDict objectForKey:NAME];
            
            // filter "device-name-"
            NSString *_deviceName = @"device-name-";
            const NSUInteger _deviceNamelength = [_deviceName length];
            if ([deviceName length] > _deviceNamelength) {
                NSString *deviceNamePre = [deviceName substringToIndex:_deviceNamelength];
                if ([deviceNamePre isEqualToString:_deviceName]) {
                    deviceName = [ESPBssidUtil genDeviceNameByBssid:bssid];
                }
            }
            
            NSDictionary *keyJsonDict = [deviceJsonDict objectForKey:KEY];
            
            // isOwner
            BOOL isOwner = NO;
            if ([[keyJsonDict objectForKey:IS_OWNER_KEY]intValue] == 1) {
                isOwner = YES;
            }
            
            // deviceKey
            NSString *deviceKey = [keyJsonDict objectForKey:TOKEN];
            
            // romVersion and latestRomVersion
            NSString *romVersion = [deviceJsonDict objectForKey:ROM_VERSION];
            NSString *latestRomVersion = [deviceJsonDict objectForKey:LATEST_ROM_VERSION];
            // check isOnline
            BOOL isMeshDevice = [deviceJsonDict objectForKey:PARENT_MDEV_MAC]!=nil;
            long long lastActive = [[deviceJsonDict objectForKey:LAST_ACTIVE]longLongValue] * 1000;
            BOOL isOnline = [self isDeviceOnline:isMeshDevice DeviceType:deviceType LastActive:lastActive CurrentTime:currentTime];
            // set state
            ESPDeviceState *deviceState = [[ESPDeviceState alloc]init];
            isOnline ? [deviceState addStateInternet] : [deviceState addStateOffline];
            
            // parent device bssid
            NSString *parentBssid = nil;
            if (isMeshDevice) {
                NSString *_parentBssid = [deviceJsonDict objectForKey:PARENT_MDEV_MAC];
                if (![_parentBssid isEqualToString:@"null"]) {
                    parentBssid = _parentBssid;
                }
            }
            // check parentBssid, filter the AP
            if (parentBssid != nil && ![ESPBssidUtil isESPDevice:parentBssid]) {
                parentBssid = nil;
            }
            // activated timestamp
            long long activatedTimeSecond = [[deviceJsonDict objectForKey:ACTIVATED_AT]longLongValue];
            NSDate *activatedTimestamp = [NSDate dateWithTimeIntervalSince1970:activatedTimeSecond];
            // create device
            ESPDevice *device = [[ESPDevice alloc]initWithDeviceName:deviceName DeviceId:deviceId DeviceKey:deviceKey IsOwner:isOwner Bssid:bssid DeviceState:deviceState DeviceType:deviceType RomVersion:romVersion LatestRomVersion:latestRomVersion UserId:userId IsMeshDevice:isMeshDevice ParentBssid:parentBssid ActivatedTimestamp:activatedTimestamp];
            
            [group addDevice:device];
        }
    }
    return groupArray;
}

- (NSArray *) resolveDeviceArrayFromGroupArray:(NSArray *)groupArray
{
    NSMutableArray *deviceArray = [[NSMutableArray alloc]init];
    for (ESPGroup *group in groupArray) {
        NSArray *deviceArrayInGroup = group.espDeviceArray;
        for (ESPDevice *device in deviceArrayInGroup) {
            if (![deviceArray containsObject:device]) {
                [deviceArray addObject:device];
            }
        }
    }
    return deviceArray;
}

/**
 * discover the user's device from the Server
 *
 * @return the device array of the user
 */
- (NSArray *) doCommandDeviceDiscoverInternet:(NSString *)userKey
{
    long long currentTime = [ESPBaseApiUtil getUTCTimeLongLong];
    if (currentTime == LONG_LONG_MIN) {
        // the Internet is unaccessible
        return @[[ESPDevice ESP_DEVICE_INTERNET_UNACCESSIBLE]];
    }
    NSArray *groupJsonArray = [self sendRequest:userKey];
    if (groupJsonArray!=nil) {
        NSArray *groupArray = [self resolveResponse:groupJsonArray CurrentTime:currentTime];
        return [self resolveDeviceArrayFromGroupArray:groupArray];
    } else {
        return @[[ESPDevice ESP_DEVICE_INTERNET_UNACCESSIBLE]];
    }
}

@end
