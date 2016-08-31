//
//  ESPActionDeviceGetStatusInternet.h
//  suite
//
//  Created by 白 桦 on 6/8/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESPDevice.h"

@interface ESPActionDeviceGetStatusInternet : NSObject

/**
 * get the current status of device via internet)
 *
 * @param device the device
 * @return whether the get action is suc
 */
-(BOOL) doActionDeviceGetStatusInternetDevice:(ESPDevice *)device;

@end
