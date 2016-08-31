//
//  ESPActionDevicePostStatusLocal.m
//  suite
//
//  Created by 白 桦 on 6/8/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import "ESPActionDevicePostStatusLocal.h"
#import "ESPCommandLightPostStatusLocal.h"
#import "ESPDeviceLight.h"

@implementation ESPActionDevicePostStatusLocal

/**
 * post the status to device via local
 *
 * @param device the device
 * @param status the new status
 * @return whether the post action is suc
 */
-(BOOL) doActionDevicePostStatusLocalDevice:(ESPDevice *)device Status:(ESPDeviceStatus *)status
{
    ESPDeviceType *deviceType = device.espDeviceType;
    switch (deviceType.espTypeEnum) {
        case FLAMMABLE_ESP_DEVICETYPE:
            break;
        case HUMITURE_ESP_DEVICETYPE:
            break;
        case LIGHT_ESP_DEVICETYPE:
            return [self executePostLightStatusLocalDeviceLight:(ESPDeviceLight *)device Status:(ESPStatusLight *)status];
        case NEW_ESP_DEVICETYPE:
            break;
        case PLUG_ESP_DEVICETYPE:
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
    abort();
}

-(BOOL) executePostLightStatusLocalDeviceLight:(ESPDeviceLight *)light Status:(ESPStatusLight *)status
{
    ESPCommandLightPostStatusLocal *lightCommand = [[ESPCommandLightPostStatusLocal alloc]init];
    BOOL result = [lightCommand doCommandLightPostStatusLocal:light StatusLight:status];
    if (result) {
        ESPStatusLight *lightStatus = light.espStatusLight;
        lightStatus.espPeriod = status.espPeriod;
        lightStatus.espRed = status.espRed;
        lightStatus.espGreen = status.espGreen;
        lightStatus.espBlue = status.espBlue;
        lightStatus.espCwhite = status.espCwhite;
        lightStatus.espWwhite = status.espWwhite;
        lightStatus.espStatus = status.espStatus;
        lightStatus.espWhite = status.espWhite;
    }
    return result;
}

@end
