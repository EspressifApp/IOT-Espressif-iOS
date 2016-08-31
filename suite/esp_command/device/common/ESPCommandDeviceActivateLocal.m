//
//  ESPCommandDeviceActivateLocal.m
//  suite
//
//  Created by 白 桦 on 7/26/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import "ESPCommandDeviceActivateLocal.h"
#import "ESPBaseApiUtil.h"

@implementation ESPCommandDeviceActivateLocal

-(NSString *) getLocalUrl:(NSString *)inetAddr
{
    return [NSString stringWithFormat:@"http://%@/config?command=wifi",inetAddr];
}

-(NSDictionary *) getJsonRequest:(NSString *)randomToken
{
    NSDictionary *content = @{@"token":randomToken};
    NSDictionary *contentStation = @{@"Connect_Station":content};
    NSDictionary *station = @{@"Station":contentStation};
    NSDictionary *request = @{@"Request":station};
    return request;
}

/**
 * make the device activate on Server
 *
 * @param inetAddress the device's ip address
 * @param randomToken 40 randomToken
 * @return whether the command executed suc
 */
-(BOOL) doCommandDeviceActivateLocalInetAddr:(NSString *)inetAddr RandomToken:(NSString *)randomToken
{
    NSString *urlString = [self getLocalUrl:inetAddr];
    NSDictionary *requestJson = [self getJsonRequest:randomToken];
    NSDictionary *responseJson = [ESPBaseApiUtil Post:urlString Json:requestJson Headers:nil];
    BOOL isSuc = responseJson!=nil;
    return isSuc;
}

/**
 * make the mesh device activate on Server
 *
 * @param bssid the mesh device's bssid
 * @param inetAddr the mesh device's ip address
 * @param randomToken 40 randomToken
 * @return whether the command executed suc
 */
-(BOOL) doCommandMeshDeviceActivateLoalBssid:(NSString *)bssid InetAddr:(NSString *)inetAddr RandomToken:(NSString *)randomToken
{
    NSString *urlString = [self getLocalUrl:inetAddr];
    NSDictionary *requestJson = [self getJsonRequest:randomToken];
    NSDictionary *responseJson = [ESPBaseApiUtil PostForJson:urlString Bssid:bssid Json:requestJson Headers:nil];
    BOOL isSuc = responseJson!=nil;
    return isSuc;
}

@end
