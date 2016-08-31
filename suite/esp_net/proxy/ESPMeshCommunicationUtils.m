//
//  ESPMeshCommunicationUtils.m
//  MeshProxy
//
//  Created by 白 桦 on 4/15/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import "ESPMeshCommunicationUtils.h"
#import "ESPMeshLog.h"
#import "ESPProxyServer.h"
#import "ESPProxyTask.h"
#import "ESPJsonUtil.h"

#define DEBUG_ON                NO
#define KEY_STATUS              @"status"
#define CONN_TIMEOUT            2000
#define READ_TIMEOUT_STR        @"4000"
// socket connect and read timeout altogether
#define READ_TIMEOUT_INFINITE   30
#define METHOD_POST             @"POST"
#define METHOD_GET              @"GET"
#define RESPONSE                @"response"
#define RESPONSE_ONLY_ROOT_STR  @"2"

static volatile int SERIAL_LONG_TASK = 1;

@implementation ESPMeshCommunicationUtils


/**
 * Get a new long socket task serial
 *
 * @return a new long socket task serial
 */
+ (int) GenerateLongSocketSerial
{
    static NSCondition *SERIAL_LOCK;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        SERIAL_LOCK = [[NSCondition alloc]init];
    });
    int longSocketSerial;
    [SERIAL_LOCK lock];
    longSocketSerial = SERIAL_LONG_TASK++;
    [SERIAL_LOCK unlock];
    return longSocketSerial;
}

+ (NSDictionary *) JSON_EMPTY
{
    static NSDictionary* JSON_EMPTY;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        JSON_EMPTY = [[NSDictionary alloc]init];
    });
    return JSON_EMPTY;
}

+ (BOOL) isHttpCloseResponse:(NSDictionary *)responseJson
{
    if ([[responseJson objectForKey:@")(*&^%$#@!"] isEqualToString:@"!@#$%^&*()"]) {
        return YES;
    } else if(responseJson==nil){
        return YES;
    } else {
        return NO;
    }
}

+ (NSDictionary *) executeHttpRequest:(NSString *)url LocalServerPort:(int) localServerPort Method:(NSString *)method BSSID:(NSString *)bssid JSON:(NSDictionary *)json NonResponse:(BOOL)nonResponse Headers:(NSDictionary *)headers
{
    NSMutableDictionary *headers0 = headers==nil ? [[NSMutableDictionary alloc]init] : [NSMutableDictionary dictionaryWithDictionary:headers];
    NSMutableDictionary *json0 = json==nil ? nil : [NSMutableDictionary dictionaryWithDictionary:json];
    
    NSURL *targetURL = [NSURL URLWithString:url];
    NSString *targetHost = [targetURL host];
    NSString *localHost = [NSString stringWithFormat:@"localhost:%d",localServerPort];
    
    NSMutableString *localUrlMstr = [[NSMutableString alloc]initWithString:url];
    [localUrlMstr replaceOccurrencesOfString:targetHost withString:localHost options:NSLiteralSearch range:NSMakeRange(0, [localUrlMstr length])];
    NSURL *localURL = [NSURL URLWithString:localUrlMstr];
    
    NSString *msg = [NSString stringWithFormat:@"Local url = %@",localURL];
    [ESPMeshLog info:DEBUG_ON Class:[self class] Message:msg];
    
    NSMutableURLRequest *localRequest = [[NSMutableURLRequest alloc]initWithURL:localURL cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:READ_TIMEOUT_INFINITE];
    
    // Set don't use cookid
    [localRequest setHTTPShouldHandleCookies:NO];
    
    // Set method
    [localRequest setHTTPMethod:method];
    
    // Set headers
    [headers0 setObject:READ_TIMEOUT_STR forKey:HEADER_PROXY_TIMEOUT];
    [headers0 setObject:targetHost forKey:HEADER_MESH_HOST];
    [headers0 setObject:bssid forKey:HEADER_MESH_BSSID];
    if (nonResponse) {
        [headers0 setObject:@"1" forKey:HEADER_NON_RESPONSE];
    }
    [localRequest setAllHTTPHeaderFields:headers0];
    
    // Add necessary json
    if (!nonResponse && ([bssid isEqualToString:MULTICAST_MAC] || [bssid isEqualToString:BROADCAST_MAC])) {
        if (json0==nil) {
            json0 = [[NSMutableDictionary alloc]init];
        }
        [json0 setObject:RESPONSE_ONLY_ROOT_STR forKey:RESPONSE];
    }
    
    // Send request
    if (json0!=nil) {
        msg = [NSString stringWithFormat:@"Post json0 = %@",json0];
        [ESPMeshLog info:DEBUG_ON Class:[self class] Message:msg];
        NSData* jsonData = [NSJSONSerialization dataWithJSONObject:json0 options:kNilOptions error:nil];
        jsonData = [ESPJsonUtil retransferData:jsonData];
        [localRequest setHTTPBody:jsonData];
    }
    
    NSError *error = nil;
    NSHTTPURLResponse *response = nil;
    NSData *receivedData = [NSURLConnection sendSynchronousRequest:localRequest returningResponse:&response error:&error];
    if (error != nil || receivedData == nil) {
        if (DEBUG_ON) {
            NSLog(@"ESPMeshCommunicationUtils executeHttpRequest fail to receive response1");
        }
        return nil;
    }
    
    NSDictionary *receivedDict = [NSJSONSerialization JSONObjectWithData:receivedData options:NSJSONReadingMutableLeaves error:&error];
    
    if ([self isHttpCloseResponse:receivedDict]&&!nonResponse) {
        if (DEBUG_ON) {
            NSLog(@"ESPMeshCommunicationUtils executeHttpRequest fail to receive response2");
        }
        return nil;
    }
    
    if (nonResponse) {
        return [self JSON_EMPTY];
    }
    
    msg = [NSString stringWithFormat:@"Response = %@",receivedDict];
    
    if (![receivedDict objectForKey:KEY_STATUS]) {
        NSString *statusStr = [NSString stringWithFormat:@"%d",(int)[response statusCode]];
        NSMutableDictionary *receivedDictMutable = [[NSMutableDictionary alloc]initWithDictionary:receivedDict];
        [receivedDictMutable setObject:statusStr forKey:KEY_STATUS];
        receivedDict = [receivedDictMutable copy];
    }
    
    return receivedDict;
}

