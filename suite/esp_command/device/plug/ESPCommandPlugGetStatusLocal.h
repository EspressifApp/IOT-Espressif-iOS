//
//  ESPCommandPlugGetStatusLocal.h
//  suite
//
//  Created by 白 桦 on 10/13/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESPStatusPlug.h"
#import "ESPDevicePlug.h"

@interface ESPCommandPlugGetStatusLocal : NSObject

/**
 * get the statusLight to the Plug by Local
 *
 * @param device the plug device
 * @return the status of the Plug
 */
-(ESPStatusPlug *) doCommandPlugGetStatusLocal:(ESPDevicePlug *)device;

@end
