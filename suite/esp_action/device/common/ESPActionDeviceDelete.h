//
//  ESPActionDeviceDelete.h
//  suite
//
//  Created by 白 桦 on 8/16/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESPDevice.h"

@interface ESPActionDeviceDelete : NSObject

/**
 * delete the device on Server, if fail tag delete state on local database
 *
 * @param device the device to be deleted
 * @param instantly delete device instantly or not
 */
- (void) doActionDeviceDeleteInternetAsync:(ESPDevice *)device Instantly:(BOOL)instantly;

/**
 * delete the device on local database
 *
 * @param device the device to be deleted
 * @param instantly delete device instantly or not
 */
- (void) doActionDeviceDeleteLocalAsync:(ESPDevice *)device Instantly:(BOOL)instantly;

@end