+ (NSDictionary *) newDstHeaders: (NSDictionary *)srcHeaders NewHeaders: (NSDictionary *)newHeaders
{
    NSUInteger srcHeadersCount = srcHeaders == nil ? 0 : [srcHeaders count];
    NSUInteger newHeadersCount = newHeaders == nil ? 0 : [newHeaders count];
    NSMutableDictionary *dstHeaders = [[NSMutableDictionary alloc]initWithCapacity:(srcHeadersCount + newHeadersCount)];
    if (srcHeaders!=nil) {
        [dstHeaders addEntriesFromDictionary:srcHeaders];
    }
    if (newHeaders!=nil) {
        [dstHeaders addEntriesFromDictionary:newHeaders];
    }
    
    return dstHeaders;
}

/**
 * Post Http get request to target url
 *
 * @param url the url of the http request
 * @param bssid the mesh device's bssid
 * @param headers the headers of the http request
 * @return response or null when failed
 */
+ (NSDictionary *)HttpGet:(NSString *)url Bssid:(NSString *)bssid Headers:(NSDictionary *)headers
{
    int port = [[ESPProxyServer sharedProxyServer]getEspProxyServerPort];
    return [self executeHttpRequest:url LocalServerPort:port Method:METHOD_GET BSSID:bssid JSON:nil NonResponse:NO Headers:headers];
}

/**
 * Post Http post request to target url
 *
 * @param url the url of the http request
 * @param bssid the mesh device's bssid
 * @param json the json body to be sent
 * @param headers the headers of the http request
 * @return response or null when failed
 */
+ (NSDictionary *)HttpPost:(NSString *)url Bssid:(NSString *)bssid Json:(NSDictionary *)json Headers:(NSDictionary *)headers
{
    int port = [[ESPProxyServer sharedProxyServer]getEspProxyServerPort];
    return [self executeHttpRequest:url LocalServerPort:port Method:METHOD_POST BSSID:bssid JSON:json NonResponse:NO Headers:headers];
}

/**
 * Post Http post request to target url and don't expect response from device
 *
 * @param url the url of the http request
 * @param bssid the mesh device's bssid
 * @param json the json body to be sent
 * @param headers the headers of the http request
 * @return response or null when failed
 */
+ (NSDictionary *)HttpNonResponsePost:(NSString *)url Bssid:(NSString *)bssid Json:(NSDictionary *)json Headers:(NSDictionary *)headers
{
    int port = [[ESPProxyServer sharedProxyServer]getEspProxyServerPort];
    return [self executeHttpRequest:url LocalServerPort:port Method:METHOD_POST BSSID:bssid JSON:json NonResponse:YES Headers:headers];
}

/**
 * Just post Json Http to target url without Http headers
 *
 * @param url the url of the http request
 * @param bssid the mesh device's bssid
 * @param json the json body to be sent
 * @param headers the headers of the http request
 * @return response or null when failed
 */
