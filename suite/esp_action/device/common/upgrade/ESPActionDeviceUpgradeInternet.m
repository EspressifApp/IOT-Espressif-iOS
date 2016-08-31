//
//  ESPActionDeviceUpgradeInternet.m
//  suite
//
//  Created by 白 桦 on 6/24/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import "ESPActionDeviceUpgradeInternet.h"
#import "ESPBaseApiUtil.h"
#import "ESPConstantsHttpStatus.h"
#import "ESPUser.h"
#import "ESPBssidUtil.h"

#define AUTHORIZATION           @"Authorization"
#define TOKEN                   @"token"
#define URL_UPGRADE_INTERNET    @"https://iot.espressif.cn/v1/device/rpc/?deliver_to_device=true&action=sys_upgrade"
#define URL_UPGRAGE_GET_DEVICE  @"https://iot.espressif.cn/v1/device/?query_device_mesh=true"
#define URL_REBOOT_DEVICE       @"https://iot.espressif.cn/v1/device/rpc/?deliver_to_device=true&action=sys_reboot"

// 5 minutes = 5 * 60 = 300 seconds
#define TIMEOUT_SECONDS         300

#define RETRY_TIME_SECONDS      5

#define SLEEP_TIMEOUT           3

@implementation ESPActionDeviceUpgradeInternet

#pragma mark - do device upgrade internet

- (BOOL) doDeviceUpgradeInternet:(NSString *)deviceKey RomVersion:(NSString *)romVersion
{
    NSString *headerKey = AUTHORIZATION;
    NSString *headeValue = [NSString stringWithFormat:@"%@ %@",TOKEN,deviceKey];
    NSDictionary *header = @{headerKey:headeValue};
    NSString *url = [NSString stringWithFormat:@"%@&version=%@",URL_UPGRADE_INTERNET,romVersion];
    NSDictionary *responseJson = [ESPBaseApiUtil Get:url Headers:header];
    int status = -1;
    @try {
        if (responseJson!=nil) {
            status = [[responseJson objectForKey:@"status"]intValue];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"%@ %@ exception:%@",[self class],NSStringFromSelector(_cmd),exception);
    }
    if (status==HTTP_STATUS_OK) {
#ifdef DEBUG
        NSLog(@"%@ %@ deviceKey:%@ romVersion:%@ SUC",[self class],NSStringFromSelector(_cmd),deviceKey,romVersion);
#endif
        return YES;
    } else {
#ifdef DEBUG
        NSLog(@"%@ %@ deviceKey:%@ romVersion:%@ FAIL",[self class],NSStringFromSelector(_cmd),deviceKey,romVersion);
#endif
        return NO;
    }
}

#pragma mark - check device upgrade internet suc

- (ESPDevice *) getCurrentDeviceInternet:(NSString *)deviceKey
{
    NSString *headerKey = AUTHORIZATION;
    NSString *headerValue = [NSString stringWithFormat:@"%@ %@",TOKEN,deviceKey];
    NSDictionary *header = @{headerKey:headerValue};
    NSDictionary *responseJson = [ESPBaseApiUtil Get:URL_UPGRAGE_GET_DEVICE Headers:header];
    int status = -1;
    @try {
        if (responseJson!=nil) {
            status = [[responseJson objectForKey:@"status"]intValue];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"%@ %@ exception:%@",[self class],NSStringFromSelector(_cmd),exception);
    }
    if (status==HTTP_STATUS_OK) {
        @try {
            long long userId = [ESPUser sharedUser].espUserId;
            BOOL isOwner = YES;
            // deviceJson
            NSDictionary *deviceJson = [responseJson objectForKey:@"device"];
            long long deviceId = [[deviceJson objectForKey:@"id"]longLongValue];
            NSString *bssid = [deviceJson objectForKey:@"bssid"];
            NSString *deviceName = [deviceJson objectForKey:@"name"];
            // filter "device-name-"
            NSString *_deviceName = @"device-name-";
            const NSUInteger _deviceNamelength = [_deviceName length];
            if ([deviceName length] > _deviceNamelength) {
                NSString *deviceNamePre = [deviceName substringToIndex:_deviceNamelength];
                if ([deviceNamePre isEqualToString:_deviceName]) {
                    deviceName = [ESPBssidUtil genDeviceNameByBssid:bssid];
                }
            }
            int ptype = [[deviceJson objectForKey:@"ptype"]intValue];
            ESPDeviceType *deviceType = [ESPDeviceType resolveDeviceTypeBySerial:ptype];
            NSString *romVersion = [deviceJson objectForKey:@"rom_version"];
            NSString *latestRomVersion = [deviceJson objectForKey:@"latest_rom_version"];
            ESPDeviceState *deviceState = [[ESPDeviceState alloc]init];
            [deviceState addStateInternet];
            BOOL isMeshDevice = [deviceJson objectForKey:@"parent_mdev_mac"]!=nil;
            // parent device bssid
            NSString *parentBssid = nil;
            if (isMeshDevice) {
                NSString *_parentBssid = [deviceJson objectForKey:@"parent_mdev_mac"];
                if (![_parentBssid isEqualToString:@"null"]) {
                    parentBssid = _parentBssid;
                }
            }
            long long activatedTimeSecond = [[deviceJson objectForKey:@"activated_at"]longLongValue];
            NSDate *activatedTimestamp = [NSDate dateWithTimeIntervalSince1970:activatedTimeSecond];
            ESPDevice *device = [[ESPDevice alloc]initWithDeviceName:deviceName DeviceId:deviceId DeviceKey:deviceKey IsOwner:isOwner Bssid:bssid DeviceState:deviceState DeviceType:deviceType RomVersion:romVersion LatestRomVersion:latestRomVersion UserId:userId IsMeshDevice:isMeshDevice ParentBssid:parentBssid ActivatedTimestamp:activatedTimestamp];
#ifdef DEBUG
//            NSLog(@"%@ %@ device:%@",[self class],NSStringFromSelector(_cmd),device);
#endif
            return device;

        }
        @catch (NSException *exception) {
            NSLog(@"%@ %@ exception:%@",[self class],NSStringFromSelector(_cmd),exception);
        }
    }
    return nil;
}

