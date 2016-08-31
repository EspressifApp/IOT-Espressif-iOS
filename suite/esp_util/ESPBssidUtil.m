
//
//  ESPBssidUtil.m
//  suite
//
//  Created by 白 桦 on 6/1/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import "ESPBssidUtil.h"

@implementation ESPBssidUtil

/**
 * generate Device name by bssid
 *
 * @param bssid device's bssid
 * @return "ESP_XXXXXX", "XXXXXX" is the last 6 of bssid
 */
+ (NSString *)genDeviceNameByBssid:(NSString *)bssid
{
    return [self genDeviceNameByPrefix:@"ESP_" Bssid:bssid];
}

/**
 * generate Device name by bssid
 *
 * @param prefix the prefix of the name
 * @param bssid the device's bssid
 * @return prefix + "XXXXXX", "XXXXXX" is the last 6 of bssid
 */
+ (NSString *)genDeviceNameByPrefix:(NSString *)prefix Bssid: (NSString *)bssid
{
    NSMutableString *tail = [[NSMutableString alloc]init];
    [tail appendString:[[bssid substringWithRange:NSMakeRange(9, 2)]uppercaseString]];
    [tail appendString:[[bssid substringWithRange:NSMakeRange(12, 2)]uppercaseString]];
    [tail appendString:[[bssid substringWithRange:NSMakeRange(15, 2)]uppercaseString]];
    return [NSString stringWithFormat:@"%@%@",prefix,tail];
}

/**
 * check whether the bssid is belong to ESP device
 *
 * @param bssid the bssid to be checked
 * @return whether the bssid is belong to ESP device
 */
+ (BOOL) isESPDevice:(NSString *)bssid
{
    // ESP wifi's sta bssid is started with "18:fe:34"
    return bssid!=nil && [bssid hasPrefix:@"18:fe:34"];
}

/**
 * restore the bssid from esptouch result
 *
 * @param bssid like 18fe34abcdef or 18FE34ABCDEF
 * @return like 18:fe:34:ab:cd:ef
 */
+ (NSString *)restoreBssid:(NSString *)bssid
{
    NSMutableString *mstr = [[NSMutableString alloc]init];
    NSRange range;
    for (int index=0; index<bssid.length; index+=2) {
        range = NSMakeRange(index, 2);
        [mstr appendString:[bssid substringWithRange:range]];
        if (index!=bssid.length-2) {
            [mstr appendString:@":"];
        }
    }
    return [mstr lowercaseString];
}

@end
