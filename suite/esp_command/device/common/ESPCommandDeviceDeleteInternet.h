//
//  ESPCommandDeviceDeleteInternet.h
//  suite
//
//  Created by 白 桦 on 8/16/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESPDevice.h"

@interface ESPCommandDeviceDeleteInternet : NSObject

/**
 * delete the device on Server
 * @param device the device to be deleted
 *
 * @return whether the command executed suc
 */
- (BOOL) doCommandDeviceRenameInternet:(ESPDevice *)device;

@end
