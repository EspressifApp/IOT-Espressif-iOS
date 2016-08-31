//
//  ESPCommandLightGetStatusInternet.h
//  suite
//
//  Created by 白 桦 on 6/8/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESPStatusLight.h"
#import "ESPDeviceLight.h"

#define URL @"https://iot.espressif.cn/v1/datastreams/light/datapoint/?deliver_to_device=true"

@interface ESPCommandLightGetStatusInternet : NSObject

/**
 * get the statusLight to the Light by Internet
 *
 * @param device the light device
 * @return the status of the Light
 */
-(ESPStatusLight *)doCommandLightGetStatusInternet:(ESPDeviceLight *)device;

@end
