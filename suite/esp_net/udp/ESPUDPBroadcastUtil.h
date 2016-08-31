//
//  ESPUDPBroadcastUtil.h
//  MeshProxy
//
//  Created by 白 桦 on 4/28/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESPIOTAddress.h"

@interface ESPUDPBroadcastUtil : NSObject

/**
 * discover the specified IOT device in the same AP by UDP broadcast
 *
 * @param bssid the IOT device's bssid
 * @return the specified device's ESPIOTAddress (if found) or null(if not found)
 */
+ (ESPIOTAddress *)discoverIOTDevice:(NSString *)bssid;

/**
 * @see IOTAddress discover IOT devices in the same AP by UDP broadcast
 *
 * @return the Array of ESPIOTAddress
 */
+ (NSArray *)discoverIOTDevices;

@end
