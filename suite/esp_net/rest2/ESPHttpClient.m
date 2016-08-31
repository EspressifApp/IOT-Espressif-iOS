//
//  ESPHttpClient.m
//  IOT_Espressif_IOS
//
//  Created by 白 桦 on 11/11/14.
//  Copyright (c) 2014 白 桦. All rights reserved.
//

#import "ESPHttpClient.h"
#import "ESPVersionMacro.h"
#import "ESPConstantsHttpStatus.h"
#import "ESPJsonUtil.h"

@implementation ESPHttpClient

+ (NSURLSessionConfiguration *) DEFAULT_SESSION_CONFIGURATION
{
    static dispatch_once_t predicate;
    static NSURLSessionConfiguration *DEFAULT_SESSION_CONFIGURATION;
    dispatch_once(&predicate, ^{
        DEFAULT_SESSION_CONFIGURATION = [NSURLSessionConfiguration defaultSessionConfiguration];
    });
    return DEFAULT_SESSION_CONFIGURATION;
}

// perform NSMutableURLRequest
+ (NSData *)perfomeOperationWithRequest:(NSURLRequest *)request IsDownload:(BOOL)isDownload
{
    __block NSHTTPURLResponse *httpResponse = nil;
    if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
        NSError *error = nil;
        // it will check iOS version when running time, so let XCode stop complaining
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        NSData *received = [NSURLConnection sendSynchronousRequest:request returningResponse:&httpResponse
                                                             error:&error];
#pragma clang diagnostic pop
        if(error != nil || received == nil){
            if(error!=nil){
                NSLog(@"ERROR %@ %@::error=%@",[self class],NSStringFromSelector(_cmd),error);
            }
            else{
                NSLog(@"ERROR::received == nil");
            }
            return nil;
        }
        
        if(error != nil){
            NSLog(@"ERROR %@ %@::error=%@",[self class],NSStringFromSelector(_cmd),error);
            return nil;
        }
        
        if (isDownload) {
            if(httpResponse.statusCode != HTTP_STATUS_OK) {
                NSLog(@"ERROR %@ %@::httpRespose.statusCode is %d",[self class],NSStringFromSelector(_cmd),(int)httpResponse.statusCode);
                return nil;
            }
        } else {
            NSNumber *statusNumber = [NSNumber numberWithInteger:httpResponse.statusCode];
            if (received==nil) {
                NSDictionary *dict = @{@"status":statusNumber};
                received = [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:nil];
            } else {
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:received options:NSJSONReadingMutableLeaves error:&error];
                NSMutableDictionary *mutableDict = [[NSMutableDictionary alloc]initWithDictionary:dict];
                if ([mutableDict objectForKey:@"status"]==nil) {
                    [mutableDict setObject:statusNumber forKey:@"status"];
                    received = [NSJSONSerialization dataWithJSONObject:mutableDict options:kNilOptions error:nil];
                }

            }
        }
        return received;
    }
    else {
        NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:[self DEFAULT_SESSION_CONFIGURATION] delegate:nil delegateQueue:[NSOperationQueue currentQueue]];
        __block dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        __block NSData *received = nil;
        [[urlSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error){
            if (error !=nil ){
                NSLog(@"ERROR %@ %@::error=%@",[self class],NSStringFromSelector(_cmd),error);
            } else {
                received = data;
                httpResponse = (NSHTTPURLResponse *)response;
                if (isDownload) {
                    if(httpResponse.statusCode != HTTP_STATUS_OK) {
                        NSLog(@"ERROR %@ %@::httpRespose.statusCode is %d",[self class],NSStringFromSelector(_cmd),(int)httpResponse.statusCode);
                        received = nil;
                    }
                } else {
                    NSNumber *statusNumber = [NSNumber numberWithInteger:httpResponse.statusCode];
                    if (received==nil) {
                        NSDictionary *dict = @{@"status":statusNumber};
                        received = [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:nil];
                    } else {
                        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:received options:NSJSONReadingMutableLeaves error:&error];
                        NSMutableDictionary *mutableDict = [[NSMutableDictionary alloc]initWithDictionary:dict];
                        if ([mutableDict objectForKey:@"status"]==nil) {
                            [mutableDict setObject:statusNumber forKey:@"status"];
                            received = [NSJSONSerialization dataWithJSONObject:mutableDict options:kNilOptions error:nil];
                        }
                    }
                }
                
            }
            dispatch_semaphore_signal(semaphore);
        }] resume];
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        return received;
    }
}

