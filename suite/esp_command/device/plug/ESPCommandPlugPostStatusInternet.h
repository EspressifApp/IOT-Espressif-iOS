//
//  ESPCommandPlugPostStatusInternet.h
//  suite
//
//  Created by 白 桦 on 10/13/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESPStatusPlug.h"
#import "ESPDevicePlug.h"

#define URL @"https://iot.espressif.cn/v1/datastreams/plug-status/datapoint/?deliver_to_device=true"

@interface ESPCommandPlugPostStatusInternet : NSObject

/**
 * post the statusPlug to the Plug by Internet
 *
 * @param device the plug device
 * @param statusPlug the status of Plug
 * @return whether the command executed suc
 */
-(BOOL) doCommandPlugPostStatusInternet:(ESPDevicePlug *)device StatusPlug:(ESPStatusPlug *)statusPlug;

@end
