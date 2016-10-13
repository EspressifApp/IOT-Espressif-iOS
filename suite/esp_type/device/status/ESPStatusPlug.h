//
//  ESPStatusPlug.h
//  suite
//
//  Created by 白 桦 on 10/13/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESPDeviceStatus.h"

@interface ESPStatusPlug : ESPDeviceStatus<NSCopying>

@property (nonatomic, assign) bool espIsOn;

@end