// send request and parse response to json
+ (NSDictionary *)executeForJsonWithRequest:(NSURLRequest *)request
{
    NSData *received = [self perfomeOperationWithRequest:request IsDownload:NO];
    if (received==nil) {
        return nil;
    } else {
        NSError *error = nil;
        NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:received options:NSJSONReadingMutableLeaves error:&error];
        if(error != nil){
            NSLog(@"ERROR %@ %@ ::error=%@",[self class],NSStringFromSelector(_cmd),error);
            return nil;
        } else {
#ifdef DEBUG
            NSLog(@"%@ %@::response=%@",[self class],NSStringFromSelector(_cmd),dict);
#endif
            return dict;
        }
    }
}

// generate the NSMutableURLRequest
+ (NSMutableURLRequest *)genURLRequest:(NSString *)path
                               headers:(NSDictionary *)headers
                            parameters:(NSDictionary *)parameters
                        timeoutSeconds:(NSUInteger)timeoutSeconds
                            httpMethod:(NSString *)httpMethod
{
    NSURL *url = [NSURL URLWithString:path];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:timeoutSeconds];
    NSLog(@"%@ %@::path=%@,headers=%@,parameters=%@,timeoutSeconds=%d,httpMethod=%@",[self class],NSStringFromSelector(_cmd),path,headers,parameters,(int)timeoutSeconds,httpMethod);
    // don't use cookie
    [request setHTTPShouldHandleCookies:NO];
    // set timeout
    [request setTimeoutInterval:timeoutSeconds];
    // set HTTP Method
    [request setHTTPMethod:httpMethod];
    // set HTTP Headers
    if(headers!=nil)
    {
        [request setAllHTTPHeaderFields:headers];
    }
    // set HTTP Body(JSONObject)
    if(parameters!=nil)
    {
        NSData* parametersData = [NSJSONSerialization dataWithJSONObject:parameters options:kNilOptions error:nil];
        parametersData = [ESPJsonUtil retransferData:parametersData];
        [request setHTTPBody:parametersData];
    }
    return request;
}

+ (NSData *)downloadSynPath:(NSString *)path
                    headers:(NSDictionary *)headers
                 parameters:(NSDictionary *)parameters
             timeoutSeconds:(NSTimeInterval)timeoutSeconds
{
    NSMutableURLRequest *request = [ESPHttpClient genURLRequest:path headers:headers parameters:parameters timeoutSeconds:timeoutSeconds httpMethod:@"GET"];
    return [ESPHttpClient perfomeOperationWithRequest:request IsDownload:YES];
}

#pragma mark - GET Operation
+ (NSDictionary *)getSynPath:(NSString *)path
                     headers:(NSDictionary *)headers
                  parameters:(NSDictionary *)parameters
              timeoutSeconds:(NSUInteger)timeoutSeconds
{
    NSMutableURLRequest *request = [ESPHttpClient genURLRequest:path headers:headers parameters:parameters timeoutSeconds:timeoutSeconds httpMethod:@"GET"];
    return [ESPHttpClient executeForJsonWithRequest:request];
}

#pragma mark - POST Operation
+ (NSDictionary *)postSynPath:(NSString *)path
                      headers:(NSDictionary *)headers
                   parameters:(NSDictionary *)parameters
               timeoutSeconds:(NSUInteger)timeoutSeconds

{
    NSMutableURLRequest *request = [ESPHttpClient genURLRequest:path headers:headers parameters:parameters timeoutSeconds:timeoutSeconds httpMethod:@"POST"];
    return [ESPHttpClient executeForJsonWithRequest:request];
}

#pragma mark - PUT Operation
+ (NSDictionary *)putSynPath:(NSString *)path
                     headers:(NSDictionary *)headers
                  parameters:(NSDictionary *)parameters
              timeoutSeconds:(NSUInteger)timeoutSeconds

{
    NSMutableURLRequest *request = [ESPHttpClient genURLRequest:path headers:headers parameters:parameters timeoutSeconds:timeoutSeconds httpMethod:@"PUT"];
    return [ESPHttpClient executeForJsonWithRequest:request];
}

#pragma mark - DELETE Operation
+ (NSDictionary *)deleteSynPath:(NSString *)path
                        headers:(NSDictionary *)headers
                     parameters:(NSDictionary *)parameters
                 timeoutSeconds:(NSUInteger)timeoutSeconds

{
    NSMutableURLRequest *request = [ESPHttpClient genURLRequest:path headers:headers parameters:parameters timeoutSeconds:timeoutSeconds httpMethod:@"DELETE"];
    return [ESPHttpClient executeForJsonWithRequest:request];
}


@end
