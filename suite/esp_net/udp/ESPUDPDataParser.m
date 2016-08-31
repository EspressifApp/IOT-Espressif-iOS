//
//  ESPUDPDataParser.m
//  MeshProxy
//
//  Created by 白 桦 on 4/28/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import "ESPUDPDataParser.h"

#define DEVICE_PATTERN_TYPE     @"^I'm ((\\w)+( )*)+\\."
#define DEVICE_PATTERN_BSSID    @"([0-9a-fA-F]{2}:){5}([0-9a-fA-F]{2} )"
#define DEVICE_PATTERN_IP       @"(\\d+\\.){3}(\\d+)$"

// DEVICE_PATTERN = DEVICE_PATTERN_TYPE + DEVICE_PATTERN_BSSID + DEVICE_PATTERN_IP
#define DEVICE_PATTERN          @"^I'm ((\\w)+( )*)+\\.([0-9a-fA-F]{2}:){5}([0-9a-fA-F]{2} )(\\d+\\.){3}(\\d+)$"

@implementation ESPUDPDataParser

/**
 * check whether the data is valid
 * @param data the content String get from UDP Broadcast
 * @return whether the data is valid
 */
+ (BOOL)resolveIsValid:(NSString *)dataStr
{
    NSString *regex = DEVICE_PATTERN;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    return [predicate evaluateWithObject:dataStr];
}

/**
 * check whether the device is mesh
 * @param data the content String get from UDP Broadcast
 * @return whether the device is mesh
 */
+ (BOOL)resolveIsMesh:(NSString *)dataStr
{
    NSString *regex = @"with mesh";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF CONTAINS %@",regex];
    return [predicate evaluateWithObject:dataStr];
}

/**
 * resolve the device's type String from data
 * @param data the content String get from UDP Broadcast
 * @return the device's type String
 */
+ (NSString *)resolveType:(NSString *)dataStr
{
    NSArray *dataSplitArray1 = [dataStr componentsSeparatedByString:@"."];
    NSString *dataStr1 = [dataSplitArray1 objectAtIndex:0];
    NSArray *dataSplitArray2 = [dataStr1 componentsSeparatedByString:@" "];
    NSString *dataStr2 = [dataSplitArray2 objectAtIndex:1];
    return dataStr2;
}

/**
 * resolve the device's bssid from data
 * @param data the content String get from UDP Broadcast
 * @return the device's bssid String
 */
+ (NSString *)resolveBssid:(NSString *)dataStr
{
    NSArray *dataSplitArray1 = [dataStr componentsSeparatedByString:@"."];
    NSString *dataStr1 = [dataSplitArray1 objectAtIndex:1];
    NSArray *dataSplitArray2 = [dataStr1 componentsSeparatedByString:@" "];
    NSString *dataStr2 = [dataSplitArray2 objectAtIndex:0];
    return dataStr2;
}

/**
 * resolve the device's ip address from data
 * @param data the content String get from UDP Broadcast
 * @return the device's ip address String
 */
+ (NSString *)resolveInetAddress:(NSString *)dataStr
{
    NSArray *dataSplitArray1 = [dataStr componentsSeparatedByString:@" "];
    NSString *dataStr1 = [dataSplitArray1 objectAtIndex:[dataSplitArray1 count]-1];
    return dataStr1;
}

@end
