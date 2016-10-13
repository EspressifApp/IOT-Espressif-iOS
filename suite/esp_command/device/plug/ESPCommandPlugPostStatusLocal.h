//
//  ESPCommandPlugPostStatusLocal.h
//  suite
//
//  Created by 白 桦 on 10/13/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESPStatusPlug.h"
#import "ESPDevicePlug.h"

@interface ESPCommandPlugPostStatusLocal : NSObject

/**
 * post the statusPlug to the Plug by Local
 *
 * @param device the plug device
 * @param statusPlug the status of Light
 * @return whether the command executed suc
 */
-(BOOL) doCommandLightPostStatusLocal:(ESPDevicePlug *)device StatusPlug:(ESPStatusPlug *)statusPlug;

@end