+ (NSDictionary *)JsonPost:(NSString *)url Bssid:(NSString *)bssid Json:(NSDictionary *)json Headers:(NSDictionary *)headers
{
    return [self JsonPost:url Bssid:bssid Serial:SERIAL_NORMAL_TASK Json:json Headers:headers];
}

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
+ (NSDictionary *)JsonPost:(NSString *)url Bssid:(NSString *)bssid Serial:(int)serial Json:(NSDictionary *)json Headers:(NSDictionary *)headers
{
    int port = [[ESPProxyServer sharedProxyServer]getEspProxyServerPort];
    NSString *jsonHeaderValue = [NSString stringWithFormat:@"%d", M_PROTO_JSON];
    NSString *jsonHeaderKey = HEADER_PROTO_TYPE;
    NSString *serialHeaderValue = [NSString stringWithFormat:@"%d", serial];
    NSString *serialHeaderKey = HEADER_TASK_SERIAL;
    NSDictionary *newHeaders = [NSDictionary dictionaryWithObjectsAndKeys:jsonHeaderValue,jsonHeaderKey,serialHeaderValue,serialHeaderKey, nil];
    NSDictionary *dstHeaders = [self newDstHeaders:headers NewHeaders:newHeaders];
    return [self executeHttpRequest:url LocalServerPort:port Method:METHOD_POST BSSID:bssid JSON:json NonResponse:NO Headers:dstHeaders];
}


/**
 * Post read response request to target url without sending request
 *
 * @param url the url of the http request
 * @param bssid the mesh device's bssid
 * @param headers the headers of the http request
 * @return response or null when failed
 */
+ (NSDictionary *)JsonReadOnly:(NSString *)url Bssid:(NSString *)bssid Headers:(NSDictionary *)headers
{
    return [self JsonReadOnly:url Bssid:bssid Serial:SERIAL_NORMAL_TASK Headers:headers];
}

/**
 * Post read response request to target url without sending request
 *
 * @param url the url of the http request
 * @param bssid the mesh device's bssid
 * @param serial long socket serial
 * @param headers the headers of the http request
 * @return response or null when failed
 */
+ (NSDictionary *)JsonReadOnly:(NSString *)url Bssid:(NSString *)bssid Serial:(int)serial Headers:(NSDictionary *)headers
{
    return [self JsonReadOnly:url Bssid:bssid Serial:serial TaskTimeout:0 Headers:headers];
}

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
+ (NSDictionary *)JsonReadOnly:(NSString *)url Bssid:(NSString *)bssid Serial:(int)serial TaskTimeout:(int)taskTimeout Headers:(NSDictionary *)headers
{
    int port = [[ESPProxyServer sharedProxyServer]getEspProxyServerPort];
    NSString *readHeaderValue = @"1";
    NSString *readHeaderKey = HEADER_READ_ONLY;
    NSString *jsonHeaderValue = [NSString stringWithFormat:@"%d",M_PROTO_JSON];
    NSString *jsonHeaderKey = HEADER_PROTO_TYPE;
    NSString *serialHeaderValue = [NSString stringWithFormat:@"%d",serial];
    NSString *serialHeaderKey = HEADER_TASK_SERIAL;
    NSString *timeoutHeaderValue = [NSString stringWithFormat:@"%d",taskTimeout];
    NSString *timeoutHeaderKey = HEADER_TASK_TIMEOUT;
    NSDictionary *newHeaders = [NSDictionary dictionaryWithObjectsAndKeys:readHeaderValue,readHeaderKey,jsonHeaderValue,jsonHeaderKey,serialHeaderValue,serialHeaderKey,timeoutHeaderValue,timeoutHeaderKey, nil];
    NSDictionary *dstHeaders = [self newDstHeaders:headers NewHeaders:newHeaders];
    return [self executeHttpRequest:url LocalServerPort:port Method:METHOD_POST BSSID:bssid JSON:nil NonResponse:NO Headers:dstHeaders];
}

/**
 * Just post Json to target url without Http headers and don't expect response from device
 *
 * @param url the url of the http request
 * @param bssid the mesh device's bssid
 * @param json the json body to be sent
 * @return response or null when failed
 */
+ (NSDictionary *)JsonNonResponsePost:(NSString *)url Bssid:(NSString *)bssid Json:(NSDictionary *)json
{
    return [self JsonNonResponsePost:url Bssid:bssid Serial:SERIAL_NORMAL_TASK Json:json];
}

/**
 * Just post Json to target url without Http headers and don't expect response from device
 *
 * @param url the url of the http request
 * @param bssid the mesh device's bssid
 * @param serial long socket serial
 * @param json the json body to be sent
 * @return response or null when failed
 */
+ (NSDictionary *)JsonNonResponsePost:(NSString *)url Bssid:(NSString *)bssid Serial:(int)serial Json:(NSDictionary *)json
{
    int port = [[ESPProxyServer sharedProxyServer]getEspProxyServerPort];
    NSString *jsonHeaderValue = [NSString stringWithFormat:@"%d",M_PROTO_JSON];
    NSString *jsonHeaderKey = HEADER_PROTO_TYPE;
    NSString *serialHeaderValue = [NSString stringWithFormat:@"%d",serial];
    NSString *serialHeaderKey = HEADER_TASK_SERIAL;
    NSDictionary *newHeaders = [NSDictionary dictionaryWithObjectsAndKeys:jsonHeaderValue,jsonHeaderKey,serialHeaderValue,serialHeaderKey, nil];
    return [self executeHttpRequest:url LocalServerPort:port Method:METHOD_POST BSSID:bssid JSON:json NonResponse:YES Headers:newHeaders];
}

@end
