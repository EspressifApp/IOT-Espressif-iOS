//
//  ESPMeshUtil.m
//  suite
//
//  Created by 白 桦 on 6/29/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import "ESPMeshUtil.h"

@implementation ESPMeshUtil

/**
 * Get the ip address for mesh usage(For mesh require the ip address hex uppercase without ".".
 *
 * @param hostname the ip address, e.g. 192.168.1.2
 * @return ip address by hex without ".", e.g. C0A80102
 */
+ (NSString *) getIPv4AddrForMesh:(NSString *)hostname
{
    NSMutableString *mstr = [[NSMutableString alloc]init];
    NSArray *segments = [hostname componentsSeparatedByString:@"."];
    int segment;
    NSString *segmentHexStr;
    for (int i = 0; i < [segments count]; ++i) {
        // get the integer
        segment = [[segments objectAtIndex:i]intValue];
        // transform the integer to hex
        segmentHexStr = [NSString stringWithFormat:@"%x",segment];
        // transform the hex string to uppercase
        segmentHexStr = [segmentHexStr uppercaseString];
        // append segmentHexStr to the mstr
        if ([segmentHexStr length]==1) {
            [mstr appendFormat:@"0%@",segmentHexStr];
        } else if ([segmentHexStr length]==2) {
            [mstr appendString:segmentHexStr];
        } else {
            NSLog(@"%@ %@ abort()",[self class],NSStringFromSelector(_cmd));
            abort();
        }
    }
    return mstr;
}

/**
 * Get the port for mesh usage(For mesh require port hex uppercase).
 *
 * @param port the port
 * @return the port for mesh usage
 */
+ (NSString *) getPortForMesh:(int)port
{
    NSString *portHexUppercase = [[NSString stringWithFormat:@"%x",port]uppercaseString];
    NSUInteger numberOfZero = 4 - [portHexUppercase length];
    NSMutableString *mstr = [[NSMutableString alloc]init];
    for (int i = 0; i < numberOfZero; ++i) {
        [mstr appendString:@"0"];
    }
    [mstr appendString:portHexUppercase];
    return mstr;
}

/**
 * Get the mac address for mesh usage(For mesh require the BSSID uppercase and without colon). It is an inverse
 * method for getRawMacAddress
 *
 * @param bssid the bssid get from wifi scan
 * @return the mac address for mesh usage
 */
+ (NSString *) getMacAddrForMesh:(NSString *)bssid
{
    NSMutableString *mstr = [[NSMutableString alloc]init];
    NSRange range;
    NSString *subStr;
    for (int i = 0; i < [bssid length]; ++i) {
        range = NSMakeRange(i, 1);
        subStr = [bssid substringWithRange:range];
        if (![subStr isEqualToString:@":"]) {
            [mstr appendString:subStr];
        }
    }
    return [mstr uppercaseString];
}

@end
