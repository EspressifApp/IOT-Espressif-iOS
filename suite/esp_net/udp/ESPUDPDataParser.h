//
//  ESPUDPDataParser.h
//  MeshProxy
//
//  Created by 白 桦 on 4/28/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ESPUDPDataParser : NSObject

/**
 * resolve whether the data is valid
 * @param data the content String get from UDP Broadcast
 * @return whether the data is valid
 */
+ (BOOL)resolveIsValid:(NSString *)dataStr;

/**
 * resolve whether the device is mesh
 * @param data the content String get from UDP Broadcast
 * @return whether the device is mesh
 */
+ (BOOL)resolveIsMesh:(NSString *)dataStr;

/**
 * resolve the device's type String from data
 * @param data the content String get from UDP Broadcast
 * @return the device's type String
 */
+ (NSString *)resolveType:(NSString *)dataStr;

/**
 * resolve the device's bssid from data
 * @param data the content String get from UDP Broadcast
 * @return the device's bssid String
 */
+ (NSString *)resolveBssid:(NSString *)dataStr;

/**
 * resolve the device's ip address from data
 * @param data the content String get from UDP Broadcast
 * @return the device's ip address String
 */
+ (NSString *)resolveInetAddress:(NSString *)dataStr;

@end
