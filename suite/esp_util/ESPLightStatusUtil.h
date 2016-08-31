//
//  ESPLightStatusUtil.h
//  suite
//
//  Created by 白 桦 on 6/8/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESPStatusLight.h"


@interface ESPLightStatusUtil : NSObject
// device to ui
+(ESPStatusLight *) device2ui:(ESPStatusLight *)status;
// ui to device
+(ESPStatusLight *) ui2device:(ESPStatusLight *)status;
// constrain value
+(ESPStatusLight *) constrain:(ESPStatusLight *)status;
@end
