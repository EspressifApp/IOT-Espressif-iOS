//
//  ESPJsonUtil.h
//  suite
//
//  Created by 白 桦 on 7/1/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ESPJsonUtil : NSObject

/**
 * slash(/) in json require transferring, but device can't understand '\/' means '/'
 *
 * @param jsonStr json String to be retransferred
 */
+ (NSString *) retransferStr:(NSString *) jsonStr;

/**
 * slash(/) in json require transferring, but device can't understand '\/' means '/'
 *
 * @param jsonData json Data to be retransferred
 */
+ (NSData *) retransferData:(NSData *) jsonData;

@end
