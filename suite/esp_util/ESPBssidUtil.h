//
//  ESPBssidUtil.h
//  suite
//
//  Created by 白 桦 on 6/1/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ESPBssidUtil : NSObject

/**
 * generate Device name by bssid
 *
 * @param bssid device's bssid
 * @return "ESP_XXXXXX", "XXXXXX" is the last 6 of bssid
 */
+ (NSString *)genDeviceNameByBssid:(NSString *)bssid;

/**
 * generate Device name by bssid
 *
 * @param prefix the prefix of the name
 * @param bssid the device's bssid
 * @return prefix + "XXXXXX", "XXXXXX" is the last 6 of bssid
 */
+ (NSString *)genDeviceNameByPrefix:(NSString *)prefix Bssid: (NSString *)bssid;

/**
 * check whether the bssid is belong to ESP device
 *
 * @param bssid the bssid to be checked
 * @return whether the bssid is belong to ESP device
 */
+ (BOOL) isESPDevice:(NSString *)bssid;

/**
 * restore the bssid from esptouch result
 *
 * @param bssid like 18fe34abcdef or 18FE34ABCDEF
 * @return like 18:fe:34:ab:cd:ef
 */
+ (NSString *)restoreBssid:(NSString *)bssid;

@end
