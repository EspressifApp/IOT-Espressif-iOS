//
//  ESPBaseApiUtil.h
//  MeshProxy
//
//  Created by 白 桦 on 4/25/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESPIOTAddress.h"

@interface ESPBaseApiUtil : NSObject

/**
 * execute download by GET HTTP
 *
 * @param url the url NSString
 * @param headers the dictionary of header
 * @param timeoutSeconds seconds of timeout
 * @return the data of NSData
 */
+ (NSData *) downloadUrl:(NSString *)url
                 headers:(NSDictionary *)headers
          timeoutSeconds:(NSTimeInterval)timeoutSeconds;

/**
 * execute GET to get dictionary of json by HTTP
 *
 * @param url the url NSString
 * @param headers the dictionary of header
 * @return the result of json dictionary
 */
+ (NSDictionary *) Get:(NSString *)url Headers:(NSDictionary *)headers;

/**
 * execute POST to get dictionary of json by HTTP
 *
 * @param url the url NSString
 * @param json the dictionary of json
 * @param headers the dictionary of header
 * @return the result of json dictionary
 */
+ (NSDictionary *) Post:(NSString *)url Json:(NSDictionary *)json Headers:(NSDictionary *)headers;

/**
 * execute GET to get dictionary of json by Mesh Net
 *
 * @param url the url NSString
 * @param bssid the bssid of the device
 * @param headers the dictionary of header
 * @return the result of json dictionary
 */
+ (NSDictionary *) GetForJson:(NSString *)url Bssid:(NSString *)bssid Headers:(NSDictionary *)headers;

/**
 * execute POST to get dictionary of json by Mesh Net
 *
 *
 */
+ (NSDictionary *) PostForJson:(NSString *)url Bssid:(NSString *)bssid Json:(NSDictionary *)json Headers:(NSDictionary *)headers;

/**
 * (it will get UTC time from Server first time, next time, it will use local time to calculate the UTC time from
 * Server, if User change the Time or Date in Android System, it will get UTC time from Server again)
 *
 * @return the UTC time from server, if fail it will return Long.MIN_VALUE
 */
+ (long long) getUTCTimeLongLong;

/**
 * discover the devices on the same AP or in the mesh net which root mesh device is on the same AP
 *
 * @return the array of IOTAddress
 */
+ (NSArray *) discoverDevices;

/**
 * discover the specific device on the same AP or in the mesh which root mesh device is on the same AP by its bssid
 *
 * @param bssid the specific device's bssid
 * @return ESPIOTAddress
 */
+ (ESPIOTAddress *) discoverDevice:(NSString *)bssid;

@end
