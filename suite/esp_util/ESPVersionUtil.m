//
//  ESPVersionUtil.m
//  suite
//
//  Created by 白 桦 on 8/3/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import "ESPVersionUtil.h"

#define VERSION_PATTERN_VALID   @"[v|b][0-9]+\\.[0-9]+\\.[0-9]t[0-9]+\\([o|l|a|n]\\)"

// example: b1.1.5t45772(o)
@implementation ESPVersionUtil

/**
 * check whether the rom version is valid
 *
 * @param version rom version
 *
 * @return whether the rom version is valid
 */
+ (BOOL) isVersionValid:(NSString *)version
{
    NSString *regex = VERSION_PATTERN_VALID;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    return [predicate evaluateWithObject:version];
}

/**
 * resolve device type by rom verion
 *
 * @param version rom version
 *
 * @return device type
 */
+ (ESPDeviceType *) resolveDeviceType:(NSString *)version
{
    if (![self isVersionValid:version]) {
        return nil;
    }
    // split by t
    NSArray *versions = [version componentsSeparatedByString:@"t"];
    version = versions[1];
    // split by (
    versions = [version componentsSeparatedByString:@"("];
    int ptype = [versions[0]intValue];
    return [ESPDeviceType resolveDeviceTypeBySerial:ptype];
}

/**
 * resolve rom version value ty rom version
 *
 * @param version rom version
 *
 * @return rom version value
 */
+ (int) resolveValue:(NSString *)version
{
    if (![self isVersionValid:version]) {
        return ESP_ROM_VERSION_VALUE_INVALID;
    }
    // split by t
    NSArray *versions = [version componentsSeparatedByString:@"t"];
    version = versions[0];
    // split by b
    if([version containsString:@"b"]) {
        versions = [version componentsSeparatedByString:@"b"];
    } else if ([version containsString:@"v"]) {
        versions = [version componentsSeparatedByString:@"v"];
    } else {
        abort();
    }
    // split by .
    versions = [versions[1] componentsSeparatedByString:@"."];
    int value = [versions[0]intValue] * 1000 * 1000 + [versions[1]intValue] * 1000 + [versions[2]intValue];
    return value;
}

@end
