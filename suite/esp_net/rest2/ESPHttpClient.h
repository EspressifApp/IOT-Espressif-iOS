//
//  ESPHttpClient.h
//  IOT_Espressif_IOS
//
//  Created by 白 桦 on 11/11/14.
//  Copyright (c) 2014 白 桦. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ESPHttpClient : NSObject

/**
 * Perfomrs a GET HTTP Request to download data Synchronously
 *
 * @param path The path of the desired resource
 * @param headers An NSDictionary containing the headers of the request
 * @param timeoutSeconds seconds of timeout
 *
 * @return the result of data
 */
+ (NSData *)downloadSynPath:(NSString *)path
                    headers:(NSDictionary *)headers
                 parameters:(NSDictionary *)parameters
             timeoutSeconds:(NSTimeInterval)timeoutSeconds;


/**
 * Performs a GET HTTP Request Synchronously
 * @param path The path of the desired resource
 * @param headers An NSDictionary containing the headers of the request
 * @param parameters An NSDictionary containing the Json parameters of the request
 * @param timeoutSeconds seconds of timeout
 *
 * @return the result of the Request containing the Json Parameters
 */
+ (NSDictionary *)getSynPath:(NSString *)path
                  headers:(NSDictionary *)headers
               parameters:(NSDictionary *)parameters
           timeoutSeconds:(NSUInteger) timeoutSeconds;


/**
 * Performs a POST HTTP Request Synchronously
 * @param path The path of the desired resource
 * @param headers An NSDictionary containing the headers of the request
 * @param parameters An NSDictionary containing the Json parameters of the request
 * @param timeoutSeconds seconds of timeout
 *
 * @return the result of the Request containing the Json Parameters
 */
+ (NSDictionary *)postSynPath:(NSString *)path
                   headers:(NSDictionary *)headers
                parameters:(NSDictionary *)parameters
            timeoutSeconds:(NSUInteger)timeoutSeconds;


/**
 * Performs a PUT HTTP Request Synchronously
 * @param path The path of the desired resource
 * @param headers An NSDictionary containing the headers of the request
 * @param parameters An NSDictionary containing the Json parameters of the request
 * @param timeoutSeconds seconds of timeout
 *
 * @return the result of the Request containing the Json Parameters
 */
+ (NSDictionary *)putSynPath:(NSString *)path
                  headers:(NSDictionary *)headers
               parameters:(NSDictionary *)parameters
           timeoutSeconds:(NSUInteger)timeoutSeconds;


/**
 * Performs a DELETE HTTP Request Synchronously
 * @param path The path of the desired resource
 * @param headers An NSDictionary containing the headers of the request
 * @param parameters An NSDictionary containing the Json parameters of the request
 * @param timeoutSeconds seconds of timeout
 *
 * @return the result of the Request containing the Json Parameters
 */
+ (NSDictionary *)deleteSynPath:(NSString *)path
                     headers:(NSDictionary *)headers
                  parameters:(NSDictionary *)parameters
              timeoutSeconds:(NSUInteger)timeoutSeconds;

@end
