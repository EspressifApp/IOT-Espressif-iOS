//
//  ESPCommandLightGetStatusLocal.h
//  suite
//
//  Created by 白 桦 on 6/8/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESPStatusLight.h"
#import "ESPDeviceLight.h"

@interface ESPCommandLightGetStatusLocal : NSObject

/**
 * get the statusLight to the Light by Local
 *
 * @param device the light device
 * @return the status of the Light
 */
-(ESPStatusLight *) doCommandLightGetStatusLocal:(ESPDeviceLight *)device;
@end
