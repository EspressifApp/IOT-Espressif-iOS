//
//  ESPActionDeviceGetStatusInternet.m
//  suite
//
//  Created by 白 桦 on 6/8/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import "ESPActionDeviceGetStatusInternet.h"
#import "ESPCommandLightGetStatusInternet.h"
#import "ESPCommandPlugGetStatusInternet.h"
#import "ESPDeviceLight.h"
#import "ESPDevicePlug.h"
#import "ESPDeviceType.h"

@implementation ESPActionDeviceGetStatusInternet

/**
 * get the current status of device via internet)
 *
 * @param device the device
 * @return whether the get action is suc
 */
-(BOOL) doActionDeviceGetStatusInternetDevice:(ESPDevice *)device
{
    ESPDeviceType *deviceType = device.espDeviceType;
    switch (deviceType.espTypeEnum) {
        case FLAMMABLE_ESP_DEVICETYPE:
            break;
        case HUMITURE_ESP_DEVICETYPE:
            break;
        case LIGHT_ESP_DEVICETYPE:
            return [self executeGetLightStatusInternetDeviceLight:(ESPDeviceLight *)device];
        case NEW_ESP_DEVICETYPE:
            break;
        case PLUG_ESP_DEVICETYPE:
            return [self executeGetPlugStatusInternetDevicePlug:(ESPDevicePlug *)device];
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

-(BOOL) executeGetPlugStatusInternetDevicePlug:(ESPDevicePlug *)plug
{
    BOOL result = NO;
    ESPCommandPlugGetStatusInternet *plugCommand = [[ESPCommandPlugGetStatusInternet alloc]init];
    ESPStatusPlug *plugStatus = [plugCommand doCommandPlugGetStatusInternet:plug];
    if (plugStatus!=nil) {
        result = YES;
        ESPStatusPlug *currentPlugStatus = plug.espStatusPlug;
        currentPlugStatus.espIsOn = plugStatus.espIsOn;
    }
    return result;
}

-(BOOL) executeGetLightStatusInternetDeviceLight:(ESPDeviceLight *)light
{
    BOOL result = NO;
    ESPCommandLightGetStatusInternet *lightCommand = [[ESPCommandLightGetStatusInternet alloc]init];
    ESPStatusLight *lightStatus = [lightCommand doCommandLightGetStatusInternet:light];
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
