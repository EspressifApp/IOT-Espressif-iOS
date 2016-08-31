//
//  ESPActionDeviceActivateLocal.m
//  suite
//
//  Created by 白 桦 on 7/27/16.
//  Copyright © 2016 白 桦. All rights reserved.
//

#import "ESPActionDeviceActivateLocal.h"
#import "ESPCommandDeviceActivateLocal.h"

@implementation ESPActionDeviceActivateLocal

/**
 * make the device activate on Server
 *
 * @param inetAddress the device's ip address
 * @param randomToken 40 randomToken
 * @return whether the command executed suc
 */
-(BOOL) doActionDeviceActivateLocalInetAddr:(NSString *)inetAddr RandomToken:(NSString *)randomToken
{
    ESPCommandDeviceActivateLocal *command = [[ESPCommandDeviceActivateLocal alloc]init];
    return [command doCommandDeviceActivateLocalInetAddr:inetAddr RandomToken:randomToken];
}

/**
 * make the mesh device activate on Server
 *
 * @param bssid the mesh device's bssid
 * @param inetAddr the mesh device's ip address
 * @param randomToken 40 randomToken
 * @return whether the command executed suc
 */
-(BOOL) doActionMeshDeviceActivateLoalBssid:(NSString *)bssid InetAddr:(NSString *)inetAddr RandomToken:(NSString *)randomToken
{
    ESPCommandDeviceActivateLocal *command = [[ESPCommandDeviceActivateLocal alloc]init];
    return [command doCommandMeshDeviceActivateLoalBssid:bssid InetAddr:inetAddr RandomToken:randomToken];
}
@end
