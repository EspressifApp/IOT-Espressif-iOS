//
//  ESPActionDeviceUpgradeInternet.h
//  suite
//
//  Created by 白 桦 on 6/24/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESPDevice.h"

@interface ESPActionDeviceUpgradeInternet : NSObject

/**
 * upgrade device by internet
 *
 * @param device the device to be upgraded
 * @return the device after internet upgrading
 */
- (BOOL) doUpgradeInternetDevice:(ESPDevice *)device;

@end
