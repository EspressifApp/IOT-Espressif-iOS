//
//  ESPMeshDiscoverUtil.h
//  MeshProxy
//
//  Created by 白 桦 on 5/3/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESPIOTAddress.h"


@interface ESPMeshDiscoverUtil : NSObject

/**
 * discover the IOT devices in the same AP
 *
 * @return the Array of ESPIOTAddress
 */
+ (NSArray *) discoverIOTDevices;

/**
 * discover the IOT device in the same AP by its bssid
 * @param bssid the device's bssid
 *
 * @return the ESPIOTAddress
 */
+ (ESPIOTAddress *) discoverIOTDevice:(NSString *)bssid;

@end
