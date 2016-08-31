//
//  ESPActionDeviceDelete.m
//  suite
//
//  Created by 白 桦 on 8/16/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import "ESPActionDeviceDelete.h"
#import "ESPCommandDeviceDeleteInternet.h"
#import "DEspDeviceManager.h"
#import "ESPUser.h"
#import "ESPGlobalTaskHandler.h"

@implementation ESPActionDeviceDelete

- (BOOL) deleteDeviceInternet:(ESPDevice *)device
{
    // do device delete internet command
    ESPCommandDeviceDeleteInternet *command = [[ESPCommandDeviceDeleteInternet alloc]init];
    return [command doCommandDeviceRenameInternet:device];
}

- (void) updateDeviceInDB:(ESPDevice *)device
{
    // update device in local db
    DEspDeviceManager *deviceManager = [DEspDeviceManager sharedDeviceManager];
    [deviceManager update:device.espDaoEspDevice];
}

-(void) deleteDeviceInstantly:(ESPDevice *)device
{
    ESPUser *user = [ESPUser sharedUser];
    // add transfrom device for user
    [device.espDeviceState addStateDeleted];
    [user addDeviceTransform:device];
}

/**
 * delete the device on Server, if fail tag delete state on local database
 *
 * @param device the device to be deleted
 * @param instantly delete device instantly or not
 */
- (void) doActionDeviceDeleteInternetAsync:(ESPDevice *)device Instantly:(BOOL)instantly
{
    __block ESPDevice *copyDevice = [device copy];
    [self deleteDeviceInstantly:copyDevice];
    if (instantly) {
        ESPUser *user = [ESPUser sharedUser];
        [user notifyDevicesArrive];
    }
    
    ESPGlobalTaskHandler *handler = [ESPGlobalTaskHandler sharedGlobalTaskHandler];
    
    ESPTask *task = [[ESPTask alloc]init];
    task.espBlock = ^{
        BOOL isSuc = [self deleteDeviceInternet:copyDevice];
        if (isSuc) {
            [copyDevice remove];
        } else {
            [self updateDeviceInDB:copyDevice];
        }
    };
    
    [handler submit:task];
}

/**
 * delete the device on local database
 *
 * @param device the device to be deleted
 * @param instantly delete device instantly or not
 */
- (void) doActionDeviceDeleteLocalAsync:(ESPDevice *)device Instantly:(BOOL)instantly
{
    __block ESPDevice *copyDevice = [device copy];
    [self deleteDeviceInstantly:copyDevice];
    if (instantly) {
        ESPUser *user = [ESPUser sharedUser];
        [user notifyDevicesArrive];
    }
    
    ESPGlobalTaskHandler *handler = [ESPGlobalTaskHandler sharedGlobalTaskHandler];
    
    ESPTask *task = [[ESPTask alloc]init];
    task.espBlock = ^{
        [copyDevice remove];
    };
    
    [handler submit:task];
}

@end
