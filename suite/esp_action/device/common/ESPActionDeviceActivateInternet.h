//
//  ESPActionDeviceActivateInternet.h
//  suite
//
//  Created by 白 桦 on 7/27/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESPDevice.h"

@interface ESPActionDeviceActivateInternet : NSObject

/**
 * Activate the new device online
 *
 * @param userId the user's id
 * @param userKey the user's key
 * @param randomToken the random token
 * @return the new activated device
 */
- (ESPDevice *) doActionDeviceActivateInternetUserId:(long long)userId UserKey:(NSString *)userKey RandomToken:(NSString *)randomToken;

@end
