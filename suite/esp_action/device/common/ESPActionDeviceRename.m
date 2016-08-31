//
//  ESPActionDeviceRename.m
//  suite
//
//  Created by 白 桦 on 8/16/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import "ESPActionDeviceRename.h"
#import "ESPCommandDeviceRenameInternet.h"
#import "DEspDeviceManager.h"
#import "ESPUser.h"
#import "ESPGlobalTaskHandler.h"

@implementation ESPActionDeviceRename

- (BOOL) renameDeviceInternet:(ESPDevice *)device DeviceName:(NSString *)deviceName
{
    // do device rename internet command
    ESPCommandDeviceRenameInternet *command = [[ESPCommandDeviceRenameInternet alloc]init];
    return [command doCommandDeviceRenameInternet:device DeviceName:deviceName];
}

- (void) updateDeviceInDB:(ESPDevice *)device
{
    // update device in local db
    DEspDeviceManager *deviceManager = [DEspDeviceManager sharedDeviceManager];
    [deviceManager update:device.espDaoEspDevice];
}

- (void) clearIsRenamedJustNow:(ESPDevice *)device
{
    // clear espIsRenamedJustNow
    device._espIsRenamedJustNow = NO;
    // update device in local db
    // (it may be unnecessary to update local db sometime, just do it to simplify code logical)
    DEspDeviceManager *deviceManager = [DEspDeviceManager sharedDeviceManager];
    [deviceManager update:device.espDaoEspDevice];
    
    ESPUser *user = [ESPUser sharedUser];
    [user addDeviceTransform:device];
    // notify UI to refresh
    [user notifyDevicesArrive];
}

-(void) renameDeviceInstantly:(ESPDevice *)device DeviceName:(NSString *)deviceName
{
    ESPUser *user = [ESPUser sharedUser];
    // add transfrom device for user
    device.espDeviceName = deviceName;
    device._espIsRenamedJustNow = YES;
    [device.espDeviceState addStateRenamed];
    [user addDeviceTransform:device];
}

/**
 * rename the device on Server, if fail tag rename state on local database
 *
 * @param device the device to be renamed
 * @param deviceName the device's new name
 * @param instantly rename device name instantly or not
 */
- (void) doActionDeviceRenameInternetAsync:(ESPDevice *)device DeviceName:(NSString *)deviceName Instantly:(BOOL)instantly
{
    __block ESPDevice *copyDevice = [device copy];
    [self renameDeviceInstantly:copyDevice DeviceName:deviceName];
    if (instantly) {
        ESPUser *user = [ESPUser sharedUser];
        // notity UI to refresh
        [user notifyDevicesArrive];
    }
    
    ESPGlobalTaskHandler *handler = [ESPGlobalTaskHandler sharedGlobalTaskHandler];
    
    ESPTask *task = [[ESPTask alloc]init];
    task.espBlock = ^{
        BOOL isSuc = [self renameDeviceInternet:copyDevice DeviceName:deviceName];
        if (isSuc) {
            [self clearIsRenamedJustNow:copyDevice];
        } else {
            [self updateDeviceInDB:copyDevice];
        }
    };
    
    [handler submit:task];
}

/**
 * rename the device on local database
 *
 * @param device the device to be renamed
 * @param deviceName the device's new name
 * @param instantly rename device name instantly or not
 */
- (void) doActionDeviceRenameLocalAsync:(ESPDevice *)device DeviceName:(NSString *)deviceName Instantly:(BOOL)instantly
{
    __block ESPDevice *copyDevice = [device copy];
    [self renameDeviceInstantly:copyDevice DeviceName:deviceName];
    if (instantly) {
        ESPUser *user = [ESPUser sharedUser];
        // notity UI to refresh
        [user notifyDevicesArrive];
    }
    
    ESPGlobalTaskHandler *handler = [ESPGlobalTaskHandler sharedGlobalTaskHandler];
    
    ESPTask *task = [[ESPTask alloc]init];
    task.espBlock = ^{
        [self updateDeviceInDB:copyDevice];
    };

    [handler submit:task];
}

@end
