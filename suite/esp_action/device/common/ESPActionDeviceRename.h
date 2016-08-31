//
//  ESPActionDeviceRename.h
//  suite
//
//  Created by 白 桦 on 8/16/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESPDevice.h"

@interface ESPActionDeviceRename : NSObject

/**
 * rename the device on Server, if fail tag rename state on local database
 *
 * @param device the device to be renamed
 * @param deviceName the device's new name
 * @param instantly rename device name instantly or not
 */
- (void) doActionDeviceRenameInternetAsync:(ESPDevice *)device DeviceName:(NSString *)deviceName Instantly:(BOOL)instantly;

/**
 * rename the device on local database
 *
 * @param device the device to be renamed
 * @param deviceName the device's new name
 * @param instantly rename device name instantly or not
 */
- (void) doActionDeviceRenameLocalAsync:(ESPDevice *)device DeviceName:(NSString *)deviceName Instantly:(BOOL)notify;

@end
