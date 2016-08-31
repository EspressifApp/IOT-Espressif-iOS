//
//  ESPGroup.m
//  suite
//
//  Created by 白 桦 on 6/2/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import "ESPGroup.h"

@implementation ESPGroup

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.espGroupState = [[ESPGroupState alloc]init];
        self.espDeviceArray = [[NSMutableArray alloc]init];
    }
    return self;
}

/**
 * Add device in the group
 *
 * @param device
 */
-(void) addDevice:(ESPDevice *)device
{
    if (![self.espDeviceArray containsObject:device]) {
        [self.espDeviceArray addObject:device];
    }
}

/**
 * Remove device from group
 *
 * @param device
 */
-(void) removeDevice:(ESPDevice *)device
{
    [self.espDeviceArray removeObject:device];
}

/**
 * Generate the array of devices' bssid
 *
 * @return bssid array
 */
-(NSArray *) generateDeviceBssidArray
{
    NSUInteger capacity = [self.espDeviceArray count];
    NSMutableArray *bssidArray = [[NSMutableArray alloc]initWithCapacity:capacity];
    for (ESPDevice *device in self.espDeviceArray) {
        [bssidArray addObject:device.espBssid];
    }
    return bssidArray;
}

-(NSString *) description
{
    NSString *hexAddr = [super description];
    return [NSString stringWithFormat:@"[%@ groupState:%@ deviceArray:%@]",hexAddr,self.espGroupState,self.espDeviceArray];
}

@end
