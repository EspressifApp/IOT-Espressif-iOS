//
//  ESPMeshUtil.h
//  suite
//
//  Created by 白 桦 on 6/29/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ESPMeshUtil : NSObject

/**
 * Get the ip address for mesh usage(For mesh require the ip address hex uppercase without ".".
 *
 * @param hostname the ip address, e.g. 192.168.1.2
 * @return ip address by hex without ".", e.g. C0A80102
 */
+ (NSString *) getIPv4AddrForMesh:(NSString *)hostname;

/**
 * Get the port for mesh usage(For mesh require port hex uppercase).
 *
 * @param port the port
 * @return the port for mesh usage
 */
+ (NSString *) getPortForMesh:(int)port;

/**
 * Get the mac address for mesh usage(For mesh require the BSSID uppercase and without colon). It is an inverse
 * method for getRawMacAddress
 *
 * @param bssid the bssid get from wifi scan
 * @return the mac address for mesh usage
 */
+ (NSString *) getMacAddrForMesh:(NSString *)bssid;

@end