- (ESPDevice *) checkDeviceUpgradeInternetSuc:(NSString *)deviceKey
{
    NSTimeInterval startTime = [NSDate date].timeIntervalSince1970;
    NSTimeInterval currentTime;
    ESPDevice *device = nil;
    while (device==nil) {
        device = [self getCurrentDeviceInternet:deviceKey];
        if (device!=nil) {
            // check whether the device has upgrade internet suc already
            NSString *romVersionCur = device.espRomVersionCurrent;
            NSString *romVersionLat = device.espRomVersionLatest;
            if (romVersionCur==nil||romVersionLat==nil||![romVersionCur isEqualToString:romVersionLat]) {
                device = nil;
            }
        }
        if (device==nil) {
            currentTime = [NSDate date].timeIntervalSince1970;
            if (currentTime - startTime > TIMEOUT_SECONDS) {
#ifdef DEBUG
                NSLog(@"%@ %@ deviceKey:%@ tiemout",[self class],NSStringFromSelector(_cmd),deviceKey);
#endif
                break;
            } else {
                [NSThread sleepForTimeInterval:RETRY_TIME_SECONDS];
            }
        }
    }
    return device;
}

#pragma mark - reboot device internet

- (void) rebootDeviceInternet:(NSString *)deviceKey
{
    NSString *headerKey = AUTHORIZATION;
    NSString *headerValue = [NSString stringWithFormat:@"%@ %@",TOKEN,deviceKey];
    NSDictionary *header = @{headerKey:headerValue};
    NSDictionary *responseJson = [ESPBaseApiUtil Get:URL_REBOOT_DEVICE Headers:header];
    int status = -1;
    @try {
        if (responseJson!=nil) {
            status = [[responseJson objectForKey:@"status"]intValue];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"%@ %@ exception:%@",[self class],NSStringFromSelector(_cmd),exception);
    }
    if (status==HTTP_STATUS_OK) {
#ifdef DEBUG
        NSLog(@"%@ %@ deviceKey:%@ SUC",[self class],NSStringFromSelector(_cmd),deviceKey);
#endif
    } else {
#ifdef DEBUG
        NSLog(@"%@ %@ deviceKey:%@ FAIL",[self class],NSStringFromSelector(_cmd),deviceKey);
#endif
    }
}

- (BOOL) doUpgradeInternetDeviceInternal:(ESPDevice *)device
{
    NSString *deviceKey = device.espDeviceKey;
    NSString *romVersion = device.espRomVersionLatest;
    BOOL isUpgradeSuc = [self doDeviceUpgradeInternet:deviceKey RomVersion:romVersion];
    if (isUpgradeSuc) {
        ESPDevice *upgradedDevice = [self checkDeviceUpgradeInternetSuc:deviceKey];
        if (upgradedDevice!=nil) {
            [self rebootDeviceInternet:deviceKey];
            // suc
#ifdef DEBUG
            NSLog(@"%@ %@ device:%@ suc",[self class],NSStringFromSelector(_cmd),device);
#endif
            return YES;
        } else {
            // fail to confirm device upgrade internet suc
#ifdef DEBUG
            NSLog(@"%@ %@ device:%@ fail to confirm device upgrade internet suc",[self class],NSStringFromSelector(_cmd),device);
#endif
            return NO;
        }
    } else {
        // fail to send upgrade internet action to device
#ifdef DEBUG
        NSLog(@"%@ %@ device:%@ fail to send upgrade internet action to device",[self class],NSStringFromSelector(_cmd),device);
#endif
        return NO;
    }
}

/**
 * upgrade device by internet
 *
 * @param device the device to be upgraded
 * @return the device after internet upgrading
 */
- (BOOL) doUpgradeInternetDevice:(ESPDevice *)device
{
    ESPUser *user = [ESPUser sharedUser];
    // 1. push current device
    ESPDevice *currentDevice = [device copy];
    // 2. transform current device(isUsing=YES and deviceState=upgradeLocal)
    ESPDevice *upgradingDevice = [device copy];
    upgradingDevice.espIsUsing = YES;
    [upgradingDevice.espDeviceState clearState];
    [upgradingDevice.espDeviceState addStateUpgradeInternet];
    [user addDeviceTransform:upgradingDevice];
    [user notifyDevicesArrive];
    // 3. do upgrading by internet
    BOOL isSuc = [self doUpgradeInternetDeviceInternal:device];
    if (isSuc) {
        // sleep some seconds let device connect to AP
        [NSThread sleepForTimeInterval:SLEEP_TIMEOUT];
    }
    // 4. pop current device and transform current device(isUsing=NO and deviceState=offline and other origin device states)
    // it should be NO even we don't set it
    currentDevice.espIsUsing = NO;
    [currentDevice.espDeviceState clearStateLocal];
    [currentDevice.espDeviceState clearStateInternet];
    [currentDevice.espDeviceState addStateOffline];
    [user addDeviceTransform:currentDevice];
    // 5. discover devices local and internet
    [user doActionRefreshAllDevices:YES];
    [user notifyDevicesArrive];
    
    return isSuc;
}
@end
