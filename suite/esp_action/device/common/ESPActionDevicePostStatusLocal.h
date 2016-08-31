//
//  ESPActionDevicePostStatusLocal.h
//  suite
//
//  Created by 白 桦 on 6/8/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESPDevice.h"
#import "ESPDeviceStatus.h"


@interface ESPActionDevicePostStatusLocal : NSObject

/**
 * post the status to device via local
 *
 * @param device the device
 * @param status the new status
 * @return whether the post action is suc
 */
-(BOOL) doActionDevicePostStatusLocalDevice:(ESPDevice *)device Status:(ESPDeviceStatus *)status;

@end
