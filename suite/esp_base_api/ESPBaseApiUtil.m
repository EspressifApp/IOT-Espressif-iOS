//
//  ESPBaseApiUtil.m
//  MeshProxy
//
//  Created by 白 桦 on 4/25/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import "ESPBaseApiUtil.h"
#import "ESPMeshCommunicationUtils.h"
#import "ESPMeshDiscoverUtil.h"
#import "ESPHttpClient.h"

#define HTTP_SOTIMEOUT      4

@implementation ESPBaseApiUtil

/**
 * execute download by HTTP
 *
 * @param url the url NSString
 * @param headers the dictionary of header
 * @param timeoutSeconds seconds of timeout
 * @return the data of NSData
 */
+ (NSData *) downloadUrl:(NSString *)url
                 headers:(NSDictionary *)headers
          timeoutSeconds:(NSTimeInterval)timeoutSeconds
{
    return [ESPHttpClient downloadSynPath:url headers:headers parameters:nil timeoutSeconds:timeoutSeconds];
}

/**
 * execute GET to get dictionary of json by HTTP
 *
 * @param url the url NSString
 * @param headers the dictionary of header
 * @return the result of json dictionary
 */
+ (NSDictionary *) Get:(NSString *)url Headers:(NSDictionary *)headers
{
    return [ESPHttpClient getSynPath:url headers:headers parameters:nil timeoutSeconds:HTTP_SOTIMEOUT];
}

/**
 * execute POST to get dictionary of json by HTTP
 *
 * @param url the url NSString
 * @param json the dictionary of json
 * @param headers the dictionary of header
 * @return the result of json dictionary
 */
+ (NSDictionary *) Post:(NSString *)url Json:(NSDictionary *)json Headers:(NSDictionary *)headers
{
    return [ESPHttpClient postSynPath:url headers:headers parameters:json timeoutSeconds:HTTP_SOTIMEOUT];
}

/**
 * execute GET to get dictionary of json by Mesh Net
 *
 * @param url the url NSString
 * @param bssid the bssid of the device
 * @param headers the dictionary of header
 * @return the result of json dictionary
 */
+ (NSDictionary *) GetForJson:(NSString *)url Bssid:(NSString *)bssid Headers:(NSDictionary *)headers
{
    return [ESPMeshCommunicationUtils HttpGet:url Bssid:bssid Headers:headers];
}

/**
 * execute POST to get dictionary of json by Mesh Net
 *
 *
 */
+ (NSDictionary *) PostForJson:(NSString *)url Bssid:(NSString *)bssid Json:(NSDictionary *)json Headers:(NSDictionary *)headers
{
    return [ESPMeshCommunicationUtils HttpPost:url Bssid:bssid Json:json Headers:headers];
}

/**
 * (it will get UTC time from Server first time, next time, it will use local time to calculate the UTC time from
 * Server, if User change the Time or Date in Android System, it will get UTC time from Server again)
 *
 * @return the UTC time from server, if fail it will return Long.MIN_VALUE
 */
+ (long long) getUTCTimeLongLong
{
    // TODO use local timeout only at present
    NSDate *now = [NSDate date];
    return now.timeIntervalSince1970 * 1000;
}

/**
 * discover the devices on the same AP or in the mesh net which root mesh device is on the same AP
 *
 * @return the array of IOTAddress
 */
+ (NSArray *) discoverDevices
{
    return [ESPMeshDiscoverUtil discoverIOTDevices];
}

/**
 * discover the specific device on the same AP or in the mesh which root mesh device is on the same AP by its bssid
 *
 * @param bssid the specific device's bssid
 * @return ESPIOTAddress
 */
+ (ESPIOTAddress *) discoverDevice:(NSString *)bssid
{
    return [ESPMeshDiscoverUtil discoverIOTDevice:bssid];
}

@end
