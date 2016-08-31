//
//  ESPUDPBroadcastUtil.m
//  MeshProxy
//
//  Created by 白 桦 on 4/28/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import "ESPUDPBroadcastUtil.h"
#import "ESPUDPSocketClient2.h"
#import "ESPUDPDataParser.h"

#define DEBUG_ON                YES

#define REQUEST_DATA_STR        @"Are You Espressif IOT Smart Device?"
#define IOT_DEVICE_PORT         1025
// udp socket read timeout in milliseconds
#define SO_TIMEOUT              3000
#define RECEIVE_LEN             64
#define BROADCAST_INETADDRESS   @"255.255.255.255"

@implementation ESPUDPBroadcastUtil


+ (NSArray *)discoverDevices:(NSString *)bssid
{
    NSMutableSet *responseSet = [[NSMutableSet alloc]init];
    ESPUDPSocketClient2 *udpClient = nil;
    NSString *realRequestDataStr = bssid == nil ? REQUEST_DATA_STR : [NSString stringWithFormat:@"%@ %@",REQUEST_DATA_STR,bssid];
    
    udpClient = [[ESPUDPSocketClient2 alloc]init];
    if (udpClient!=nil) {
        // set socket timout
        [udpClient setSoTimeout:SO_TIMEOUT];
        // send request
        if ([udpClient writeStr:realRequestDataStr Offset:0 NStr:[realRequestDataStr length] ToRemoteAddr:BROADCAST_INETADDRESS Port:IOT_DEVICE_PORT]) {
            
            do {
                // receive response and resolve them
                NSTimeInterval start = [[NSDate date] timeIntervalSince1970];
                NSString *responseStr = [udpClient readStr];
                if (DEBUG_ON) {
                    NSLog(@"ESPUDPBroadcastUtil discoverDevices() receive: %@",responseStr);
                }
                NSTimeInterval consume = [[NSDate date] timeIntervalSince1970] - start;
                if (DEBUG_ON) {
                    NSLog(@"ESPUDPBroadcastUtil discoverDevices() udp receive cost: %f s",consume);
                }
                // no more devices available
                if (responseStr==nil || [responseStr length] == 0) {
                    break;
                } else {
                    if ([ESPUDPDataParser resolveIsValid:responseStr]) {
                        NSString *respInetAddress = [ESPUDPDataParser resolveInetAddress:responseStr];
                        if ([respInetAddress isEqualToString:@"0.0.0.0"]) {
                            if (DEBUG_ON) {
                                NSLog(@"ESPUDPBroadcastUtil discoverDevices() inetAddress is 0.0.0.0 not valid");
                            }
                            continue;
                        }
                        NSString *respDeviceTypeStr = [ESPUDPDataParser resolveType:responseStr];
                        ESPDeviceType *respDeviceType = [ESPDeviceType resolveDeviceTypeByTypeName:respDeviceTypeStr];
                        NSString *respBssid = [ESPUDPDataParser resolveBssid:responseStr];
                        BOOL respIsMesh = [ESPUDPDataParser resolveIsMesh:responseStr];
                        ESPIOTAddress *respIOTAddress = [[ESPIOTAddress alloc]initWithBssid:respBssid InetAddress:respInetAddress IsMeshDevice:respIsMesh];
                        if ([ESPDeviceType isTypeSupportedAlready:respDeviceType]) {
                            respIOTAddress.espDeviceType = respDeviceType;
                            [responseSet addObject:respIOTAddress];
                        } else {
                            NSLog(@"%@ %@ type:%@ isn't supported yet",[ESPUDPBroadcastUtil class],NSStringFromSelector(_cmd),respDeviceType);
                        }
                    }
                }
            }while (bssid == nil);
        }
    }
    if (udpClient!=nil) {
        [udpClient close];
    }
    
    return [responseSet allObjects];
}

/**
 * discover the specified IOT device in the same AP by UDP broadcast
 *
 * @param bssid the IOT device's bssid
 * @return the specified device's ESPIOTAddress (if found) or null(if not found)
 */
+ (ESPIOTAddress *)discoverIOTDevice:(NSString *)bssid
{
    NSArray *result = [self discoverDevices:bssid];
    if ([result count]==1) {
        return [result objectAtIndex:0];
    } else {
        return  nil;
    }
}

/**
 * @see IOTAddress discover IOT devices in the same AP by UDP broadcast
 *
 * @return the Array of ESPIOTAddress
 */
+ (NSArray *)discoverIOTDevices
{
    return [self discoverDevices:nil];
}

@end
