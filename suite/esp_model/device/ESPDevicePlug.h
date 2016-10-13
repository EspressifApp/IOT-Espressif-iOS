//
//  ESPDevicePlug.h
//  suite
//
//  Created by 白 桦 on 10/13/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import "ESPDevice.h"
#import "ESPStatusPlug.h"

@interface ESPDevicePlug : ESPDevice

@property (nonatomic, strong) ESPStatusPlug *espStatusPlug;

@end
