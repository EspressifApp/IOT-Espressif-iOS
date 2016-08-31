//
//  ESPActionDeviceDiscoverInternetLocal.m
//  suite
//
//  Created by 白 桦 on 6/2/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import "ESPActionDeviceDiscoverInternetLocal.h"
#import "ESPCommandDeviceDiscoverLocal.h"
#import "ESPCommandDeviceDiscoverInternet.h"
#import "ESPUser.h"
#import "ESPDevice.h"
#import "ESPConstantsNotification.h"

@implementation ESPActionDeviceDiscoverInternetLocal

- (void) doActionDeviceDiscoverLocalDeviceArray:(NSMutableArray *) deviceArray
{
    ESPCommandDeviceDiscoverLocal *commandLocal = [[ESPCommandDeviceDiscoverLocal alloc]init];
    NSArray *_deviceArray = [commandLocal doCommandDiscoverLocal];
    for (ESPDevice *device in _deviceArray) {
        if (![deviceArray containsObject:device]) {
            [deviceArray addObject:device];
        }
    }
}

- (void) doActionDeviceDiscoverInternetUserKey:(NSString *)userKey DeviceArray:(NSMutableArray *)deviceArray
{
    ESPCommandDeviceDiscoverInternet *commandInternet = [[ESPCommandDeviceDiscoverInternet alloc]init];
    NSArray *_deviceArray = [commandInternet doCommandDeviceDiscoverInternet:userKey];
    for (ESPDevice *device in _deviceArray) {
        if (![deviceArray containsObject:device]) {
            [deviceArray addObject:device];
        } else {
            NSLog(@"%@ %@ it shouldn't run here",[self class],NSStringFromSelector(_cmd));
        }
    }
}

- (void) doActionDeviceDiscoverInternetLocalUserKey:(NSString *)userKey DeviceArrayLocal: (NSMutableArray *) deviceArrayLocal DeviceArrayInternet:(NSMutableArray *)deviceArrayInternet
{
    __block BOOL isActionInternetDone = NO;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        [self doActionDeviceDiscoverInternetUserKey:userKey DeviceArray:deviceArrayInternet];
        isActionInternetDone = YES;
    });
    for (int retry = 0; retry < UDP_EXECUTE_MAX_TIMES; ++retry) {
        if (retry >= UDP_EXECUTE_MIN_TIMES && isActionInternetDone) {
            break;
        }
        dispatch_sync(queue, ^{
            [self doActionDeviceDiscoverLocalDeviceArray:deviceArrayLocal];
        });
    }
    while (!isActionInternetDone) {
        [NSThread sleepForTimeInterval:0.5];
    }
}

/**
 * discover devices from internet and local
 *
 * @param isSyn whether execute the it syn or asyn
 * @param userKey the user key
 */
- (void) doActionDeviceDiscoverInternetLocal:(BOOL)isSyn UserKey:(NSString *)userKey
{
    __block NSMutableArray *deviceArrayLocal = [[NSMutableArray alloc]init];
    __block NSMutableArray *deviceArrayInternet = [[NSMutableArray alloc]init];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    if (isSyn) {
        dispatch_sync(queue, ^{
            [self doActionDeviceDiscoverInternetLocalUserKey:userKey DeviceArrayLocal:deviceArrayLocal DeviceArrayInternet:deviceArrayInternet];
            ESPUser *user = [ESPUser sharedUser];
            [user updateDeviceLocalArray:deviceArrayLocal];
            [user updateDeviceInternetArray:deviceArrayInternet];
            [user notifyDevicesArrive];
        });
    } else {
        dispatch_async(queue, ^{
            [self doActionDeviceDiscoverInternetLocalUserKey:userKey DeviceArrayLocal:deviceArrayLocal DeviceArrayInternet:deviceArrayInternet];
            ESPUser *user = [ESPUser sharedUser];
            [user updateDeviceLocalArray:deviceArrayLocal];
            [user updateDeviceInternetArray:deviceArrayInternet];
            [user notifyDevicesArrive];
        });
    }
}

/**
 * discover devices from local
 *
 * @param isSyn whether execute the it syn or asyn
 */
- (void) doActionDeviceDiscoverLocal:(BOOL)isSyn
{
    __block NSMutableArray *deviceArrayLocal = [[NSMutableArray alloc]init];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    if (isSyn) {
        dispatch_sync(queue, ^{
            [self doActionDeviceDiscoverLocalDeviceArray:deviceArrayLocal];
            ESPUser *user = [ESPUser sharedUser];
            [user updateDeviceLocalArray:deviceArrayLocal];
            [user notifyDevicesArrive];
        });
    } else {
        dispatch_async(queue, ^{
            [self doActionDeviceDiscoverLocalDeviceArray:deviceArrayLocal];
            ESPUser *user = [ESPUser sharedUser];
            [user updateDeviceLocalArray:deviceArrayLocal];
            [user notifyDevicesArrive];
        });
    }
}

/**
 * discover devices from internet
 *
 * @param isSyn whether execute the it syn or asyn
 * @param userKey the user key
 */
- (void) doActionDeviceDiscoverInternet:(BOOL)isSyn UserKey:(NSString *)userKey
{
    __block NSMutableArray *deviceArrayInternet = [[NSMutableArray alloc]init];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    if (isSyn) {
        dispatch_sync(queue, ^{
            [self doActionDeviceDiscoverInternetUserKey:userKey DeviceArray:deviceArrayInternet];
            ESPUser *user = [ESPUser sharedUser];
            [user updateDeviceInternetArray:deviceArrayInternet];
            [user notifyDevicesArrive];
        });
    } else {
        dispatch_async(queue, ^{
            [self doActionDeviceDiscoverInternetUserKey:userKey DeviceArray:deviceArrayInternet];
            ESPUser *user = [ESPUser sharedUser];
            [user updateDeviceInternetArray:deviceArrayInternet];
            [user notifyDevicesArrive];
        });
    }

}

@end
