//
//  ESPLightStatusUtil.m
//  suite
//
//  Created by 白 桦 on 6/8/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import "ESPLightStatusUtil.h"
#define PERIOD  1000

@implementation ESPLightStatusUtil

+(int) device2uiPeriod:(int)period Value:(int)value
{
    int max_rgb_device = period * 1000 / 45;
    int max_rgb_ui = 255;
    return max_rgb_ui * value / max_rgb_device;
}

+(int) ui2devicePeriod:(int)period Value:(int)value
{
    int max_rgb_device = period * 1000 / 45;
    int max_rgb_ui = 255;
    int value_ui = value;
    int value_device = max_rgb_device * value / max_rgb_ui;
    int value_ui_inverse = [self device2uiPeriod:period Value:value_device];
    while (value_ui_inverse!=value_ui) {
        if (value_ui_inverse>value_ui) {
            value_ui_inverse = [self device2uiPeriod:period Value:--value_device];
        } else {
            value_ui_inverse = [self device2uiPeriod:period Value:++value_device];
        }
    }
    return value_device;
}

// device to ui
+(ESPStatusLight *) device2ui:(ESPStatusLight *)status
{
    ESPStatusLight *statusUi = [[ESPStatusLight alloc]init];
    statusUi.espRed = [self device2uiPeriod:status.espPeriod Value:status.espRed];
    statusUi.espGreen = [self device2uiPeriod:status.espPeriod Value:status.espGreen];
    statusUi.espBlue = [self device2uiPeriod:status.espPeriod Value:status.espBlue];
    statusUi.espPeriod = status.espPeriod;
    statusUi.espCwhite = status.espCwhite;
    statusUi.espWwhite = status.espWwhite;
    return statusUi;
}

// ui to device
+(ESPStatusLight *) ui2device:(ESPStatusLight *)status
{
    status.espPeriod = PERIOD;
    ESPStatusLight *statusDevice = [[ESPStatusLight alloc]init];
    statusDevice.espRed = [self ui2devicePeriod:status.espPeriod Value:status.espRed];
    statusDevice.espGreen = [self ui2devicePeriod:status.espPeriod Value:status.espGreen];
    statusDevice.espBlue = [self ui2devicePeriod:status.espPeriod Value:status.espBlue];
    statusDevice.espPeriod = status.espPeriod;
    statusDevice.espCwhite = status.espCwhite;
    statusDevice.espWwhite = status.espWwhite;
    return statusDevice;
}

// constrain value
+(ESPStatusLight *) constrain:(ESPStatusLight *)status
{
    ESPStatusLight *statusResult = [[ESPStatusLight alloc]init];
    statusResult.espPeriod = status.espPeriod;
    statusResult.espStatus = status.espStatus;
    statusResult.espRed = MAX(0, status.espRed);
    statusResult.espRed = MIN(statusResult.espRed, 255);
    statusResult.espGreen = MAX(0, status.espGreen);
    statusResult.espGreen = MIN(statusResult.espGreen, 255);
    statusResult.espBlue = MAX(0, status.espBlue);
    statusResult.espBlue = MIN(statusResult.espBlue, 255);
    statusResult.espCwhite = MAX(0, status.espCwhite);
    statusResult.espCwhite = MIN(statusResult.espCwhite, 255);
    statusResult.espWwhite = MAX(0, status.espWwhite);
    statusResult.espWwhite = MIN(statusResult.espWwhite, 255);
    statusResult.espWhite = MAX(0, status.espWhite);
    statusResult.espWhite = MIN(statusResult.espWhite, 255);
    return statusResult;
}

@end
