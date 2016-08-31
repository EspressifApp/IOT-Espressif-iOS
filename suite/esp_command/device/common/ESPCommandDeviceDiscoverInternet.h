//
//  ESPCommandDeviceDiscoverInternet.h
//  suite
//
//  Created by 白 桦 on 6/1/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import <Foundation/Foundation.h>

#define URL             @"https://iot.espressif.cn/v1/user/devices/?list_by_group=true&query_devices_mesh=true"
#define ACTIVATED_AT    @"activated_at"
#define DEVICES         @"devices"
#define IS_OWNER_KEY    @"is_owner_key"
#define DEVICE_GROUPS   @"deviceGroups"

@interface ESPCommandDeviceDiscoverInternet : NSObject

/**
 * discover the user's device from the Server
 *
 * @return the device array of the user
 */
- (NSArray *) doCommandDeviceDiscoverInternet:(NSString *)userKey;

@end
