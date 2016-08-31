//
//  ESPCommandDeviceDiscoverLocal.m
//  suite
//
//  Created by 白 桦 on 6/1/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import "ESPCommandDeviceDiscoverLocal.h"
#import "ESPBaseApiUtil.h"
#import "ESPDevice.h"

@implementation ESPCommandDeviceDiscoverLocal

/**
 * discover the ESPDevice in the same AP
 * @return the array of device
 */
- (NSArray *) doCommandDiscoverLocal
{
    NSArray *iotAddressArray = [ESPBaseApiUtil discoverDevices];
    NSMutableArray *deviceArray = [[NSMutableArray alloc]initWithCapacity:[iotAddressArray count]];
    for (ESPIOTAddress *iotAddress in iotAddressArray) {
        ESPDevice *device = [[ESPDevice alloc]initWithIOTAddress:iotAddress];
        if (device==nil) {
            NSLog(@"ERROR %@ %@ iotAddress:%@ is invalid",[self class],NSStringFromSelector(_cmd),iotAddress);
            continue;
        }
        [deviceArray addObject:device];
    }
#ifdef DEBUG
    NSLog(@"%@ %@(): %@",[self class],NSStringFromSelector(_cmd),deviceArray);
#endif
    return deviceArray;
}

@end
