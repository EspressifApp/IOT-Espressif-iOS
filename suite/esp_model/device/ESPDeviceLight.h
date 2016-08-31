//
//  ESPDeviceLight.h
//  suite
//
//  Created by 白 桦 on 5/25/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import "ESPDevice.h"
#import "ESPStatusLight.h"

@interface ESPDeviceLight : ESPDevice

@property (nonatomic, strong) ESPStatusLight *espStatusLight;

@end
