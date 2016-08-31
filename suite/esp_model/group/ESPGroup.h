//
//  ESPGroup.h
//  suite
//
//  Created by 白 桦 on 6/2/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESPGroupState.h"
#import "ESPDevice.h"

@interface ESPGroup : NSObject

@property (nonatomic, assign) long long espGroupId;
@property (nonatomic, strong) NSString *espGroupName;
@property (nonatomic, strong) NSMutableArray *espDeviceArray;
@property (nonatomic, strong) ESPGroupState *espGroupState;

- (instancetype)init;

/**
 * Add device in the group
 *
 * @param device
 */
-(void) addDevice:(ESPDevice *)device;

/**
 * Remove device from group
 *
 * @param device
 */
-(void) removeDevice:(ESPDevice *)device;

/**
 * Generate the array of devices' bssid
 *
 * @return bssid array
 */
-(NSArray *) generateDeviceBssidArray;

@end
