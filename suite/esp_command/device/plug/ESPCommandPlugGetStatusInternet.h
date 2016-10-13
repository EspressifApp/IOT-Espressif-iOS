//
//  ESPCommandPlugGetStatusInternet.h
//  suite
//
//  Created by 白 桦 on 10/13/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESPStatusPlug.h"
#import "ESPDevicePlug.h"

#define URL @"https://iot.espressif.cn/v1/datastreams/plug-status/datapoint/?deliver_to_device=true"

@interface ESPCommandPlugGetStatusInternet : NSObject

/**
 * get the statusPlug to the Plug by Internet
 *
 * @param device the plug device
 * @return the status of the Plug
 */
-(ESPStatusPlug *)doCommandPlugGetStatusInternet:(ESPDevicePlug *)device;

@end
