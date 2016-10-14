//
//  ESPActionDevicePostStatusInternet.m
//  suite
//
//  Created by 白 桦 on 6/8/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import "ESPActionDevicePostStatusInternet.h"
#import "ESPDeviceType.h"
#import "ESPDeviceLight.h"
#import "ESPDevicePlug.h"
#import "ESPCommandLightPostStatusInternet.h"
#import "ESPCommandPlugPostStatusInternet.h"

@implementation ESPActionDevicePostStatusInternet

/**
 * post the status to device via Internet
 *
 * @param device the device
 * @param status the new status
 * @return whether the post action is suc
 */
-(BOOL) doActionDevicePostStatusInternetDevice:(ESPDevice *)device Status:(ESPDeviceStatus *)status
{
    ESPDeviceType *deviceType = device.espDeviceType;
    switch (deviceType.espTypeEnum) {
        case FLAMMABLE_ESP_DEVICETYPE:
            break;
        case HUMITURE_ESP_DEVICETYPE:
            break;
        case LIGHT_ESP_DEVICETYPE:
            return [self executePostLightStatusInternetDeviceLight:(ESPDeviceLight *)device Status:(ESPStatusLight *)status];
        case NEW_ESP_DEVICETYPE:
            break;
        case PLUG_ESP_DEVICETYPE:
            return [self executePostPlugStatusInternetDevicePlug:(ESPDevicePlug *)device Status:(ESPStatusPlug *)status];
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

-(BOOL) executePostPlugStatusInternetDevicePlug:(ESPDevicePlug *)plug Status:(ESPStatusPlug *)status
{
    ESPCommandPlugPostStatusInternet *plugCommand = [[ESPCommandPlugPostStatusInternet alloc]init];
    BOOL result = [plugCommand doCommandPlugPostStatusInternet:plug StatusPlug:status];
    if (result) {
        ESPStatusPlug *plugStatus = plug.espStatusPlug;
        plugStatus.espIsOn = status.espIsOn;
    }
    return result;
}

-(BOOL) executePostLightStatusInternetDeviceLight:(ESPDeviceLight *)light Status:(ESPStatusLight *)status
{
    ESPCommandLightPostStatusInternet *lightCommand = [[ESPCommandLightPostStatusInternet alloc]init];
    BOOL result = [lightCommand doCommandLightPostStatusInternet:light StatusLight:status];
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
