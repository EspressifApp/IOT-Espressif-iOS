//
//  ESPMeshCommunicationUtils.h
//  MeshProxy
//
//  Created by 白 桦 on 4/15/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import <Foundation/Foundation.h>

#define BROADCAST_MAC               @"00:00:00:00:00:00"
#define MULTICAST_MAC               @"01:00:5e:00:00:00"
#define HEADER_MESH_HOST            @"Mesh-Host"
#define HEADER_MESH_BSSID           @"Mesh-Bssid"
#define HEADER_MESH_MULTICAST_GROUP @"Mesh-Group"
#define HEADER_PROXY_TIMEOUT        @"Proxy-Timeout"
#define HEADER_PROTO_TYPE           @"M-Proto-Type"
#define HEADER_NON_RESPONSE         @"Non-Response"
#define HEADER_READ_ONLY            @"Read-Only"
#define HEADER_TASK_SERIAL          @"Task-Serial"
#define HEADER_TASK_TIMEOUT         @"Task-Timeout"

#define SERIAL_NORMAL_TASK          0

@interface ESPMeshCommunicationUtils : NSObject

/**
 * Get a new long socket task serial
 *
 * @return a new long socket task serial
 */
+ (int) GenerateLongSocketSerial;

/**
 * Post Http get request to target url
 *
 * @param url the url of the http request
 * @param bssid the mesh device's bssid
 * @param headers the headers of the http request
 * @return response or null when failed
 */
+ (NSDictionary *)HttpGet:(NSString *)url Bssid:(NSString *)bssid Headers:(NSDictionary *)headers;

/**
 * Post Http post request to target url
 *
 * @param url the url of the http request
 * @param bssid the mesh device's bssid
 * @param json the json body to be sent
 * @param headers the headers of the http request
 * @return response or null when failed
 */
+ (NSDictionary *)HttpPost:(NSString *)url Bssid:(NSString *)bssid Json:(NSDictionary *)json Headers:(NSDictionary *)headers;

/**
 * Post Http post request to target url and don't expect response from device
 *
 * @param url the url of the http request
 * @param bssid the mesh device's bssid
 * @param json the json body to be sent
 * @param headers the headers of the http request
 * @return response or null when failed
 */
+ (NSDictionary *)HttpNonResponsePost:(NSString *)url Bssid:(NSString *)bssid Json:(NSDictionary *)json Headers:(NSDictionary *)headers;

/**
 * Just post Json Http to target url without Http headers
 *
 * @param url the url of the http request
 * @param bssid the mesh device's bssid
 * @param json the json body to be sent
 * @param headers the headers of the http request
 * @return response or null when failed
 */
+ (NSDictionary *)JsonPost:(NSString *)url Bssid:(NSString *)bssid Json:(NSDictionary *)json Headers:(NSDictionary *)headers;

/**
 * Just post Json Http to target url without Http headers
 *
 * @param url the url of the http request
 * @param bssid the mesh device's bssid
 * @param serial long socket serial
 * @param json the json body to be sent
 * @param headers the headers of the http request
 * @return response or null when failed
 */
+ (NSDictionary *)JsonPost:(NSString *)url Bssid:(NSString *)bssid Serial:(int)serial Json:(NSDictionary *)json Headers:(NSDictionary *)headers;


/**
 * Post read response request to target url without sending request
 *
 * @param url the url of the http request
 * @param bssid the mesh device's bssid
 * @param headers the headers of the http request
 * @return response or null when failed
 */
+ (NSDictionary *)JsonReadOnly:(NSString *)url Bssid:(NSString *)bssid Headers:(NSDictionary *)headers;

/**
 * Post read response request to target url without sending request
 *
 * @param url the url of the http request
 * @param bssid the mesh device's bssid
 * @param serial long socket serial
 * @param headers the headers of the http request
 * @return response or null when failed
 */
+ (NSDictionary *)JsonReadOnly:(NSString *)url Bssid:(NSString *)bssid Serial:(int)serial Headers:(NSDictionary *)headers;

/**
 * Post read response request to target url without sending request
 *
 * @param url the url of the http request
 * @param bssid the mesh device's bssid
 * @param serial long socket serial
 * @param taskTimeout task timeout
 * @param headers the headers of the http request
 * @return response or null when failed
 */
+ (NSDictionary *)JsonReadOnly:(NSString *)url Bssid:(NSString *)bssid Serial:(int)serial TaskTimeout:(int)taskTimeout Headers:(NSDictionary *)headers;

/**
 * Just post Json to target url without Http headers and don't expect response from device
 *
 * @param url the url of the http request
 * @param bssid the mesh device's bssid
 * @param json the json body to be sent
 * @return response or null when failed
 */
+ (NSDictionary *)JsonNonResponsePost:(NSString *)url Bssid:(NSString *)bssid Json:(NSDictionary *)json;

/**
 * Just post Json to target url without Http headers and don't expect response from device
 *
 * @param url the url of the http request
 * @param bssid the mesh device's bssid
 * @param serial long socket serial
 * @param json the json body to be sent
 * @return response or null when failed
 */
+ (NSDictionary *)JsonNonResponsePost:(NSString *)url Bssid:(NSString *)bssid Serial:(int)serial Json:(NSDictionary *)json;

@end
