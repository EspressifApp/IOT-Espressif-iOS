//
//  ESPActionDeviceGetStatusLocal.m
//  suite
//
//  Created by 白 桦 on 6/8/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import "ESPActionDeviceGetStatusLocal.h"
#import "ESPCommandLightGetStatusLocal.h"
#import "ESPCommandPlugGetStatusLocal.h"
#import "ESPDeviceLight.h"
#import "ESPDevicePlug.h"

@implementation ESPActionDeviceGetStatusLocal

/**
 * get the current status of device via local)
 *
 * @param device the device
 * @return whether the get action is suc
 */
-(BOOL) doActionDeviceGetStatusLocalDevice:(ESPDevice *)device
{
    ESPDeviceType *deviceType = device.espDeviceType;
    switch (deviceType.espTypeEnum) {
        case FLAMMABLE_ESP_DEVICETYPE:
            break;
        case HUMITURE_ESP_DEVICETYPE:
            break;
        case LIGHT_ESP_DEVICETYPE:
            return [self executeGetLightStatusLocalDeviceLight:(ESPDeviceLight *)device];
        case NEW_ESP_DEVICETYPE:
            break;
        case PLUG_ESP_DEVICETYPE:
            return [self executeGetPlugStatusLocalDevicePlug:(ESPDevicePlug *)device];
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

-(BOOL) executeGetPlugStatusLocalDevicePlug:(ESPDevicePlug *)plug
{
    BOOL result = NO;
    ESPCommandPlugGetStatusLocal *plugCommand = [[ESPCommandPlugGetStatusLocal alloc]init];
    ESPStatusPlug *plugStatus = [plugCommand doCommandPlugGetStatusLocal:plug];
    if (plugStatus!=nil) {
        result = YES;
        ESPStatusPlug *currentPlugStatus = plug.espStatusPlug;
        currentPlugStatus.espIsOn = plugStatus.espIsOn;
    }
    return result;
}

-(BOOL) executeGetLightStatusLocalDeviceLight:(ESPDeviceLight *)light
{
    BOOL result = NO;
    ESPCommandLightGetStatusLocal *lightCommand = [[ESPCommandLightGetStatusLocal alloc]init];
    ESPStatusLight *lightStatus = [lightCommand doCommandLightGetStatusLocal:light];
    if (lightStatus!=nil) {
        result = YES;
        ESPStatusLight *currentLightStatus = light.espStatusLight;
        currentLightStatus.espPeriod = lightStatus.espPeriod;
        currentLightStatus.espRed = lightStatus.espRed;
        currentLightStatus.espGreen = lightStatus.espGreen;
        currentLightStatus.espBlue = lightStatus.espBlue;
        currentLightStatus.espCwhite = lightStatus.espCwhite;
        currentLightStatus.espWwhite = lightStatus.espWwhite;
        currentLightStatus.espStatus = lightStatus.espStatus;
        currentLightStatus.espWhite = lightStatus.espWhite;
    }
    
    return result;
}


@end
