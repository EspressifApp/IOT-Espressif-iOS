//
//  ESPMeshDiscoverUtil.m
//  MeshProxy
//
//  Created by 白 桦 on 5/3/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import "ESPMeshDiscoverUtil.h"
#import "ESPUDPBroadcastUtil.h"
#import "ESPMeshNetUtil2.h"
#import "ESPUser.h"
#import "ESPDevice.h"

#define UDP_RETRY_TIME  3
#define DEBUG_ON        NO

@implementation ESPMeshDiscoverUtil

+ (NSSet *) discoverIOTMeshDevicesOnRoot2:(ESPIOTAddress *)rootIOTAddress Bssid:(NSString *)deviceBssid
{
    NSMutableSet *iotMeshAddressSet = [[NSMutableSet alloc]init];
    NSString *rootInetAddress = rootIOTAddress.espInetAddress;
    NSString *rootBssid = rootIOTAddress.espBssid;
    if (deviceBssid != nil) {
        ESPIOTAddress *iotAddress = [ESPMeshNetUtil2 GetTopoIOTAddress5:rootInetAddress Bssid:deviceBssid];
        if (iotAddress!=nil) {
            [iotMeshAddressSet addObject:iotAddress];
        }
    }
    else {
        NSArray *iotAddressArray = [ESPMeshNetUtil2 GetTopoIOTAddressArray5:rootInetAddress RootBssid:rootBssid];
        if (iotAddressArray!=nil) {
            [iotMeshAddressSet addObjectsFromArray:iotAddressArray];
        }
    }
    return iotMeshAddressSet;
}

/**
 * discover IOT devices in the same AP
 *
 * @param bssid the device's bssid which is to be found, nil means find all devices
 * @return NSSet of IOT Devices
 */
+ (NSSet *) discoverIOTMeshDevices:(NSString *)bssid
{
    // discover IOT root devices by UDP Broadcast
    __block NSMutableSet *rootDeviceSet = [[NSMutableSet alloc]init];
    dispatch_queue_t queue = dispatch_queue_create("com.espressif.iot.net.ESPMeshDiscoverUtil", DISPATCH_QUEUE_CONCURRENT);
    
    for (int i = 0; i < UDP_RETRY_TIME; ++i) {
        dispatch_async(queue, ^{
            NSArray *rootDeviceArray = nil;
            rootDeviceArray = [ESPUDPBroadcastUtil discoverIOTDevices];
            
            ESPUser *user = [ESPUser sharedUser];
            
            if (bssid==nil) {
                
                for (ESPIOTAddress *iotAddress in rootDeviceArray) {
                    iotAddress.espRootBssid = iotAddress.espBssid;
                }
                
                NSMutableArray *rootDevices = [[NSMutableArray alloc]init];
                for (ESPIOTAddress *iotAddr in rootDeviceArray) {
                    ESPDevice *device = [[ESPDevice alloc]initWithIOTAddress:iotAddr];
                    if (device!=nil) {
                        [rootDevices addObject:device];
                    }
                }
                [user addDeviceTempArray:rootDevices];
                [user notifyDevicesArrive];
            }
            
            [rootDeviceSet addObjectsFromArray:rootDeviceArray];
        });
        if (i < UDP_RETRY_TIME - 1) {
            [NSThread sleepForTimeInterval:1.0];
        }
    }
    
    dispatch_barrier_sync(queue, ^{
        if (DEBUG_ON) {
            NSLog(@"ESPMeshDiscoverUtil discoverIOTMeshDevices(): rootDeviceSet=%@",rootDeviceSet);
        }
    });
    
    // discover IOT Devices by IOT Root Devices
    __block NSMutableSet *allDeviceSet = [[NSMutableSet alloc]init];
    for (ESPIOTAddress *rootIOTAddress in rootDeviceSet) {
        // if the device isn't mesh device ignore it
        if (!rootIOTAddress.espIsMeshDevice) {
            continue;
        }
        dispatch_async(queue, ^{
            if (DEBUG_ON) {
                NSLog(@"ESPMeshDiscoverUtil discoverIOTMeshDevicesOnRoot2(): rootIOTAddress=[%@]",rootIOTAddress);
            }
            NSSet *deviceSet = [self discoverIOTMeshDevicesOnRoot2:rootIOTAddress Bssid:bssid];
            [allDeviceSet addObjectsFromArray:[deviceSet allObjects]];
        });
    }
    
    dispatch_barrier_sync(queue, ^{
        if (DEBUG_ON) {
            NSLog(@"ESPMeshDiscoverUtil discoverIOTMeshDevices(): allDeviceSet=%@",allDeviceSet);
        }
    });
    
    // only zero or one device should in the allDeviceSet
    if (bssid != nil) {
        if ([allDeviceSet count] > 1) {
            if (DEBUG_ON) {
                NSLog(@"ESPMeshDiscoverUtil discoverIOTMeshDevices():: more than one device in allDeviceSet, but we just trust the first one");
            }
        }
        if ([allDeviceSet count] == 0) {
            for (ESPIOTAddress *rootDevice in rootDeviceSet) {
                if ([rootDevice.espBssid isEqualToString:bssid]) {
                    [allDeviceSet addObject:rootDevice];
                    break;
                }
            }
        }
        if (DEBUG_ON) {
            NSLog(@"ESPMeshDiscoverUtil discoverIOTMeshDevices(): allDeviceSet=%@",allDeviceSet);
        }
        return allDeviceSet;
    }
    // add all root device set
    [allDeviceSet addObjectsFromArray:[rootDeviceSet allObjects]];
    if (DEBUG_ON) {
        NSLog(@"ESPMeshDiscoverUtil discoverIOTMeshDevices(): allDeviceSet=%@",allDeviceSet);
    }
    return allDeviceSet;
}

/**
 * discover the IOT devices in the same AP
 *
 * @return the Array of ESPIOTAddress
 */
+ (NSArray *) discoverIOTDevices
{
    NSSet *iotAddressSet = [self discoverIOTMeshDevices:nil];
    return [iotAddressSet allObjects];
}

/**
 * discover the IOT device in the same AP by its bssid
 * @param bssid the device's bssid
 *
 * @return the ESPIOTAddress
 */
+ (ESPIOTAddress *) discoverIOTDevice:(NSString *)bssid
{
    NSSet *iotAddressSet = [self discoverIOTMeshDevices:bssid];
    if ([iotAddressSet count] > 0) {
        return [[iotAddressSet allObjects] objectAtIndex:0];
    } else {
        return nil;
    }
}

@end
