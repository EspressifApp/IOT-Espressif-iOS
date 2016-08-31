//
//  ESPJsonUtil.m
//  suite
//
//  Created by 白 桦 on 7/1/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import "ESPJsonUtil.h"

@implementation ESPJsonUtil

/**
 * slash(/) in json require transferring, but device can't understand '\/' means '/'
 *
 * @param jsonStr json String to be retransferred
 */
+ (NSString *) retransferStr:(NSString *) jsonStr
{
    if (![jsonStr containsString:@"\\/"]) {
        return jsonStr;
    } else {
        return [jsonStr stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"];
    }
}

/**
 * slash(/) in json require transferring, but device can't understand '\/' means '/'
 *
 * @param jsonData json Data to be retransferred
 */
+ (NSData *) retransferData:(NSData *) jsonData
{
    NSData *target = [@"\\/" dataUsingEncoding:NSUTF8StringEncoding];
    if ([jsonData rangeOfData:target options:kNilOptions range:NSMakeRange(0, [jsonData length])].length!=0) {
        NSString *jsonStr = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
        jsonStr = [jsonStr stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"];
        jsonData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    }
    return jsonData;
}

@end
