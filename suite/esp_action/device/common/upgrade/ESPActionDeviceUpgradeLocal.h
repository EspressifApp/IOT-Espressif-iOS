//
//  ESPActionDeviceUpgradeLocal.h
//  suite
//
//  Created by 白 桦 on 6/21/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESPDevice.h"

@interface ESPActionDeviceUpgradeLocal : NSObject

/**
 * upgrade device by local
 *
 * @param device the device to be upgraded
 * @return whether device upgrade local suc or fail
 */
- (BOOL) doUpgradeLocalDevice:(ESPDevice *)device;

@end
